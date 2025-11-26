
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chatR

<!-- badges: start -->

<!-- badges: end -->

This repository is a Retrieval-Augmented Generation (RAG) chat bot
written in R Shiny.

### Installation

Download and install Ollama for your operation system:
<https://ollama.com>

We can call `ping_ollama()` to confirm that it is running and available.

``` r
rollama::ping_ollama() # Make sure Ollam is running
#> ▶ Ollama (v0.11.5) is running at <http://localhost:11434>!
```

You can get a list of available models at <https://ollama.com/library>.

``` r
model <- 'llama3.1'
rollama::pull_model(model = model)
#> ✔ model llama3.1 () pulled succesfully
```
