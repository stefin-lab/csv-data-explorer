# CSV Data Explorer — R Programming Project

An interactive CSV management web application built with **R**, **Shiny**, and **DT**. The project demonstrates the list operations covered in the R Programming lab material.

## Features

- Load the included sample CSV or upload another CSV file.
- View and search dataset records.
- Convert a data frame into a named list using `as.list()`.
- Access list elements by column and index.
- Modify an existing value using list indexing.
- Append a value to a list column.
- Count rows, columns, numeric columns, and missing values.
- View column information and summary statistics.
- Download the current dataset as a CSV file.

## Project structure

```text
CSVDataExplorer/
├── app.R
├── README.md
└── data/
    └── sample.csv
```

## Requirements

- R (version 4.0 or newer recommended)
- R packages: `shiny` and `DT`

## Installation

Open R or RStudio and run:

```r
install.packages(c("shiny", "DT"))
```

## Run the application

Open the project folder as the working directory, then run:

```r
shiny::runApp()
```

Alternatively, open `app.R` in RStudio and click **Run App**.

## Lab concepts demonstrated

| R concept | Where it appears |
|---|---|
| Read CSV data | `read.csv()` loads `data/sample.csv` |
| Convert data frame to a list | `as.list()` in the List View and list operations |
| Access an element by index | List Indexing panel |
| Append a value | Append Value section |
| Modify a value | Update Value section |
| Find the number of columns | `length(current_data())` |

## Notes

- Changes are kept in application memory while the app is running.
- Use **Download Modified CSV** to save the current dataset.
- Appending a value to one column creates a new row; other columns in that row are filled with `NA`.
- This is an educational mini-project and does not use a database or user authentication.
