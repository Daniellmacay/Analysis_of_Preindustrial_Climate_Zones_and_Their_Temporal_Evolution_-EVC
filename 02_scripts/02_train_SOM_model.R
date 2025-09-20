library(kohonen)

INPUT_MATRIX_FILE <- "Data/processed/preindustrial_matrix_scaled.rds"
OUTPUT_MODEL_FILE <- "03_results/models/som_model.rds"

message(paste("Loading PRE-SCALED pre-industrial matrix from:", INPUT_MATRIX_FILE))
preindustrial_matrix <- readRDS(INPUT_MATRIX_FILE)
message("Data loaded successfully.")

som_grid <- somgrid(xdim = 6, ydim = 6, topo = "hexagonal")

message("Training SOM model... (This may take a few moments)")
set.seed(123)
som_model <- som(preindustrial_matrix,
                 grid = som_grid,
                 rlen = 500,
                 alpha = c(0.05, 0.01),
                 keep.data = TRUE)

message("Model training complete.")

output_dir <- dirname(OUTPUT_MODEL_FILE)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

message(paste("Saving trained model to:", OUTPUT_MODEL_FILE))
saveRDS(som_model, file = OUTPUT_MODEL_FILE)

message(paste("\n✅ SOM model successfully trained and saved."))