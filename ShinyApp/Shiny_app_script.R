library(shiny)
library(tidyverse)
library(shinydashboard)
library(janitor)
library(paletteer)
library(here)

health_data <- read_csv(here("data/ss.csv")) %>% clean_names()

health_data %>% 
  mutate(daily_steps_category = case_when(
    daily_steps < 5000 ~ "Low",
    daily_steps >= 5000 & daily_steps < 10000 ~ "Moderate",
    daily_steps >= 10000 ~ "High"
  )) %>% 
  mutate(blood_pressure_category = case_when(
    blood_pressure < 120 ~ "Normal",
    blood_pressure >= 120 & blood_pressure < 130 ~ "Elevated",
    blood_pressure >= 130 & blood_pressure < 140 ~ "High Blood Pressure Stage 1",
    blood_pressure >= 140 ~ "High Blood Pressure Stage 2"
  )) -> health_data


my_palette <- paletteer_d("futurevisions::atomic_red")

ui <- dashboardPage(
  dashboardHeader(title = "Health information based on Occupation"),
  
  dashboardSidebar(
    width = 250, # You can adjust the width as needed
    selectInput("x", "Sleep Disorder", choices=c("All", unique(health_data$`sleep_disorder`))),
    hr(),
    selectInput("y", "Select BMI Category", choices=c("All", unique(health_data$bmi_category))),
    hr(),
    selectInput("z", "Select Daily Steps", choices=c("All", unique(health_data$daily_steps_category))),
    hr(),
    selectInput("a", "Select Blood Pressure Category", choices=c("All", unique(health_data$blood_pressure_category))),
    hr()
  ),
  
  dashboardBody(
    fluidRow(
      box(width = 12, 
          plotOutput("plot", width="100%", height="400px"))
    )
  )
)

server <- function(input, output, session) {
  session$onSessionEnded(stopApp) #stops app when we close it
  
  output$plot <- renderPlot({
    filtered_data <- health_data
    
    if(input$x != "All") {
      filtered_data <- filtered_data %>% filter(sleep_disorder == input$x)
    }
    if(input$y != "All") {
      filtered_data <- filtered_data %>% filter(bmi_category == input$y)
    }
    if(input$z != "All") {
      filtered_data <- filtered_data %>% filter(daily_steps_category == input$z)
    }
    if(input$a != "All") {
      filtered_data <- filtered_data %>% filter(blood_pressure_category == input$a)
    }
    
    filtered_data %>% 
      ggplot(aes(x=occupation, fill=gender))+
      geom_bar(position="dodge")+
      theme_light()+
      scale_fill_manual(values=my_palette)+
      theme(axis.text.x=element_text(angle=90,hjust=1))+
      labs(title="Health Information by Occupation",
           x="Occupation", 
           fill="Gender")
  })
}


shinyApp(ui, server)