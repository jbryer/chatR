#' The Shiny server function for the custom chatbot.
#'
#' @param input Shiny input object.
#' @param outout Shiny output object.
#' @param session Shiny session object.
#' @export
#' @import shiny shinychat ragnar ellmer
#' @import bslib
#' @importFrom shinyjs hide show
#' @importFrom coro await_each async
chatR_server <- function(input, output, session) {
	required_login_params <- c('APP_ID', 'email_host', 'email_port', 'email_username',
							   'email_password', 'from_email')

	use_authentication <- reactiveVal()

	if(all(sapply(required_login_params, exists))) {
		USER <- login::login_server(
			id = APP_ID,
			db_conn = DBI::dbConnect(RSQLite::SQLite(), 'users.sqlite'),
			emailer = emayili_emailer(
				email_host = email_host,
				email_port = email_port,
				email_username = email_username,
				email_password = email_password,
				from_email = reset_password_from_email
			),
			additional_fields = c('first_name' = 'First Name',
								  'last_name' = 'Last Name'),
			new_account_subject = "Verify your new account",
			reset_password_subject = "Reset password",
			salt = 'login_demo'
		)
		use_authentication(TRUE)
	} else {
		USER <- reactiveValues(
			logged_in = TRUE,
			username = unname(Sys.info()['user'])
		)
		use_authentication(FALSE)
	}

	output$login_box <- renderUI({
		box <- NULL
		if(use_authentication()) {
			box <- div(id = 'login_box',
				tabsetPanel(
					id = 'login_panel',
					tabPanel('Login',
							 login::login_ui(id = APP_ID) ),
					tabPanel('Create Account',
							 login::new_user_ui(id = APP_ID) ),
					tabPanel('Reset Password',
							 login::reset_password_ui(id = APP_ID))
				)
			)
		}
		return(box)
	})

	output$logout_button <- renderUI({
		if(use_authentication()) {
			login::logout_button(APP_ID, style = "position: absolute; top: 5px; right: 5px; z-index:10000;")
		} else {
			NULL
		}
	})

	store <- ragnar::ragnar_store_connect(
		store_location,
		read_only = TRUE
	)

	chat <- ellmer::chat_ollama(
		model = model,
		echo = 'all',
		system_prompt = system_prompt,
		base_url = base_url
	)

	observeEvent(USER$logged_in, {
		if(USER$logged_in) {
			shinyjs::hide(id = 'login_box')
		} else {
			shinyjs::show(id = "login_box")
		}
	})

	output$is_logged_in <- renderText({
		USER$logged_in
	})

	output$username <- renderText({
		USER$username
	})

	output$name <- renderText({
		paste0(USER$first_name, ' ', USER$last_name)
	})

	output$chatbot <- renderUI({
		if(USER$logged_in) {
			shinychat::chat_ui(
				id = "chat",
				placeholder = "Enter your question..."
			)
		}
	})

	observeEvent(USER$logged_in, {
		if(USER$logged_in) {
			insertTab(
				inputId = 'tabs',
				tabPanel(
					title = 'History',
					uiOutput('chat_history')
					# htmlOutput('chat_history_text')
				),
				target = 'Chat'
			)
		} else {
			removeTab(inputId = 'tabs', target = 'History')
		}
	})

	history_file <- reactiveVal()
	question <- reactiveVal(NULL)
	history <- reactiveValues()

	if(!dir.exists(history_dir)) {
		message(paste0('Creating history directory: ', history_dir))
		dir.create(history_dir, recursive = TRUE)
	}

	observe({
		history_file(paste0(history_dir, '/', USER$username, '.rds'))
		if(file.exists(history_file())){
			tmp <- readRDS(history_file())
			for(i in seq_len(length(tmp))) {
				qid <- names(tmp)[i]
				history[[qid]] <- tmp[[i]]
			}
		}
	})

	observeEvent(input$chat_user_input, {
		timestamp <- Sys.time()
		qid <- rlang::hash(paste0(input$chat_user_input, timestamp))
		question(qid)
		history[[qid]] <- list(
			qid = qid,
			question = input$chat_user_input,
			timestamp = timestamp,
			answer = '')
		stream <- chat$stream_async(input$chat_user_input, tool_mode = 'sequential')
		stream_res <- coro::async(function() {
			for (chunk in coro::await_each(stream)) {
				if(!is.null(question())) {
					history[[question()]]$answer <- paste0(history[[question()]]$answer, chunk)
				}
				shinychat::chat_append_message('chat', list(role = 'assistant', content = chunk))
			}
		})()
		stream_res$then(function(value) {
			# print("Stream stopped.")
			shinychat::chat_append('chat', list(role = 'assistant', content = "end"))
			# shinychat::update_chat_user_input('chat', value = ' ', focus = TRUE)
			# shinychat::chat_clear('chat')
		})
	})

	observe({
		hist <- reactiveValuesToList(history)
		saveRDS(hist, file = history_file())
	})

	output$chat_history <- renderUI({
		hist <- reactiveValuesToList(history)
		ui <- list()
		for(i in rev(seq_len(length(hist)))) {
			ui[[length(ui) + 1]] <- shinyBS::bsCollapsePanel(
				title = paste(hist[[i]]$question, ' (', hist[[i]]$timestamp, ')'),
				value = hist[[i]]$qid,
				HTML(markdown::mark(hist[[i]]$answer))
			)
		}
		return(ui)
	})

	output$chat_history_text <- renderPrint({
		print(reactiveValuesToList(history))
	})
}
