library(shiny)
library(tibble)
library(DBI)
library(RPostgres)

# -----------------------------
# Question data
# -----------------------------
questions <- tribble(
  ~id, ~question, ~option1, ~option2, ~option3, ~option4, ~answer,
  1, "What color is the sky on a clear day?", "Blue", "Green", "Red", "Yellow", "Blue",
  2, "How many days are in a week?", "5", "6", "7", "8", "7",
  3, "Which animal says 'meow'?", "Dog", "Cat", "Cow", "Bird", "Cat",
  4, "What is the opposite of hot?", "Warm", "Cold", "Dry", "Soft", "Cold",
  5, "Which season comes after spring?", "Winter", "Autumn", "Summer", "Rainy", "Summer"
)

# -----------------------------
# Database connection
# -----------------------------
get_db_connection <- function() {
  DBI::dbConnect(
    drv = RPostgres::Postgres(),
    host = Sys.getenv("SUPABASE_DB_HOST"),
    port = as.integer(Sys.getenv("SUPABASE_DB_PORT")),
    dbname = Sys.getenv("SUPABASE_DB_NAME"),
    user = Sys.getenv("SUPABASE_DB_USER"),
    password = Sys.getenv("SUPABASE_DB_PASSWORD"),
    sslmode = Sys.getenv("SUPABASE_DB_SSLMODE", "require")
  )
}

save_response <- function(row_df) {
  con <- NULL
  tryCatch({
    con <- get_db_connection()

    DBI::dbWriteTable(
      conn = con,
      name = "quiz_responses",
      value = as.data.frame(row_df),
      append = TRUE,
      row.names = FALSE
    )

    list(success = TRUE, message = "Saved")
  }, error = function(e) {
    list(success = FALSE, message = e$message)
  }, finally = {
    if (!is.null(con)) DBI::dbDisconnect(con)
  })
}

# -----------------------------
# UI
# -----------------------------
ui <- fluidPage(
  titlePanel("A/B Quiz App"),
  uiOutput("main_ui")
)

# -----------------------------
# Server
# -----------------------------
server <- function(input, output, session) {

  user_id <- paste0(as.integer(Sys.time()), "_", sample(10000:99999, 1))
  start_time <- Sys.time()
  group <- sample(c("A", "B"), 1)

  rv <- reactiveValues(
    submitted_quiz = FALSE,
    score = 0,
    submit_time = NA,
    duration_sec = NA,

    # Version B
    current_question = 1,
    b_score = 0,
    b_answers = rep(NA_character_, 5),
    show_feedback = FALSE,
    feedback_text = NULL,
    feedback_color = NULL,
    answer_submitted = FALSE
  )

  # -----------------------------
  # Main UI
  # -----------------------------
  output$main_ui <- renderUI({

    if (group == "A") {

      tagList(
        h3("Version A"),
        p("Please answer all 5 questions and click submit at the end."),

        radioButtons(
          "q1", questions$question[1],
          choices = c(
            questions$option1[1], questions$option2[1],
            questions$option3[1], questions$option4[1]
          ),
          selected = character(0)
        ),

        radioButtons(
          "q2", questions$question[2],
          choices = c(
            questions$option1[2], questions$option2[2],
            questions$option3[2], questions$option4[2]
          ),
          selected = character(0)
        ),

        radioButtons(
          "q3", questions$question[3],
          choices = c(
            questions$option1[3], questions$option2[3],
            questions$option3[3], questions$option4[3]
          ),
          selected = character(0)
        ),

        radioButtons(
          "q4", questions$question[4],
          choices = c(
            questions$option1[4], questions$option2[4],
            questions$option3[4], questions$option4[4]
          ),
          selected = character(0)
        ),

        radioButtons(
          "q5", questions$question[5],
          choices = c(
            questions$option1[5], questions$option2[5],
            questions$option3[5], questions$option4[5]
          ),
          selected = character(0)
        ),

        actionButton("submit_quiz_a", "Submit Quiz")
      )

    } else {

      q_num <- rv$current_question

      if (q_num <= nrow(questions)) {
        choices_current <- c(
          questions$option1[q_num],
          questions$option2[q_num],
          questions$option3[q_num],
          questions$option4[q_num]
        )

        tagList(
          h3("Version B"),
          div(
            style = "background-color:#f7f7f7; padding:15px; border-radius:8px; margin-bottom:15px;",
            h4("Instructions"),
            tags$ol(
              tags$li("You will answer one question at a time."),
              tags$li("After each submission, you will immediately see whether your answer is correct."),
              tags$li("Then you can move on to the next question.")
            )
          ),

          h4(paste("Question", q_num, "of", nrow(questions))),
          p(style = "font-size:18px; font-weight:600;", questions$question[q_num]),

          radioButtons(
            inputId = "b_answer",
            label = NULL,
            choices = choices_current,
            selected = character(0)
          ),

          if (rv$show_feedback) {
            div(
              style = paste0(
                "font-weight:bold; margin-top:10px; margin-bottom:12px; color:",
                rv$feedback_color, ";"
              ),
              rv$feedback_text
            )
          },

          if (!rv$show_feedback) {
            actionButton("submit_question_b", "Submit Answer")
          } else {
            actionButton("next_question_b", "Next Question")
          }
        )
      } else {
        tagList(
          h3("Version B"),
          h4("You have completed all questions."),
          p(paste("Your current score is", rv$b_score, "out of", nrow(questions), ".")),
          actionButton("finish_b", "Finish Quiz")
        )
      }
    }
  })

  # -----------------------------
  # Version A: submit all at once
  # -----------------------------
  observeEvent(input$submit_quiz_a, {
    req(input$q1, input$q2, input$q3, input$q4, input$q5)

    answers <- c(input$q1, input$q2, input$q3, input$q4, input$q5)
    correct_answers <- questions$answer
    score <- sum(answers == correct_answers)

    submit_time <- Sys.time()
    duration_sec <- as.numeric(difftime(submit_time, start_time, units = "secs"))

    rv$submitted_quiz <- TRUE
    rv$score <- score
    rv$submit_time <- submit_time
    rv$duration_sec <- duration_sec

    showModal(
      modalDialog(
        title = "Short Feedback",
        p(paste("Your score is", score, "out of 5.")),
        sliderInput("satisfaction", "Overall satisfaction", min = 1, max = 5, value = 3),
        sliderInput("ease_of_use", "How easy was the app to use?", min = 1, max = 5, value = 3),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("submit_feedback_a", "Submit Feedback")
        ),
        easyClose = FALSE
      )
    )
  })

  observeEvent(input$submit_feedback_a, {
    req(rv$submitted_quiz)
    req(input$satisfaction, input$ease_of_use)

    row_df <- tibble(
      user_id = user_id,
      group_name = group,
      start_time = as.character(start_time),
      submit_time = as.character(rv$submit_time),
      duration_sec = rv$duration_sec,
      score = as.integer(rv$score),
      completed = 1L,
      satisfaction = as.integer(input$satisfaction),
      ease_of_use = as.integer(input$ease_of_use),
      q1 = input$q1,
      q2 = input$q2,
      q3 = input$q3,
      q4 = input$q4,
      q5 = input$q5
    )

    res <- save_response(row_df)

    removeModal()

    if (res$success) {
      showModal(
        modalDialog(
          title = "Thank you!",
          "Your response has been recorded successfully.",
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
    } else {
      showModal(
        modalDialog(
          title = "Save failed",
          paste("Database error:", res$message),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
    }
  })

  # -----------------------------
  # Version B: one question at a time
  # -----------------------------
  observeEvent(input$submit_question_b, {
    req(group == "B")
    req(rv$current_question <= nrow(questions))
    req(input$b_answer)

    if (rv$answer_submitted) {
      return()
    }

    q_num <- rv$current_question
    correct_answer <- questions$answer[q_num]

    rv$b_answers[q_num] <- input$b_answer

    if (input$b_answer == correct_answer) {
      rv$b_score <- rv$b_score + 1
      rv$feedback_text <- "Correct!"
      rv$feedback_color <- "green"
    } else {
      rv$feedback_text <- paste("Incorrect. The correct answer is:", correct_answer)
      rv$feedback_color <- "red"
    }

    rv$show_feedback <- TRUE
    rv$answer_submitted <- TRUE
  })

  observeEvent(input$next_question_b, {
    req(group == "B")
    req(rv$show_feedback)

    rv$current_question <- rv$current_question + 1
    rv$show_feedback <- FALSE
    rv$feedback_text <- NULL
    rv$feedback_color <- NULL
    rv$answer_submitted <- FALSE
  })

  observeEvent(input$finish_b, {
    req(group == "B")

    submit_time <- Sys.time()
    duration_sec <- as.numeric(difftime(submit_time, start_time, units = "secs"))

    rv$submitted_quiz <- TRUE
    rv$score <- rv$b_score
    rv$submit_time <- submit_time
    rv$duration_sec <- duration_sec

    showModal(
      modalDialog(
        title = "Short Feedback",
        p(paste("Your score is", rv$b_score, "out of 5.")),
        sliderInput("satisfaction_b", "Overall satisfaction", min = 1, max = 5, value = 3),
        sliderInput("ease_of_use_b", "How easy was the app to use?", min = 1, max = 5, value = 3),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("submit_feedback_b", "Submit Feedback")
        ),
        easyClose = FALSE
      )
    )
  })

  observeEvent(input$submit_feedback_b, {
    req(group == "B")
    req(rv$submitted_quiz)
    req(input$satisfaction_b, input$ease_of_use_b)

    row_df <- tibble(
      user_id = user_id,
      group_name = group,
      start_time = as.character(start_time),
      submit_time = as.character(rv$submit_time),
      duration_sec = rv$duration_sec,
      score = as.integer(rv$score),
      completed = 1L,
      satisfaction = as.integer(input$satisfaction_b),
      ease_of_use = as.integer(input$ease_of_use_b),
      q1 = rv$b_answers[1],
      q2 = rv$b_answers[2],
      q3 = rv$b_answers[3],
      q4 = rv$b_answers[4],
      q5 = rv$b_answers[5]
    )

    res <- save_response(row_df)

    removeModal()

    if (res$success) {
      showModal(
        modalDialog(
          title = "Thank you!",
          "Your response has been recorded successfully.",
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
    } else {
      showModal(
        modalDialog(
          title = "Save failed",
          paste("Database error:", res$message),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
    }
  })
}

# -----------------------------
# Run app
# -----------------------------
shinyApp(ui = ui, server = server)