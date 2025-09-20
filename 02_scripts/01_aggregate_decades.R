library(ncdf4)
library(dplyr)

nc_file <- "Data/processed/Land_and_Ocean_Alternate_EqualArea_Cleaned.nc"

nc <- nc_open(nc_file)

temp <- ncvar_get(nc, "temperature")
time <- ncvar_get(nc, "time")
lon <- ncvar_get(nc, "longitude_coords")
lat <- ncvar_get(nc, "latitude_coords")

nc_close(nc)

start_year <- 1850
dates <- start_year + floor(time / 12)

decades <- floor(dates / 10) * 10
unique_decades <- sort(unique(decades))

preindustrial_matrix <- sapply(unique_decades, function(d) {
  rowMeans(temp[, decades == d], na.rm = TRUE)
})

colnames(preindustrial_matrix) <- as.character(unique_decades)

saveRDS(preindustrial_matrix, "Data/processed/preindustrial_matrix.rds")
write.csv(preindustrial_matrix, "Data/processed/preindustrial_matrix.csv", row.names = FALSE)

cat("¡Matriz preindustrial generada y guardada correctamente!\n")