# ============================================================
# CSV DATA EXPLORER
# R Programming Mini Project - Lists and CSV Operations
# Framework: Shiny
# ============================================================

library(shiny)
library(DT)

# --------------------------- UI ------------------------------

ui <- fluidPage(
  tags$head(
    tags$title("CSV Data Explorer"),
    tags$style(HTML("
      body { background:#f4f5fb; color:#20233a; font-family:'Segoe UI',Arial,sans-serif; }
      .hero { background:linear-gradient(120deg,#5145cd,#7c3aed); color:white;
              padding:25px; border-radius:14px; margin:15px 0 22px; }
      .hero h2 { margin-top:0; font-weight:700; }
      .card { background:white; padding:20px; border-radius:13px; margin-bottom:18px;
              box-shadow:0 4px 16px rgba(32,35,58,.06); }
      .metric { background:white; border-left:5px solid #6366f1; padding:16px;
                border-radius:12px; margin-bottom:18px; box-shadow:0 4px 16px rgba(0,0,0,.04); }
      .metric-label { color:#71758a; font-size:12px; font-weight:700; text-transform:uppercase; }
      .metric-value { color:#5145cd; font-size:28px; font-weight:700; margin-top:6px; }
      .section-title { color:#5145cd; font-weight:700; }
      .btn-primary { background:#5145cd; border-color:#5145cd; }
      .btn-primary:hover { background:#4036a8; border-color:#4036a8; }
      .small-note { color:#71758a; font-size:13px; }
    "))
  ),

  div(class = "hero",
      h2("CSV Data Explorer"),
      p("Upload, explore, search, modify and analyze CSV datasets."),
      p("Built with R Programming and Shiny")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      div(class = "card",
          h4(class = "section-title", "Dataset Controls"),
          fileInput("file", "Upload CSV file", accept = ".csv"),
          actionButton("sample", "Load Sample Dataset", class = "btn-primary"),
          tags$hr(),
          textInput("search", "Search all columns", placeholder = "Enter a keyword"),
          tags$hr(),
          h4(class = "section-title", "List Indexing"),
          uiOutput("column_select"),
          numericInput("element_index", "Element index (starts at 1)", value = 1, min = 1),
          actionButton("inspect", "Access List Element", class = "btn-primary"),
          tags$hr(),
          downloadButton("download", "Download Modified CSV")
      )
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        id = "tabs",

        tabPanel("Dashboard",
          br(),
          fluidRow(
            column(3, div(class="metric", div(class="metric-label","Total Rows"),
                          div(class="metric-value", textOutput("rows", inline=TRUE)))),
            column(3, div(class="metric", div(class="metric-label","Total Columns"),
                          div(class="metric-value", textOutput("cols", inline=TRUE)))),
            column(3, div(class="metric", div(class="metric-label","Numeric Columns"),
                          div(class="metric-value", textOutput("numeric_cols", inline=TRUE)))),
            column(3, div(class="metric", div(class="metric-label","Missing Values"),
                          div(class="metric-value", textOutput("missing", inline=TRUE)))
            )
          ),
          div(class="card", h4(class="section-title","Dataset Overview"),
              verbatimTextOutput("overview")),
          div(class="card", h4(class="section-title","Numeric Column Summary"),
              DTOutput("numeric_summary"))
        ),

        tabPanel("Explore Data",
          br(),
          div(class="card", h4(class="section-title","Dataset Records"),
              p(class="small-note","Use the search box in the sidebar to filter rows."),
              DTOutput("table"))
        ),

        tabPanel("R List View",
          br(),
          div(class="card", h4(class="section-title","CSV converted to an R list"),
              p("This uses as.list() to convert each data-frame column into a named list component."),
              verbatimTextOutput("list_view")),
          div(class="card", h4(class="section-title","Access List Component"),
              verbatimTextOutput("element_result"))
        ),

        tabPanel("Modify Data",
          br(),
          div(class="card",
              h4(class="section-title","Modify an Existing Value"),
              p(class="small-note","Choose a column and row index, then enter the replacement value."),
              uiOutput("modify_column_select"),
              numericInput("modify_row", "Row index (starts at 1)", value=1, min=1),
              textInput("modify_value", "New value"),
              actionButton("modify", "Update Value", class="btn-primary"),
              tags$hr(),
              h4(class="section-title","Append a Value to a List Column"),
              p(class="small-note","Appends a value to one selected column. Other columns in the new row are filled with NA."),
              uiOutput("append_column_select"),
              textInput("append_value", "Value to append"),
              actionButton("append", "Append Value", class="btn-primary"),
              tags$hr(),
              verbatimTextOutput("operation_message")
          )
        ),

        tabPanel("Statistics",
          br(),
          div(class="card", h4(class="section-title","Column Information"),
              DTOutput("column_info")),
          div(class="card", h4(class="section-title","Summary Statistics"),
              verbatimTextOutput("summary"))
        )
      )
    )
  ),

  tags$footer(
    style="text-align:center;color:#71758a;padding:20px;",
    "CSV Data Explorer | R Programming Mini Project"
  )
)

# -------------------------- SERVER ---------------------------

server <- function(input, output, session) {

  # Read the sample CSV relative to the app folder.
  sample_path <- file.path("data", "sample.csv")
  initial_data <- if (file.exists(sample_path)) {
    read.csv(sample_path, stringsAsFactors = FALSE, check.names = FALSE)
  } else {
    data.frame(
      names = c("John", "Emily", "Michael", "Sara"),
      ages = c(35, 28, 42, 32),
      stringsAsFactors = FALSE
    )
  }

  dataset <- reactiveVal(initial_data)
  operation_message <- reactiveVal("Load a dataset to begin.")
  element_result <- reactiveVal("Choose a column and index, then click Access List Element.")

  observeEvent(input$sample, {
    if (file.exists(sample_path)) {
      dataset(read.csv(sample_path, stringsAsFactors = FALSE, check.names = FALSE))
    } else {
      dataset(initial_data)
    }
    operation_message("Sample dataset loaded successfully.")
    element_result("Choose a column and index, then click Access List Element.")
    showNotification("Sample dataset loaded.", type = "message")
  })

  observeEvent(input$file, {
    req(input$file)
    tryCatch({
      new_data <- read.csv(input$file$datapath,
                           stringsAsFactors = FALSE,
                           check.names = FALSE)
      validate(need(ncol(new_data) > 0, "The CSV file has no columns."))
      dataset(new_data)
      operation_message("CSV file uploaded successfully.")
      element_result("Choose a column and index, then click Access List Element.")
      showNotification("CSV file uploaded successfully.", type = "message")
    }, error = function(e) {
      showNotification(paste("Could not read CSV:", conditionMessage(e)),
                       type = "error", duration = NULL)
    })
  })

  current_data <- reactive({
    req(dataset())
    dataset()
  })

  filtered_data <- reactive({
    d <- current_data()
    keyword <- trimws(if (is.null(input$search)) "" else input$search)
    if (!nzchar(keyword)) return(d)
    matches <- apply(d, 1, function(row) {
      any(grepl(keyword, as.character(row), ignore.case = TRUE, fixed = TRUE))
    })
    d[matches, , drop = FALSE]
  })

  output$rows <- renderText(nrow(current_data()))
  # PDF concept: length(data) returns the number of columns in an R data frame.
  output$cols <- renderText(length(current_data()))
  output$numeric_cols <- renderText(sum(vapply(current_data(), is.numeric, logical(1))))
  output$missing <- renderText(sum(is.na(current_data())))

  output$overview <- renderPrint({
    d <- current_data()
    cat("DATASET INFORMATION\n")
    cat("------------------------------\n")
    cat("Number of rows:", nrow(d), "\n")
    cat("Number of columns:", length(d), "\n\n")
    cat("Column names:\n")
    print(names(d))
    cat("\nData structure:\n")
    str(d)
  })

  output$table <- renderDT({
    datatable(filtered_data(), rownames = FALSE,
              options = list(pageLength = 8, scrollX = TRUE))
  })

  output$list_view <- renderPrint({
    # PDF concept: convert data frame columns into a list.
    result <- as.list(current_data())
    print(result)
  })

  output$column_select <- renderUI({
    selectInput("selected_column", "Choose a column",
                choices = names(current_data()))
  })

  output$modify_column_select <- renderUI({
    selectInput("modify_column", "Column to modify",
                choices = names(current_data()))
  })

  output$append_column_select <- renderUI({
    selectInput("append_column", "Column to append to",
                choices = names(current_data()))
  })

  observeEvent(input$inspect, {
    d <- current_data()
    col <- input$selected_column
    idx <- input$element_index

    if (is.null(col) || !col %in% names(d)) {
      element_result("Please select a valid column.")
    } else if (length(idx) != 1 || is.na(idx) || idx < 1 ||
               idx != floor(idx) || idx > length(d[[col]])) {
      element_result(paste("Index out of range. Valid range: 1 to",
                           length(d[[col]])))
    } else {
      list_data <- as.list(d)
      element_result(paste0(
        "List component: ", col,
        "\nIndex: ", idx,
        "\nValue: ", as.character(list_data[[col]][idx])
      ))
    }
  })

  output$element_result <- renderText(element_result())

  observeEvent(input$modify, {
    d <- current_data()
    col <- input$modify_column
    row <- input$modify_row
    value <- input$modify_value

    if (is.null(col) || !col %in% names(d)) {
      operation_message("Please select a valid column.")
      return()
    }
    if (length(row) != 1 || is.na(row) || row < 1 ||
        row != floor(row) || row > nrow(d)) {
      operation_message("Invalid row index.")
      return()
    }
    if (is.null(value) || !nzchar(value)) {
      operation_message("Please enter a new value.")
      return()
    }

    # List conversion and indexed modification, matching the lab concepts.
    data_list <- as.list(d)
    old_column <- data_list[[col]]
    if (is.numeric(old_column)) {
      converted <- suppressWarnings(as.numeric(value))
      if (!is.na(converted)) value <- converted
    }
    data_list[[col]][row] <- value
    updated <- as.data.frame(data_list, stringsAsFactors = FALSE,
                             optional = TRUE, check.names = FALSE)
    names(updated) <- names(d)
    dataset(updated)
    operation_message(paste("Updated", col, "at row", row, "to", value))
  })

  observeEvent(input$append, {
    d <- current_data()
    col <- input$append_column
    value <- input$append_value

    if (is.null(col) || !col %in% names(d)) {
      operation_message("Please select a valid column.")
      return()
    }
    if (is.null(value) || !nzchar(value)) {
      operation_message("Please enter a value to append.")
      return()
    }

    data_list <- as.list(d)
    old_column <- data_list[[col]]
    if (is.numeric(old_column)) {
      converted <- suppressWarnings(as.numeric(value))
      if (!is.na(converted)) value <- converted
    }
    data_list[[col]] <- c(data_list[[col]], value)

    # Rebuild a rectangular data frame; shorter columns are padded with NA.
    max_length <- max(vapply(data_list, length, integer(1)))
    data_list <- lapply(data_list, function(x) {
      length(x) <- max_length
      x
    })
    updated <- as.data.frame(data_list, stringsAsFactors = FALSE,
                             optional = TRUE, check.names = FALSE)
    names(updated) <- names(d)
    dataset(updated)
    operation_message(paste("Appended value", value, "to column", col,
                            "- dataset now has", nrow(updated), "rows."))
    updateTextInput(session, "append_value", value = "")
  })

  output$operation_message <- renderText(operation_message())

  output$numeric_summary <- renderDT({
    d <- current_data()
    numeric_names <- names(d)[vapply(d, is.numeric, logical(1))]
    if (length(numeric_names) == 0) {
      return(datatable(data.frame(Message = "No numeric columns available."),
                       rownames = FALSE))
    }
    stats <- do.call(rbind, lapply(numeric_names, function(nm) {
      x <- d[[nm]]
      data.frame(
        Column = nm,
        Minimum = if (all(is.na(x))) NA else min(x, na.rm = TRUE),
        Maximum = if (all(is.na(x))) NA else max(x, na.rm = TRUE),
        Mean = if (all(is.na(x))) NA else round(mean(x, na.rm = TRUE), 2)
      )
    }))
    datatable(stats, rownames = FALSE, options = list(dom = "t", scrollX = TRUE))
  })

  output$column_info <- renderDT({
    d <- current_data()
    info <- data.frame(
      Column = names(d),
      Data_Type = vapply(d, function(x) paste(class(x), collapse = ", "), character(1)),
      Non_Missing = vapply(d, function(x) sum(!is.na(x)), integer(1)),
      Missing = vapply(d, function(x) sum(is.na(x)), integer(1)),
      stringsAsFactors = FALSE
    )
    datatable(info, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE))
  })

  output$summary <- renderPrint(summary(current_data()))

  output$download <- downloadHandler(
    filename = function() paste0("modified_dataset_", Sys.Date(), ".csv"),
    content = function(file) {
      write.csv(current_data(), file, row.names = FALSE, na = "")
    }
  )
}

shinyApp(ui = ui, server = server)
