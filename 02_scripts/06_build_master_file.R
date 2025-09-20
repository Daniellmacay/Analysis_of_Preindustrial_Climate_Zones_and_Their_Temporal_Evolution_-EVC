library(tidyverse)
library(ncdf4)

INPUT_SOM_MODEL_RDS <- "03_results/models/som_model.rds"
INPUT_PCA_RDS <- "03_results/models/pca_results_by_cluster.rds"
INPUT_NC_FILE <- "Data/processed/Land_and_Ocean_Alternate_EqualArea_Cleaned.nc"

OUTPUT_MASTER_CSV <- "03_results/EVC_master_dataset_final.csv"

message("Loading all source data...")
som_model <- readRDS(INPUT_SOM_MODEL_RDS)
pca_results_list <- readRDS(INPUT_PCA_RDS)

nc <- nc_open(INPUT_NC_FILE)
temp_full_matrix <- ncvar_get(nc, "temperature")
time_monthly <- ncvar_get(nc, "time")
lon <- ncvar_get(nc, "longitude_coords")
lat <- ncvar_get(nc, "latitude_coords")
nc_close(nc)

base_df <- tibble(
  point_id = 1:length(lon),
  lon = lon,
  lat = lat,
  som_cluster = som_model$unit.classif
)

message("Calculating and adding decadal temperatures...")
start_year <- 1850
dates <- start_year + floor(time_monthly / 12)
decades <- floor(dates / 10) * 10
unique_decades <- sort(unique(decades))

full_decadal_matrix <- sapply(unique_decades, function(d) {
  temp_subset <- temp_full_matrix[, decades == d, drop = FALSE]
  rowMeans(temp_subset, na.rm = TRUE)
})
colnames(full_decadal_matrix) <- paste0("temp_", as.character(unique_decades), "s")

base_df <- base_df %>%
  bind_cols(as_tibble(full_decadal_matrix))

message("Adding PCA scores...")
pca_scores_df <- map_df(pca_results_list, ~ as_tibble(.x$x), .id = "cluster") %>%
  group_by(cluster) %>%
  mutate(point_in_cluster_id = row_number()) %>%
  ungroup() %>%
  rename_with(~ sub("PC", "PC_", .x, fixed = TRUE), starts_with("PC"))

base_df_with_temp_id <- base_df %>%
  mutate(cluster = as.character(som_cluster)) %>%
  group_by(cluster) %>%
  mutate(point_in_cluster_id = row_number()) %>%
  ungroup()

master_df <- left_join(base_df_with_temp_id, pca_scores_df, 
                       by = c("cluster", "point_in_cluster_id")) %>%
  select(-point_id, -point_in_cluster_id, -cluster)

message(paste("Saving the final master CSV to:", OUTPUT_MASTER_CSV))
write.csv(master_df, OUTPUT_MASTER_CSV, row.names = FALSE)

message("\n✅ ¡Proceso completado!")