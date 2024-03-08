library(shiny)
library(tidyverse)
library(shinydashboard)

ui <- dashboardPage(
  
  dashboardHeader(title = "Health information based on Occupation"),
  
  dashboardSidebar(disable=TRUE),
  
  dashboardBody(
    fluidRow(
      box( 
        selectInput("x", "Sleep Disorder", choices=c("All", unique(health_data$`sleep_disorder`))), hr()
      ),
      box( 
        selectInput("y", "Select BMI Category", choices=c("All", unique(health_data$bmi_category))), hr()
      ),
      box( 
        selectInput("z", "Select Daily Steps", choices=c("All", unique(health_data$daily_steps_category))), hr()
      ),
      box( 
        selectInput("a", "Select Blood Pressure Category", choices=c("All", unique(health_data$blood_pressure_category))), hr()
      ),
      box(width=7, 
          plotOutput("plot", width="600px", height="400px"))
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
      theme(axis.text.x=element_text(angle=90,hjust=1))+
      labs(title="Health Information by Occupation",
           x="Occupation", 
           fill="Gender")
  })
}


shinyApp(ui, server)