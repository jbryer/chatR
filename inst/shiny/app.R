library(chatR)

if(file.exists('../../R/shiny_server.R')) { # For local testing
	message('Running Shiny functions locally...')
	source('../../R/shiny_server.R')
	source('../../R/shiny_ui.R')
}

chatR_config <- new.env()

if(file.exists('config.R')) {
	source('config.R', chatR_config)
	# ls(chatR_config)
} else {
	stop('No configuration file found.')
}

ui <- chatR_ui
server <- chatR_server

environment(ui) <- chatR_config
environment(server) <- chatR_config

##### Run the application ######################################################
shiny::shinyApp(ui = ui, server = server)
