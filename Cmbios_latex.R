archivo <- "01-intro.Rmd"

mu  <- "\u03bc"; eta <- "\u03b7"; rho <- "\u03c1"; chi <- "\u03c7"; cuad <- "\u00b2"
neq <- "\u2260"
sub0 <- "\u2080"; sub1 <- "\u2081"; sub2 <- "\u2082"; sub3 <- "\u2083"; sub4 <- "\u2084"
H0 <- paste0("H", sub0); H1 <- paste0("H", sub1)

N <- "-?[0-9]+(?:[.,][0-9]+)*(?:e[+-]?[0-9]+)?"

a_latex <- function(s) {
  s <- gsub(mu,  "\\mu",  s, fixed = TRUE)
  s <- gsub(eta, "\\eta", s, fixed = TRUE)
  s <- gsub(rho, "\\rho", s, fixed = TRUE)
  s <- gsub(neq, "\\neq", s, fixed = TRUE)
  s <- gsub(sub0, "_0", s, fixed = TRUE); s <- gsub(sub1, "_1", s, fixed = TRUE)
  s <- gsub(sub2, "_2", s, fixed = TRUE); s <- gsub(sub3, "_3", s, fixed = TRUE)
  s <- gsub(sub4, "_4", s, fixed = TRUE)
  s
}

procesa <- function(contenido) {
  m <- regmatches(contenido, regexec("^(.*?) \\((.*)\\)\\.?$", contenido, perl = TRUE))[[1]]
  if (length(m) == 3) { izq <- m[2]; com <- m[3] } else { izq <- sub("\\.$", "", contenido); com <- NULL }
  cuerpo <- if (grepl(paste0("^[", mu, eta, rho, "]"), izq)) a_latex(izq) else paste0("\\text{", izq, "}")
  if (!is.null(com)) cuerpo <- paste0(cuerpo, " \\quad \\text{(", com, ")}")
  cuerpo
}

bloque_hipotesis <- function(c0, c1) {
  if (grepl(paste0("^[", mu, eta, rho, "]"), c0)) {
    c("$$", "\\begin{aligned}",
      paste0("H_0 &: ", procesa(c0), " \\\\"),
      paste0("H_1 &: ", procesa(c1)),
      "\\end{aligned}", "$$")
  } else {
    c(paste0("$H_0$: ", c0), "", paste0("$H_1$: ", c1))
  }
}

lineas <- readLines(archivo, encoding = "UTF-8", warn = FALSE)

nuevas <- character(0)
i <- 1
en_codigo <- FALSE
while (i <= length(lineas)) {
  l <- lineas[i]
  if (grepl("^```", l)) { en_codigo <- !en_codigo; nuevas <- c(nuevas, l); i <- i + 1; next }
  if (!en_codigo && startsWith(l, paste0(H0, ": ")) && i < length(lineas) &&
      startsWith(lineas[i + 1], paste0(H1, ": "))) {
    c0 <- substring(l, nchar(H0) + 3)
    c1 <- substring(lineas[i + 1], nchar(H1) + 3)
    nuevas <- c(nuevas, bloque_hipotesis(c0, c1))
    i <- i + 2
    next
  }
  nuevas <- c(nuevas, l)
  i <- i + 1
}

en_codigo <- FALSE
for (k in seq_along(nuevas)) {
  l <- nuevas[k]
  if (grepl("^```", l)) { en_codigo <- !en_codigo; next }

  if (!en_codigo) {
    l <- gsub("\\\\chi\\^2\\((\\d+)\\)", "\\\\chi^2_{\\1}", l, perl = TRUE)
    l <- gsub(paste0(chi, cuad, "\\((\\d+)\\) = (", N, ")"), "$\\\\chi^2_{\\1} = \\2$", l, perl = TRUE)
    l <- gsub(paste0("F\\((\\d+)\\) = (", N, ")"), "$F_{\\1} = \\2$", l, perl = TRUE)
    l <- gsub(paste0("\\((D|W|S|U) = (", N, ")"), "($\\1 = \\2$", l, perl = TRUE)
    l <- gsub(paste0(eta, cuad, "\\[H\\] = (", N, ")"), "$\\\\eta^2_H = \\1$", l, perl = TRUE)
    l <- gsub(paste0(eta, cuad, "\\[H\\]"), "$\\\\eta^2_H$", l, perl = TRUE)
    l <- gsub(paste0("(?<![A-Za-z\\\\])(?:rho|", rho, ") = (", N, ")"), "$\\\\rho = \\1$", l, perl = TRUE)
    l <- gsub(paste0("(?<![A-Za-z\\\\])r = (", N, ")"), "$r = \\1$", l, perl = TRUE)
    l <- gsub(H0, "$H_0$", l, fixed = TRUE)
    l <- gsub(H1, "$H_1$", l, fixed = TRUE)
    for (s in c(mu, eta)) for (j in list(c(sub1, 1), c(sub2, 2), c(sub3, 3), c(sub4, 4))) {
      nombre <- if (s == mu) "\\mu" else "\\eta"
      l <- gsub(paste0(s, j[1]), paste0("$", nombre, "_", j[2], "$"), l, fixed = TRUE)
    }
    l <- gsub(rho, "$\\rho$", l, fixed = TRUE)
  }

  l <- gsub(paste0("p-valor \\$(<|=) (", N, ")\\$"), "p valor $\\1 \\2$", l, perl = TRUE)
  l <- gsub(paste0("p-valor (<|=) (", N, ")"), "p valor $\\1 \\2$", l, perl = TRUE)
  l <- gsub(paste0("p ajustado (<|=) (", N, ")"), "p ajustado $\\1 \\2$", l, perl = TRUE)
  l <- gsub("p-valor", "p valor", l, fixed = TRUE)

  nuevas[k] <- l
}

writeLines(nuevas, archivo, useBytes = TRUE)
cat("Listo. Revisa los cambios con git diff antes de hacer commit.\n")
