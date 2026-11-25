preparar_particion <- function(ajuste, evaluacion) {
  categoricas <- names(ajuste)[vapply(ajuste, is.character, logical(1))]
  numericas <- setdiff(names(ajuste)[vapply(ajuste, is.numeric, logical(1))], "Premium_Amount")
  for (variable in numericas) {
    referencia <- median(ajuste[[variable]], na.rm = TRUE)
    ajuste[[variable]][is.na(ajuste[[variable]])] <- referencia
    evaluacion[[variable]][is.na(evaluacion[[variable]])] <- referencia
  }
  for (variable in categoricas) {
    frecuencias <- table(ajuste[[variable]])
    referencia <- if (variable == "Occupation") "No especificado" else names(which.max(frecuencias))
    ajuste[[variable]][is.na(ajuste[[variable]])] <- referencia
    niveles <- sort(unique(ajuste[[variable]]))
    nuevos <- is.na(evaluacion[[variable]]) | !evaluacion[[variable]] %in% niveles
    evaluacion[[variable]][nuevos] <- if (referencia %in% niveles) referencia else names(which.max(frecuencias))
    ajuste[[variable]] <- factor(ajuste[[variable]], levels = niveles)
    evaluacion[[variable]] <- factor(evaluacion[[variable]], levels = niveles)
  }
  stopifnot(!anyNA(ajuste), !anyNA(evaluacion))
  list(ajuste = ajuste, evaluacion = evaluacion)
}

validar_modelos <- function(datos, pliegues) {
  formula <- Premium_Amount ~ .
  candidatos <- c("Nulo", "Simple (Annual Income)", "Completo",
                   "Seleccionado (BIC)", "Seleccionado (AIC)")
  resultados <- lapply(sort(unique(pliegues)), function(pliegue) {
    particion <- preparar_particion(datos[pliegues != pliegue, ], datos[pliegues == pliegue, ])
    x <- model.matrix(formula, particion$ajuste)
    grupos <- split(seq_len(ncol(x)), attr(x, "assign"))
    y <- particion$ajuste$Premium_Amount
    n <- length(y)
    escala <- sqrt(colMeans(x^2))
    x <- sweep(x, 2, escala, "/")
    xx <- crossprod(x)
    xy <- drop(crossprod(x, y))
    yy <- sum(y^2)
    rm(x)
    invisible(gc())

    ajustar <- function(terminos) {
      columnas <- unlist(grupos[c("0", terminos)], use.names = FALSE)
      coeficientes <- solve(xx[columnas, columnas, drop = FALSE], xy[columnas])
      list(columnas = columnas, coeficientes = coeficientes,
           sse = yy - sum(coeficientes * xy[columnas]))
    }

    elegir <- function(penalizacion) {
      terminos <- character()
      disponibles <- setdiff(names(grupos), "0")
      criterio <- function(seleccion) {
        modelo <- ajustar(seleccion)
        n * log(modelo$sse / n) + penalizacion * length(modelo$columnas)
      }
      actual <- criterio(terminos)
      repeat {
        vecinos <- c(lapply(terminos, function(t) setdiff(terminos, t)),
                     lapply(setdiff(disponibles, terminos), function(t) c(terminos, t)))
        valores <- vapply(vecinos, criterio, numeric(1))
        mejor <- which.min(valores)
        if (valores[mejor] >= actual - 1e-7) break
        terminos <- vecinos[[mejor]]
        actual <- valores[mejor]
      }
      terminos
    }

    nombres <- attr(terms(formula, data = particion$ajuste), "term.labels")
    simple <- as.character(match("Annual_Income", nombres))
    selecciones <- list(character(), simple, setdiff(names(grupos), "0"),
                        elegir(log(n)), elegir(2))
    validacion <- model.matrix(formula, particion$evaluacion)
    observados <- particion$evaluacion$Premium_Amount
    base <- sum((observados - mean(y))^2)
    metricas <- lapply(selecciones, function(terminos) {
      modelo <- ajustar(terminos)
      pred <- drop(validacion[, modelo$columnas, drop = FALSE] %*%
                     (modelo$coeficientes / escala[modelo$columnas]))
      error <- observados - pred
      c(n = length(error), sse = sum(error^2), sae = sum(abs(error)), referencia = base)
    })
    data.frame(Modelo = candidatos, do.call(rbind, metricas))
  })
  totales <- Reduce(function(a, b) {
    a[-1] <- a[-1] + b[-1]
    a
  }, resultados)
  data.frame(Modelo = totales$Modelo,
             RMSE = sqrt(totales$sse / totales$n),
             MAE = totales$sae / totales$n,
             R2 = 1 - totales$sse / totales$referencia)
}
