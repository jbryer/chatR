#' Run the chatR Shiny application
#'
#' @param config_file a configuratino file. If specified, all other parameters are ignored.
#' @import shiny
#' @export
run_chatR <- function(
		config_file,
		store_location = '',
		system_prompt = '',
		model = 'llama3.1',
		base_url = Sys.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
		history_dir = 'history',
		app_title = 'chatR'
) {
	# TODO: Would be nice to have some parameters in the file, others can be overwrittenx
	if(!missing(config_file)) {
		chatR_config <- new.env()
		source(config_file, chatR_config)
	} else {
		chatR_config <- list(
			store_location = store_location,
			system_prompt = system_prompt,
			model = model,
			base_url = base_url,
			history_dir = history_dir,
			app_title = app_title
		)
		chatR_config <- list2env(chatR_config)
	}

	ui <- chatR_ui
	server <- chatR_server

	environment(ui) <- chatR_config
	environment(server) <- chatR_config

	shinyApp(ui = ui, server = server)
}
