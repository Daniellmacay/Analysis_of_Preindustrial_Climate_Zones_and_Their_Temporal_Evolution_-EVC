library(kohonen)
library(tidyverse)
library(maps)
library(ncdf4)

INPUT_MODEL_FILE <- "03_results/models/som_model.rds"
INPUT_NC_FILE <- "Data/processed/Land_and_Ocean_Alternate_EqualArea_Cleaned.nc"

OUTPUT_PLOT_FILE <- "03_results/graficas/mapa_clusters_preindustrial.png"
OUTPUT_CSV_FILE <- "03_results/som_clusters_preindustrial.csv"

message("Loading trained SOM model and coordinates...")
som_model <- readRDS(INPUT_MODEL_FILE)

nc_data <- nc_open(INPUT_NC_FILE)
lon <- ncvar_get(nc_data, "longitude_coords")
lat <- ncvar_get(nc_data, "latitude_coords")
nc_close(nc_data)

cluster_assignments <- som_model$unit.classif

results_df <- data.frame(
  lon = lon,
  lat = lat,
  cluster = as.factor(cluster_assignments)
)

message("Cluster information extracted.")

world_map <- map_data("world")

message("Generating cluster map...")
cluster_map <- ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), 
               fill = "gray80", color = "white") +
  geom_point(data = results_df, aes(x = lon, y = lat, color = cluster), size = 1, alpha = 0.7) +
  scale_color_viridis_d(name = "Climate Cluster") +
  labs(title = "Climate Clusters (Pre-industrial Period: 1850-1900)",
       subtitle = "Clusters identified by a 6x6 Self-Organizing Map",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal() +
  coord_fixed(1.3)

message(paste("Saving map to:", OUTPUT_PLOT_FILE))
output_dir_graficas <- dirname(OUTPUT_PLOT_FILE)
if (!dir.exists(output_dir_graficas)) {
  dir.create(output_dir_graficas, recursive = TRUE)
}
ggsave(OUTPUT_PLOT_FILE, plot = cluster_map, width = 12, height = 8, dpi = 300)
message("Map created successfully!")

message(paste("Saving results to CSV:", OUTPUT_CSV_FILE))
write.csv(results_df, file = OUTPUT_CSV_FILE, row.names = FALSE)
message("CSV file created successfully!")

message("\n✅ Process complete! Map and CSV file are in your '03_results' folder.")