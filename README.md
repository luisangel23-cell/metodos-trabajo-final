# Análisis Estadístico del Dataset de Seguros

**Autores:** Fernando Cabrera y Keisy Polo

## Descripción

Este proyecto realiza un análisis estadístico completo sobre un conjunto de datos de pólizas de seguros, compuesto por 1,200,000 registros y 21 variables (demográficas, socioeconómicas, de salud y de comportamiento). El objetivo es comprender el comportamiento de estas variables y su posible relación con el monto de la prima de seguro (**Premium Amount**), la variable de interés principal del estudio.

El trabajo incluye:

- **Análisis Exploratorio de Datos (EDA):** limpieza e imputación de valores faltantes, caracterización univariada de variables numéricas y categóricas, análisis bivariado (variables independientes vs. Premium Amount) y análisis de independientes entre sí.
- **Pruebas de hipótesis paramétricas y no paramétricas:** verificación de supuestos (normalidad, homogeneidad de varianzas) y aplicación de pruebas como Wilcoxon, Kruskal-Wallis, correlación de Spearman y Chi-cuadrado, para confirmar estadísticamente los patrones observados en el EDA.

- **Regresión lineal múltiple:** partición previa a la imputación, validación cruzada en entrenamiento, comparación contra el promedio e inferencia con errores estándar robustos HC1.

El documento completo se genera como un libro con **bookdown**.

## Versión para presentación

El informe está disponible en [GitHub Pages](https://analisis-seguros-r.github.io/01-intro/).
GitHub Pages publica directamente la carpeta `docs/` de la rama `main`.
La configuración correspondiente está en **Settings → Pages → Deploy from a branch → main → /docs**.

## Cómo obtener el dataset

Por su tamaño (~170 MB), el archivo `train.csv` **no está incluido en este repositorio**. Para poder ejecutar el análisis, sigue estos pasos:

1. Descarga el dataset desde la competencia de Kaggle **"Playground Series - Season 4, Episode 12: Regression with an Insurance Dataset"**:
   👉 https://www.kaggle.com/competitions/playground-series-s4e12/data
   *(requiere una cuenta gratuita de Kaggle)*
2. Descarga el archivo `train.csv`.
3. Crea una carpeta llamada `data` en la raíz de este proyecto (si no existe) y coloca el archivo ahí, de modo que quede en la ruta:
   ```
   data/train.csv
   ```

## Estructura del repositorio

```
├── index.Rmd            # Página de introducción del libro
├── 01-intro.Rmd         # EDA, pruebas de hipótesis y regresión
├── evaluacion.R         # Imputación por partición y validación cruzada
├── analisis-seguros.Rproj # Proyecto de RStudio
├── _bookdown.yml        # Configuración de bookdown
├── _output.yml          # Configuración de salida (gitbook, PDF, etc.)
├── data/                # Carpeta local para el dataset (no versionada)
└── README.md
```

## Cómo ejecutar el proyecto

1. Clona este repositorio.
2. Abre el archivo `analisis-seguros.Rproj` en RStudio.
3. Descarga el dataset siguiendo las instrucciones de la sección anterior y colócalo en `data/train.csv`.
4. Para reproducir exactamente el entorno registrado, instala `renv` una sola vez y restaura las versiones bloqueadas:
   ```r
   install.packages("renv")
   renv::restore()
   ```

   Como alternativa, instala manualmente los paquetes de R necesarios:
   ```r
   install.packages(c(
     "bookdown", "tidyverse", "Amelia", "moments", "patchwork", "GGally",
     "car", "rstatix", "coin", "nortest", "data.table", "knitr", "kableExtra",
     "lmtest", "sandwich"
   ))
   ```
5. Compila el libro con:
   ```r
   bookdown::render_book("index.Rmd", "bookdown::gitbook")
   ```
   o usando el botón **Build Book** en el panel "Build" de RStudio.

   Si R se ejecuta fuera de RStudio en Windows, asegúrate de que Pandoc esté
   disponible. Con la instalación de RStudio usada en este equipo se puede hacer
   así antes de renderizar:
   ```r
   Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
   bookdown::render_book("index.Rmd", "bookdown::gitbook")
   ```

6. Copia el contenido generado de `_book/` a `docs/`, confirma los cambios y
   ejecuta `git push origin main`. GitHub Pages publicará el sitio estático desde `main:/docs`.

## Librerías principales utilizadas

`bookdown`, `tidyverse`, `data.table`, `ggplot2`, `GGally`, `car`, `rstatix`, `coin`, `nortest`, `moments`, `patchwork`, `knitr`, `kableExtra`.

El HTML generado incluye el resumen de prueba y los diagnósticos. GitHub Pages publica el HTML estático; la compilación con el CSV se hace localmente. La semilla externa es 123 y la de los pliegues es 124.
