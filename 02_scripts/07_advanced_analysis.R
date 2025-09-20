library(kohonen)
library(psych)
library(boot)
library(tidyverse)

message("Cargando el archivo maestro de datos...")
data <- read_csv("03_results/EVC_master_dataset_final.csv")

temp_cols <- grep("^temp_", names(data), value = TRUE)

message("\n--- Iniciando Análisis de Distancias SOM ---")

preindustrial_cols <- paste0("temp_", seq(1850, 1900, 10), "s")
preindustrial_matrix <- data %>%
  select(all_of(preindustrial_cols)) %>%
  as.matrix()

X_pre_cor <- t(scale(t(preindustrial_matrix)))
X_pre_cor[is.nan(X_pre_cor)] <- 0

som_grid <- somgrid(xdim = 6, ydim = 6, topo = "hexagonal")

message("Entrenando SOM basado en Correlación...")
set.seed(123)
som_cor <- som(X_pre_cor, grid = som_grid, rlen = 1000)

saveRDS(som_cor, "03_results/models/som_model_correlation.rds")

clusters_comp_df <- tibble(
  lon = data$lon,
  lat = data$lat,
  cluster_original = data$som_cluster,
  cluster_correlacion = som_cor$unit.classif
)
write_csv(clusters_comp_df, "03_results/som_clusters_comparison.csv")
message("Comparación de clústeres SOM guardada.")

message("\n--- Iniciando Validación de PCA por Clúster (Método Simplificado) ---")

validar_pca_cluster_simple <- function(cluster_id) {
  subset_data <- data %>%
    filter(som_cluster == cluster_id) %>%
    select(all_of(temp_cols))
  
  cor_matrix <- cor(subset_data, use = "pairwise.complete.obs")
  
  pa_results <- fa.parallel(cor_matrix, 
                            n.obs = nrow(subset_data),
                            fa = "pc", 
                            n.iter = 100, 
                            show.legend = FALSE, 
                            plot = FALSE)
  
  return(list(cluster = cluster_id, pa = pa_results))
}

clusters <- sort(unique(data$som_cluster))
pca_validation_raw <- lapply(clusters, function(cl) {
  tryCatch({
    validar_pca_cluster_simple(cl)
  }, error = function(e) {
    message(paste("ADVERTENCIA: Falló la validación para el clúster", cl, "- Error:", e$message))
    return(NULL)
  })
})

pca_validation <- pca_validation_raw[!sapply(pca_validation_raw, is.null)]

saveRDS(pca_validation, "03_results/models/pca_validation_results.rds")

pca_table <- do.call(rbind, lapply(pca_validation, function(x) {
  data.frame(
    cluster = x$cluster,
    n_components_sugeridos = x$pa$ncomp
  )
}))

write_csv(pca_table, "03_results/pca_validation_summary.csv")
message("Resultados de validación de PCA (simplificada) guardados.")

cat("\n✅ Análisis avanzado completado. Revisa la carpeta '03_results' para los nuevos archivos.\n")