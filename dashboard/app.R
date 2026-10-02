library(shiny); library(bslib); library(tidyverse); library(plotly)

d <- read_csv("../data/processed/clean_data.csv")

# Whole-country rate per year, weighted by number of invited people
# (invited = participants / rate * 100)
national <- d %>%
  filter(rate > 0) %>%
  mutate(invited = absolute_value / (rate / 100)) %>%
  group_by(screening, year) %>%
  summarise(rate = 100 * sum(absolute_value) / sum(invited), .groups = "drop") %>%
  mutate(region = "Whole country")

# Whole-number year labels on the x-axis
whole_years <- function(x) unique(round(pretty(x)))

regions <- sort(unique(d$region))

ui <- page_sidebar(
  title = "Cancer Screening Dashboard",
  sidebar = sidebar(
    selectInput("screen", "Screening type", sort(unique(d$screening))),
    selectInput("regions", "Municipalities", regions, multiple = TRUE,
                selected = intersect(c("Helsinki", "Tampere", "Oulu"), regions)),
    checkboxInput("show_national", "Show whole-country line", TRUE),
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
    req(input$regions)
    plot_data <- f() %>% filter(region %in% input$regions)
    if (input$show_national) {
      plot_data <- bind_rows(
        plot_data,
        national %>% filter(screening == input$screen,
                            between(year, input$yr[1], input$yr[2])))
    }
    ggplotly(
      ggplot(plot_data, aes(year, rate, colour = region)) +
        geom_line() + geom_point() +
        scale_x_continuous(breaks = whole_years) +
        labs(x = "Year", y = "Participation (% of invited)", colour = NULL) +
        theme_minimal()
    )
  })
  
  output$compare <- renderPlotly({
    ggplotly(
      f() %>% filter(year == max(year)) %>% slice_max(rate, n = 20) %>%
        ggplot(aes(reorder(region, rate), rate)) + geom_col() + coord_flip() +
        labs(x = NULL, y = "Participation (% of invited), latest year in range") +
        theme_minimal()
    )
  })
}
shinyApp(ui, server)