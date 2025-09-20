library(tidyverse)
library(ncdf4)

INPUT_SOM_RESULTS_CSV <- "03_results/som_clusters_preindustrial.csv"
INPUT_NC_FILE <- "Data/processed/Land_and_Ocean_Alternate_EqualArea_Cleaned.nc"
OUTPUT_PCA_RDS <- "03_results/models/pca_results_by_cluster.rds"

message("Loading SOM cluster assignments...")
som_results <- read.csv(INPUT_SOM_RESULTS_CSV)
message("Loading full-period temperature data from NetCDF...")
nc <- nc_open(INPUT_NC_FILE)
temp_full_matrix <- ncvar_get(nc, "temperature")
time_monthly <- ncvar_get(nc, "time")
nc_close(nc)

message("Creating full-period decadal matrix...")
start_year <- 1850
dates <- start_year + floor(time_monthly / 12)
decades <- floor(dates / 10) * 10
unique_decades <- sort(unique(decades))
full_decadal_matrix <- sapply(unique_decades, function(d) {
  temp_subset <- temp_full_matrix[, decades == d, drop = FALSE]
  rowMeans(temp_subset, na.rm = TRUE)
})
colnames(full_decadal_matrix) <- as.character(unique_decades)
message("Full decadal matrix created.")

unique_clusters <- sort(unique(som_results$cluster))
pca_results_list <- list()
message("\n--- Starting PCA for each SOM cluster ---")
for (cl in unique_clusters) {
  point_indices <- which(som_results$cluster == cl)
  cluster_data_matrix <- full_decadal_matrix[point_indices, ]
  pca_result <- prcomp(cluster_data_matrix, scale. = TRUE, center = TRUE)
  pca_results_list[[as.character(cl)]] <- pca_result
  message(paste("PCA completed for Cluster", cl))
}
message("--- All PCAs completed ---")

message("\n--- Summary of Variance Explained by Principal Components ---")
for (cl_name in names(pca_results_list)) {
  pca_obj <- pca_results_list[[cl_name]]
  eigenvalues <- pca_obj$sdev^2
  variance_explained <- eigenvalues / sum(eigenvalues) * 100
  cat(paste("\n--- Cluster:", cl_name, "---\n"))
  cat(paste0("PC1 explains: ", round(variance_explained[1], 2), "%\n"))
  cat(paste0("PC2 explains: ", round(variance_explained[2], 2), "%\n"))
  cat(paste0("PC3 explains: ", round(variance_explained[3], 2), "%\n"))
}

message(paste("\nSaving full PCA results object to:", OUTPUT_PCA_RDS))
saveRDS(pca_results_list, file = OUTPUT_PCA_RDS)
message("PCA results object saved successfully.")

message("\n✅ PCA analysis complete.")