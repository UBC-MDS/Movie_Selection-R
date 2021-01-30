library(tidyverse)
library(purrr)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(plotly)
#library(dashTable)


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

cards = dbcCardDeck(
  list(
    dbcCard(dbcCardBody(list(
      htmlH6("Average voting", className = 'card-title'),
      htmlH4(id = "average-vote", className = 'card-text')
    )),
    color = "primary",
    outline = TRUE),
    dbcCard(dbcCardBody(list(
      htmlH6("Average box office value", className = 'card-title'),
      htmlH4(id = "average-revenue", className = 'card-text')
    )),
    color = "primary",
    outline = TRUE)
  )
)

genre_graphs = htmlDiv(list(dbcRow(list(
  dbcCol(dbcCard(
    list(dbcCardHeader(htmlH4(id = "vote-plot-title")),
         dbcCardBody(dccGraph(
           id = "vote-plot",
           style = list(
             "border-width" = "0",
             "width" = "100%",
             "height" = 265
           )
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
    list(dbcCardHeader(htmlH4(id = "top-movies-title")),
         dbcCardBody(dccGraph(
              id = "top_movies",
              style = list(
                   "border-width" = "0",
                   "width" = "100%",
                   "height" = "400px"
              ),
         )))
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
    options = purrr::map(movies$genres %>% unique(), function(col)
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

##### CALLBACK #####


# Voting average by studio ------------------------------------------------

app$callback(
     output('vote-plot', 'figure'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget){
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
         
          vote_avg_by_studio <- filtered_movies %>% 
               ggplot(aes(x = as.factor(studios), y = vote_average)) +
               geom_boxplot(fill="#20B2AA", color = 'turquoise4') + 
               labs(y = 'Vote Average') +
               coord_flip() +
               theme(axis.title.y = element_blank(),
                     axis.title.x = element_text(face = 'bold', color = 'turquoise4'),
                     axis.text = element_text(color = 'turquoise4'))
          
          ggplotly(vote_avg_by_studio + aes(text = title), tooltip = 'text') 
          
     }
     
)


# Financials by studio ----------------------------------------------------

app$callback(
     output('revenue-plot', 'figure'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget){
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
          
          rev_by_studio <- filtered_movies %>% 
               ggplot(aes(x = as.factor(studios), y = revenue)) +
               geom_boxplot(fill="#20B2AA", color = 'turquoise4') + 
               labs(y = 'Revenue (US$ mil)') +
               coord_flip() +
               theme(axis.title.y = element_blank(),
                     axis.title.x = element_text(face = 'bold', color = 'turquoise4'),
                     axis.text = element_text(color = 'turquoise4'))
          
          ggplotly(rev_by_studio + aes(text = title), tooltip = 'text') 
          
     }
     
)


# Voting profile scattered plot -------------------------------------------

app$callback(
     output('vote-scatter-plot', 'figure'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget){
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
          
          voting_profile <- filtered_movies %>% 
               ggplot(aes(vote_average, vote_count)) +
               geom_jitter(color = "#20B2AA", color = 'turquoise4', alpha = 0.6) +
               labs(x = 'Vote Average', y = "Vote Count") +
               theme(
                    axis.title = element_text(face = 'bold', color = 'turquoise4'),
                    axis.text = element_text(color = 'turquoise4'))
          
          ggplotly(voting_profile + aes(text = title), tooltip = 'text') 
          
     }
     
)


# Top film table/bar-chart ----------------------------------------------------------

app$callback(
     output('top_movies', 'figure'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget){
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
          
          top_movies_by_vote <- filtered_movies %>% 
               group_by(title) %>% 
               summarize(vote_average = mean(vote_average),
                         runtime = mean(runtime)) %>% 
               arrange(desc(vote_average)) %>% 
               slice(1:10) %>% 
               ggplot(aes(x= vote_average, y = reorder(title, vote_average), color = runtime)) +
               geom_point(stat = 'identity', shape = 2, size = 5, stroke = 1) +
               labs(x = "Vote Average", legend = "Runtime (mins)")+
               xlim(3.25, 4.5)+
               scale_color_gradient(low = "cadetblue1", high ="#20B2AA")+
               theme(axis.title.y = element_blank(),
                    axis.title = element_text(face = 'bold', color = 'turquoise4'),
                    axis.text = element_text(color = 'turquoise4'))
          
          ggplotly(top_movies_by_vote + aes(text = paste("Runtime:", runtime, "\nVote avg", vote_average)), tooltip = 'text')     


     }
     
)



# Avg. box office card ----------------------------------------------------

app$callback(
     output('average-revenue', 'children'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget) {
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
          average_revenue <- paste("US$", round(mean(filtered_movies$revenue),2),"mil")
          return(average_revenue)
     }
)


# Avg. voting card --------------------------------------------------------

app$callback(
     output('average-vote', 'children'),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget) {
          filtered_movies <- movies %>% 
               filter(genres == xgenre,
                      budget %in% (unlist(xbudget)[1]:unlist(xbudget)[2]))
          average_vote <- round(mean(filtered_movies$vote_average),2)
          return(average_vote)
     }
)


# Chart Titles ------------------------------------------------------------

app$callback(
     list(output("vote-plot-title", 'children'),
          output("revenue-plot-title", 'children'),
          output("vote-scatter-title", 'children'),
          output("top-movies-title", 'children')),
     list(input("xgenre-widget", "value"),
          input("xbudget-widget", "value")),
     function(xgenre, xbudget) {
         return(list(
               paste(xgenre,'Movies Vote Average By Studio'),
               paste(xgenre,'Movies Financials By Studio'),
               paste('Voting Profile For', xgenre, 'Movies'),
               paste('Most Popular', xgenre,'Movies (By Vote Average)')
          ))
     }
)




app$run_server(debug = F)