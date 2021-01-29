library(tidyverse)
library(purrr)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)

movies = read_csv("data/processed/movies.csv")

app <- Dash$new(external_stylesheets = dbcThemes$LUMEN)

SIDEBAR_STYLE = list(
  "position" = "fixed",
  "top" = 0,
  "left" = 0,
  "bottom" = 0,
  "width" = "20rem",
  "padding" = "2rem 1rem",
  "z-index" = 4000000
)

CONTENT_STYLE = list(
  "margin-left" = "20rem",
  "margin-right" = "2rem",
  "padding" = "2rem 1rem",
  "z-index" = -1
)

cards = dbcCol(list(
  dbcCard(dbcCardBody(list(
    htmlH6("Average box office value", className = 'card-title'),
    htmlH4(id = "average-revenue", className = 'card-text')
  )),
  color = "primary",
  outline = TRUE),
  dbcCard(dbcCardBody(list(
    htmlH6("Average voting", className = 'card-title'),
    htmlH4(id = "average-vote", className = 'card-text')
  )),
  color = "primary",
  outline = TRUE)
))

genre_graphs = htmlDiv(list(dbcRow(list(
  dbcCol(dbcCard(
    list(dbcCardHeader(htmlH4(id = "vote-plot-title")),
         dbcCardBody(dccGraph(
           id = "vote-plot",
           style = list(
             "border-width" = "0",
             "width" = "100%",
             "height" = 265
           ),
         ))),
    color = "success",
    outline = TRUE
  )),
  dbcCol(dbcCard(
    list(dbcCardHeader(htmlH4(id = "revenue-plot-title")),
         dbcCardBody(
           dccGraph(
             id = "revenue-plot",
             style = list(
               "border-width" = "0",
               "width" = "100%",
               "height" = 265
             ),
           )
         )),
    color = "success",
    outline = TRUE
  ))
))))

studio_graphs = htmlDiv(list(dbcRow(list(dbcCol(
  dbcCard(
    list(dbcCardHeader(htmlH4(id = "vote-scatter-title")),
         dbcCardBody(
           dccGraph(
             id = "vote-scatter-plot",
             style = list(
               "border-width" = "0",
               "width" = "100%",
               "height" = "400px"
             ),
           )
         )),
    color = "info",
    outline = TRUE
  ),
))),
htmlBr(),
htmlBr(),
dbcRow(list(dbcCol(
  dbcCard(
    list(dbcCardHeader(htmlH4(id = "table-title")),
         dbcCardBody(htmlDiv(id = "movies-data-frame")))
    ,
    color = "info",
    outline = TRUE
  )
)))))

content = htmlDiv(
  list(
    cards,
    htmlBr(),
    htmlBr(),
    genre_graphs,
    htmlBr(),
    htmlBr(),
    studio_graphs
  ),
  id = "page-content",
  style = CONTENT_STYLE
)

controls = dbcCard(list(dbcFormGroup(list(
  dbcLabel("Genre"),
  dccDropdown(
    id = "xgenre-widget",
    options = purrr::map(movies %>% colnames, function(col)
      list(label = col, value = col)),
    value = "Horror",
    clearable = FALSE
  )
)),
dbcFormGroup(list(
  dbcLabel("Budget Range (US$ mil)"),
  dccRangeSlider(
    id = "xbudget-widget",
    min = 10,
    max = 300,
    value = list(10, 300),
    marks = list(
      "10" = "10",
      "100" = "100",
      "200" = "200",
      "300" = "300"
    ),
  )
))),
body = TRUE,
className = "text-dark")

sidebar = htmlDiv(
  list(
    htmlH2("Movie Selection", className = "display-4"),
    htmlHr(),
    controls,
    htmlHr(),
    htmlP(
      "A data visualization app that allows decision makers in the streaming companies to explore a dataset of movies to determine the popular movies that they need to provide to their users",
      className = "lead"
    )
  ),
  style = SIDEBAR_STYLE,
  className = 'bg-primary text-white'
)
app$layout(htmlDiv(list(sidebar, content)))


app$run_server(debug = T)