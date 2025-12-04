
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chatR

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/chatR?color=orange)](https://cran.r-project.org/package=chatR)
[![](https://img.shields.io/badge/devel%20version-0.1.0-blue.svg)](https://github.com/jbryer/chatR)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

This repository is a Retrieval-Augmented Generation (RAG) chat bot
written in R Shiny.

### Installation

Download and install Ollama for your operation system:
<https://ollama.com>

We can call `ping_ollama()` to confirm that it is running and available.

``` r
rollama::ping_ollama() # Make sure Ollam is running
#> ▶ Ollama (v0.12.10) is running at <http://localhost:11434>!
```

You can get a list of available models at <https://ollama.com/library>.

``` r
model <- 'llama3.1'
rollama::pull_model(model = model)
#> ✔ model llama3.1 () pulled succesfully
```

### Development

``` r
usethis::use_tidy_description()
devtools::document()
devtools::install()
devtools::check(cran = TRUE)
```
