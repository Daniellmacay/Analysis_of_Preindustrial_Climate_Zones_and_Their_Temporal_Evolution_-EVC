library(tidyverse)
library(maps)

SOM_COMP_CSV <- "03_results/som_clusters_comparison.csv"
PCA_VAL_CSV <- "03_results/pca_validation_summary.csv"

OUTPUT_SOM_MAP <- "03_results/graficas/mapa_comparacion_som.png"
OUTPUT_PCA_NFACTORS_PLOT <- "03_results/graficas/pca_componentes_significativos.png"

message("Cargando resultados de los análisis avanzados...")
som_comp_df <- read_csv(SOM_COMP_CSV)
pca_val_df <- read_csv(PCA_VAL_CSV)

message("Generando Gráfico 1: Mapa Comparativo de SOMs...")
som_plot_df <- som_comp_df %>%
  pivot_longer(
    cols = c("cluster_original", "cluster_correlacion"),
    names_to = "tipo_distancia",
    values_to = "cluster_id"
  ) %>%
  mutate(tipo_distancia = recode(tipo_distancia,
                                 "cluster_original" = "Distancia Euclidiana (por Magnitud)",
                                 "cluster_correlacion" = "Distancia de Correlación (por Forma)"))

world_map <- map_data("world")

mapa_comparativo <- ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), fill = "gray80", color = "white") +
  geom_point(data = som_plot_df, aes(x = lon, y = lat, color = as.factor(cluster_id)), size = 1) +
  facet_wrap(~ tipo_distancia, ncol = 1) +
  scale_color_viridis_d(name = "Cluster ID") +
  labs(title = "Comparación de Clustering SOM según Métrica de Distancia",
       subtitle = "Datos Preindustriales (1850-1900)",
       x = "Longitud", y = "Latitud") +
  theme_minimal() +
  coord_fixed(1.3) +
  theme(legend.position = "none")

ggsave(OUTPUT_SOM_MAP, plot = mapa_comparativo, width = 8, height = 10, dpi = 300)

message("Generando Gráfico: Componentes Significativos por Clúster...")

complejidad_plot <- ggplot(pca_val_df, aes(x = reorder(as.factor(cluster), -n_components_sugeridos), y = n_components_sugeridos)) +
  geom_col(fill = "salmon", color = "black") +
  geom_text(aes(label = n_components_sugeridos), vjust = 1.5, color = "white") +
  labs(title = "Complejidad de la Señal Climática por Clúster",
       subtitle = "Número de Componentes Principales estadísticamente significativos (Análisis Paralelo)",
       x = "Clúster SOM (Ordenado por complejidad)",
       y = "Número de Componentes Significativos") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggsave(OUTPUT_PCA_NFACTORS_PLOT, plot = complejidad_plot, width = 12, height = 7, dpi = 300)

cat("\n✅ Visualizaciones avanzadas completadas. Revisa la carpeta '03_results/graficas/'.\n")