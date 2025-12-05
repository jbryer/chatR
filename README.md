
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chatR: Shiny Application for Retrival Augemented Generation Chatbot

<!-- badges: start -->

[![](https://img.shields.io/badge/devel%20version-0.1.0-blue.svg)](https://github.com/jbryer/chatR)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

This repository is a Retrieval-Augmented Generation (RAG) chat bot
written in R Shiny.

I gave a talk at the 2025 [CUNY IT
Conference](https://events.govtech.com/CUNY-IT-Conference.html#agenda)
titled *Creating a Custom AI Bot for Your Class*.

**Abstract**: AI chatbots have become a popular resource for students in
learning. However, the accuracy of answers given by AI is often
questionable. Retrieval-augmented generation (RAG) models are a way of
augmenting large language models with a curated set of resources. When
students interact with the chatbot, answers can (optionally) be
restricted to resources in the knowledge base along with direct
references and/or links. This talk will introduce a framework for
creating custom chatbots. Resources on how you can monitor the questions
and answers students ask will also be discussed.

[Click here for slides](inst/slides/chatR.pdf)

### Installation

You first need to install [R](https://cran.r-project.org). I also
recommend you install
[RStudio](https://posit.co/products/open-source/rstudio/?sid=1). The
following command will install the `chatR` package and all dependencies.

``` r
install.packages('pak')
pak::pkg_install('jbryer/chatR')
```

Download and install Ollama for your operation system:
<https://ollama.com>

We can call `ping_ollama()` to confirm that it is running and available.

``` r
rollama::ping_ollama() # Make sure Ollam is running
#> ▶ Ollama (v0.13.0) is running at <http://localhost:11434>!
```

You can get a list of available models at <https://ollama.com/library>.

``` r
model <- 'llama3.1'
rollama::pull_model(model = model)
#> ✔ model llama3.1 () pulled succesfully
```

You can download a prebuilt knowledge store of common R and statistics
resources (note this file is over 1gb in size).

``` r
if(!dir.exists('data-raw/')) { dir.create('data-raw/', recursive = TRUE) }
piggyback::pb_download(
    file = "ragner_ollama.duckdb", 
    dest = 'data-raw/',
    repo = "jbryer/chatR",
    tag = "v1.0.2")
```

We can run the application locally without needing to login.

``` r
chatR::run_chatR(
    store_location = 'data-raw/ragner_ollama.duckdb'
)
```

### Development

``` r
usethis::use_tidy_description()
devtools::document()
devtools::install()
devtools::check(cran = TRUE)
# Build PDF of the slide deck
pagedown::chrome_print('inst/slides/chatR.html', timeout = 120)
```

The [build_vector_store.R](data-raw/build_vector_store.R) script
contains the code to build the knowledge store database.

Uploading the knowledge store (DuckDB file) to Github.

``` r
library(piggyback)
tag <- 'v1.0.2'
pb_release_create(repo = "jbryer/chatR", tag = tag)
pb_upload("data-raw/ragner_ollama.duckdb", repo = "jbryer/chatR", tag = tag)
```
