# Análisis de Zonas Climáticas Preindustriales y su Evolución Temporal (EVC)

Este repositorio contiene el código y los resultados de un análisis geoespacial para identificar zonas climáticas basándose en datos del periodo preindustrial (1850-1900) y analizar su evolución hasta el año 2020.

---
## Tabla de Contenidos
1.  [**Sobre el Proyecto**](#-sobre-el-proyecto)
2.  [**Metodología**](#-metodología)
3.  [**Estructura del Repositorio**](#-estructura-del-repositorio)
4.  [**Cómo Ejecutar el Análisis**](#-cómo-ejecutar-el-análisis)
5.  [**Resultados Clave**](#-resultados-clave)
6.  [**Visualizador Interactivo**](#-visualizador-interactivo)

---

##  Sobre el Proyecto

Este análisis busca responder a la pregunta: **¿Cómo han evolucionado las regiones climáticas, definidas por sus características en la era preindustrial, hasta la actualidad?**

Para ello, se emplea un enfoque de aprendizaje no supervisado (SOM) para definir estas zonas de manera objetiva y, posteriormente,
se analiza su dinámica temporal con un Análisis de Componentes Principales (PCA) para identificar los patrones de cambio más significativos en cada una.

---

#### **Paso 0: Limpieza de Datos**
* **Script**: `00_preprocess_data.R`
* **Proceso**: Se parte de un archivo NetCDF con datos de temperatura mensual. Se aplica una imputación espacial e interpolación temporal robusta para rellenar todos los valores `NA`,
               asegurando una serie de tiempo continua.

#### **Paso 1: Agregación por Década**
* **Script**: `01_aggregate_decades.R`
* **Proceso**: Los datos mensuales limpios se agregan para obtener valores promedio por década (1850s-1900s).

#### **Paso 2: Clustering Preindustrial (SOM)**
* **Script**: `02_train_som_model.R`
* **Proceso**: Se entrena un **Mapa Autoorganizado (SOM)** utilizando únicamente la matriz de datos del periodo preindustrial (1850-1900) para clasificar el planeta en 36 zonas climáticas.

#### **Paso 3: Análisis de Evolución (PCA)**
* **Scripts**: `03_visualize_som.R`, `04_run_pca_by_cluster.R`, `05_visualize_pca_results.R`
* **Proceso**: Para cada uno de los 36 clústeres, se realiza un **Análisis de Componentes Principales (PCA)** sobre la serie de tiempo completa (1850-2020) para extraer sus "modos" o
               patrones fundamentales de cambio. Se visualizan los clústeres en un mapa y los patrones de cambio (PC1) en gráficos de series de tiempo.

#### **Paso 4: Consolidación y Exportación**
* **Script**: `06_build_master_file.R`
* **Proceso**: Se consolidan todos los resultados (coordenadas, SOM, PCA, temperaturas) en un único archivo CSV maestro, optimizado para la visualización interactiva.

#### **Paso 5: Análisis Avanzado (Opcional)**
* **Scripts**: `07_advanced_analysis.R`, `08_visualize_advanced.R`
* **Proceso**: Se realizan análisis de validación, incluyendo una comparación de métricas de distancia en el SOM y una validación estadística de la potencia de los PCA mediante Análisis Paralelo.

---
##  Estructura del Repositorio

El proyecto está organizado en las siguientes carpetas:

* **`/Data/`**: Contiene los datos crudos y los procesados (`/processed`).
* **`/02_scripts/`**: Todos los scripts de R numerados en orden de ejecución.
* **`/03_results/`**: Donde se guardan todos los productos del análisis, incluyendo los modelos (`/models`), las gráficas (`/graphics`) y los archivos CSV finales.
* **`/visor_html/`**: Contiene el visualizador interactivo `Gis_Cesium.html` y el archivo de datos `EVC_master_dataset_final.csv`.

---
## Resultados

El análisis confirma una tendencia de calentamiento global generalizada, pero demuestra que la magnitud de este cambio varía significativamente según la zona climática preindustrial de origen.

* **Mapa de Clústeres**: (`mapa_clusters_preindustrial.png`) Muestra las 36 zonas climáticas identificadas en el periodo 1850-1900.
* **Gráfico de Evolución PCA**: (`pca_pc1_timeseries_by_cluster.png`) Visualiza el patrón de cambio dominante para cada clúster,
              evidenciando una aceleración del calentamiento post-1970, especialmente pronunciada en clústeres de latitudes altas (amplificación ártica).

---
## Visualizador Interactivo

Para una exploración interactiva de los resultados, abre el archivo `Gis_Cesium.html` (ubicado en la carpeta `/visor_html/`) en un navegador web.
Se recomienda usar un servidor local.

El visor permite:
* Visualizar los puntos de datos coloreados por clúster SOM o por la magnitud de sus patrones PCA.
* Cambiar entre diferentes modos de variabilidad (PC_1, PC_2, etc.).
* Hacer clic en cualquier punto del globo para ver un gráfico de su serie de tiempo de temperatura decenal.


