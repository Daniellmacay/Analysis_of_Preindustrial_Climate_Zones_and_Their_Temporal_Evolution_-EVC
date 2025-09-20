library(ncdf4)
library(zoo)
library(dplyr)
library(tools)

original_locale <- Sys.getlocale("LC_ALL")
Sys.setlocale("LC_ALL", "C")

INPUT_DIR <- "Data/crudos/"
OUTPUT_DIR <- "Data/processed/"
ORIGINAL_NC_FILES <- c("Land_and_Ocean_Alternate_EqualArea.nc")

process_single_nc_file <- function(original_filename, input_dir, output_dir) {
  original_filepath <- file.path(input_dir, original_filename)
  clean_filename <- paste0(tools::file_path_sans_ext(original_filename), "_Cleaned.nc")
  clean_filepath <- file.path(output_dir, clean_filename)
  
  if (!file.exists(original_filepath)) {
    message(paste("ERROR: El archivo no se encuentra en:", original_filepath))
    return(NULL)
  }
  
  message(paste("\n--- Procesando:", original_filename, "---"))
  nc_original <- nc_open(original_filepath)
  
  lon <- ncvar_get(nc_original, "longitude")
  lat <- ncvar_get(nc_original, "latitude")
  temp_raw <- ncvar_get(nc_original, "temperature")
  
  n_months <- dim(temp_raw)[2]
  time_cleaned <- 0:(n_months - 1)
  time_units_cleaned <- "months since 1850-01-01"
  
  nc_close(nc_original)
  message(paste("Dimensiones cargadas:", paste(dim(temp_raw), collapse = "x")))
  
  initial_valid_rows <- apply(temp_raw, 1, function(x) !all(is.na(x)))
  lon_filtered <- lon[initial_valid_rows]
  lat_filtered <- lat[initial_valid_rows]
  temp_filtered <- temp_raw[initial_valid_rows, ]
  
  message(paste("Puntos válidos iniciales:", nrow(temp_filtered)))
  
  message("Iniciando interpolación...")
  temp_interpolated <- apply(temp_filtered, 1, function(x) {
    x_interp <- zoo::na.approx(x, na.rm = FALSE)
    x_interp <- zoo::na.locf(x_interp, na.rm = FALSE, fromLast = FALSE)
    x_interp <- zoo::na.locf(x_interp, na.rm = FALSE, fromLast = TRUE)
    return(x_interp)
  })
  temp_interpolated <- t(temp_interpolated)
  
  message("Interpolación completada.")
  
  dim_point_id <- ncdim_def("point_id", "index", 1:nrow(temp_interpolated))
  dim_time <- ncdim_def("time", time_units_cleaned, time_cleaned)
  
  var_temp_2d <- ncvar_def("temperature", "degrees_celsius", list(dim_point_id, dim_time), -9999, prec="float")
  var_lon_coords <- ncvar_def("longitude_coords", "degrees_east", list(dim_point_id), -9999, prec="float")
  var_lat_coords <- ncvar_def("latitude_coords", "degrees_north", list(dim_point_id), -9999, prec="float")
  
  nc_cleaned <- nc_create(clean_filepath, list(var_temp_2d, var_lon_coords, var_lat_coords))
  
  ncvar_put(nc_cleaned, var_temp_2d, temp_interpolated)
  ncvar_put(nc_cleaned, var_lon_coords, lon_filtered)
  ncvar_put(nc_cleaned, var_lat_coords, lat_filtered)
  
  nc_close(nc_cleaned)
  message(paste("Archivo limpio guardado en:", clean_filepath))
}

tryCatch({
  for (file in ORIGINAL_NC_FILES) {
    process_single_nc_file(file, INPUT_DIR, OUTPUT_DIR)
  }
  message("\n--- Proceso de limpieza completado ---")
}, finally = {
  Sys.setlocale("LC_ALL", original_locale)
  message("\nConfiguración regional restaurada.")
})