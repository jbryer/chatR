library(ragnar)
library(ellmer)
library(rollama)

# Need to install https://ollama.com

# Set this vector to the list of URLs you want to include in the knowledge store.
# All links within the same site will also be included so it is best to set this
# to just the homepage.
website_urls <- c(
	'https://drive.google.com/uc?export=download&id=1--811-yIIvjT3dvnyFJM20rj_-tbB3bg',
	'https://github.com/jbryer/DATA606Fall2020/blob/master/Textbook/os4.pdf?raw=true',
	'https://www.cs.ucdavis.edu/~matloff/matloff/public_html/ProbStatBook.pdf',
	'https://learningstatisticswithr.com/book/',
	'https://r4ds.hadley.nz',
	'https://adv-r.hadley.nz',
	'https://r-pkgs.org',
	'https://ggplot2-book.org',
	'https://mastering-shiny.org',
	'https://openintro-ims.netlify.app',
	'https://moderndive.com',
	'https://quarto.org',
	'https://bookdown.org/yihui/rmarkdown/',
	'https://cran.r-project.org/doc/manuals/r-release/R-intro.html'
)

store_location <- 'data/ragner_ollama.duckdb'
chunks_location <- 'data-raw/page_chunks.rds'
model <- 'llama3.1'

rollama::ping_ollama() # Make sure Ollam is running
# List of models available here: https://ollama.com/library
rollama::pull_model(model = model)
model_info <- rollama::show_model(model = model)

store <- NULL
if(file.exists(store_location)) {
	store <- ragnar_store_connect(
		store_location,
		read_only = FALSE
	)
} else {
	store <- ragnar_store_create(
		store_location,
		embed = \(x) ragnar::embed_ollama(x, model = 'llama3.1')
	)
}

if(file.exists(chunks_location)) {
	page_chunks <- readRDS(chunks_location)
} else {
	# This will get a list of all links within the pages provided
	pages <- sapply(website_urls, ragnar::ragnar_find_links)
	pages <- unlist(pages) |> unname()

	# Download pages and convert to markdown
	page_chunks <- list()
	pb <- txtProgressBar(min = 0, max = length(pages), style = 3)
	for(i in 1:length(pages)) {
		setTxtProgressBar(pb, i)
		page_chunks[[i]] <- pages[i] |> read_as_markdown() |> markdown_chunk()
	}
	close(pb)

	# Save the page chunks as an intermediate file
	saveRDS(page_chunks, file = chunks_location)
}

# Insert the pages into the knowledge store database
pb <- txtProgressBar(min = 0, max = length(page_chunks), style = 3)
for(i in 1:length(page_chunks)) {
	setTxtProgressBar(pb, i)
	ragnar_store_insert(store, page_chunks[[i]])
}
close(pb)

# Build the index
store <- ragnar_store_build_index(store)

##### Some testing #################################################################################
# We can retrieve and inspect the knowledge store
ragnar_retrieve(store, 'bar plots in ggplot2')
ragnar::ragnar_store_inspect(store)

# response <- httr::HEAD(website_urls[2])
# content_type <- httr::headers(response)[["content-type"]]
# print(content_type)

# Generate a list of references
# for(i in seq_len(length(website_urls))) {
for(i in 4:length(website_urls)) {
	title <- rvest::read_html(website_urls[i]) |>
		rvest::html_node("title") |>
		rvest::html_text()
	paste0('* [', title, '](', website_urls[i], ')\n') |> cat()
}

chat <- ellmer::chat_ollama(system_prompt = system_prompt, model = model)
ragnar_register_tool_retrieve(chat, store)
chat$chat('How do I subset columns from a data frame?')
