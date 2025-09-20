library(tidyverse)

INPUT_PCA_RDS <- "03_results/models/pca_results_by_cluster.rds"
OUTPUT_PLOT_FILE <- "03_results/graficas/pca_pc1_timeseries_by_cluster.png"

message("Loading PCA results object...")
pca_results_list <- readRDS(INPUT_PCA_RDS)

pc1_all_clusters <- tibble()
for (cl_name in names(pca_results_list)) {
  pca_obj <- pca_results_list[[cl_name]]
  pc1_timeseries <- pca_obj$rotation[, "PC1"]
  temp_df <- tibble(
    cluster = as.factor(cl_name),
    decade = as.numeric(names(pc1_timeseries)),
    pc1_value = pc1_timeseries
  )
  pc1_all_clusters <- bind_rows(pc1_all_clusters, temp_df)
}
message("PC1 time series extracted for all clusters.")

message("Generating visualization...")
final_plot <- ggplot(pc1_all_clusters, aes(x = decade, y = pc1_value, group = cluster)) +
  geom_line(color = "navy") +
  geom_smooth(method = "loess", se = FALSE, color = "red", linetype = "dashed", span = 0.5) +
  facet_wrap(~ cluster, ncol = 6) + 
  labs(
    title = "Patrón de Cambio Dominante (PC1) por Clúster Climático (1850-2024)",
    subtitle = "Cada panel muestra la serie de tiempo del Componente Principal 1 para un grupo SOM",
    x = "Década",
    y = "Valor del Componente Principal 1"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6))

output_dir <- dirname(OUTPUT_PLOT_FILE)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

message(paste("Saving final plot to:", OUTPUT_PLOT_FILE))
ggsave(OUTPUT_PLOT_FILE, plot = final_plot, width = 14, height = 10, dpi = 300)

message("\n✅ ¡Análisis completado! Revisa la imagen en tu carpeta '03_results/graficas/'.")