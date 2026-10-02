library(shiny); library(bslib); library(tidyverse); library(plotly)

d <- read_csv("../data/processed/clean_data.csv")

ui <- page_sidebar(
  title = "Cancer Screening Dashboard",
  sidebar = sidebar(
    selectInput("screen", "Screening type", sort(unique(d$screening))),
    selectInput("regions", "Municipalities", sort(unique(d$region)),
                multiple = TRUE, selected = head(sort(unique(d$region)), 3)),
    sliderInput("yr", "Years", min(d$year), max(d$year),
                value = range(d$year), sep = "")
  ),
  navset_card_tab(
    nav_panel("Trend", plotlyOutput("trend")),
    nav_panel("Regional comparison", plotlyOutput("compare"))
  )
)

server <- function(input, output) {
  f <- reactive(d %>% filter(screening == input$screen,
                             between(year, input$yr[1], input$yr[2])))
  output$trend <- renderPlotly({
    ggplotly(f() %>% filter(region %in% input$regions) %>%
               ggplot(aes(year, rate, colour = region)) + geom_line() + theme_minimal())
  })
  output$compare <- renderPlotly({
    ggplotly(f() %>% filter(year == max(year)) %>% slice_max(rate, n = 20) %>%
               ggplot(aes(reorder(region, rate), rate)) + geom_col() + coord_flip() + theme_minimal())
  })
}
shinyApp(ui, server)