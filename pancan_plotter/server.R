#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

suppressMessages(library(shiny))
suppressMessages(library(readr))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))

combined_df <- suppressMessages(
  suppressWarnings(
    readr::read_tsv(file.path("data", "combined_clinical_encoded.tsv"))
    )
  )

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  output$pancanplot <- renderPlot(
    {
      x_coord <- paste(input$x_range)
      y_coord <- paste(input$y_range)
      color_ <- input$covariate
      shape_ <- input$covariate_alt

      p <- ggplot(combined_df,
             aes_string(x = combined_df[[x_coord]],
                        y = combined_df[[y_coord]],
                        color = color_)) + 
        xlab(paste("latent dimension", x_coord)) +
        ylab(paste("latent dimension", y_coord)) +
        theme_bw()
      
      if (shape_ != "None") {
        p <- p + geom_point(aes_string(shape = shape_))
      } else {
        p <- p + geom_point()
      }
      
      print(p)
  })
  
})
