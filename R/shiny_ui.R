#' The Shiny UI for the custom chatbot.
#'
#' @return a [shiny::navbarPage()] object.
#' @export
#' @import shiny
#' @import bslib
#' @importFrom shinyjs useShinyjs
chatR_ui <- function() {
	navbarPage(
		title = app_title,
		id = 'tabs',
		tabPanel(
			title = 'Chat',
			shinyjs::useShinyjs(),
			uiOutput('login_box'),
			uiOutput('chatbot')
		),
		tabPanel(
			title = 'About',
			includeMarkdown(paste0(find.package('chatR'), '/shiny/about.md') )
		),
		uiOutput('logout_button')
	)
}
