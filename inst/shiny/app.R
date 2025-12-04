library(shiny)
library(login)
library(shinyjs)
library(ellmer)
library(ragnar)
library(shinychat)
library(shinyBS)

chatR_config <- new.env()

if(file.exists('config.R')) {
	source('config.R', chatR_config)
	# ls(chatR_config)
} else {
	stop('No configuration file found.')
}

ui <- chatR::chatR_ui
server <- chatR::chatR_server

environment(ui) <- chatR_config
environment(server) <- chatR_config

##### Run the application ######################################################
shinyApp(ui = ui, server = server)
