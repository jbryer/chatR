library(shiny)
library(shinychat)
library(ragnar)
library(ellmer)
library(rollama)

source('config.R')

store <- ragnar_store_connect(
	store_location,
	read_only = FALSE
)

chat <- ellmer::chat_ollama(
	system_prompt = stringr::str_squish(system_prompt),
	model = model,
	echo = 'none'
)

chat <- ellmer::chat_openai(
	system_prompt = stringr::str_squish(system_prompt)
)

chat <- ellmer::chat_anthropic(
	system_prompt = stringr::str_squish(system_prompt)
)

ragnar_register_tool_retrieve(chat, store, top_k = 10, title = 'R and statistics knowledge store')

response <- chat$chat("How can I subset a data frame?")
# chat$chat_async("How can I subset a data frame?")
response

chat$chat('What is the central limit theorem?')


# chat <- ellmer::chat_openai(
# 	system_prompt = system_prompt,
# 	model = "gpt-4.1"
# )


