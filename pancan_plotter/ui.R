#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Pan Cancer Genomics -- Reduced Dimensions Visualization Tool"),

  # Sidebar with interactive layout
  sidebarLayout(

    sidebarPanel(

        helpText("Explore the latent space of pan-cancer genomic data according
                 to different genomic data, covariate information, and
                 dimensionality reduction techniques."),

        selectInput("data",
                    label = "Choose a data-type to visualize",
                    choices = c("RNA-seq"),  # Copy Number Coming Soon
                    selected = "RNA-seq"),

        selectInput("algorithm",
                    label = "Choose an algorithm to explore",
                    choices = c("PCA", "NMF", "t-SNE", "ADAGE",
                                "Variational Autoencoder"),
                    selected = "Variational Autoencoder"),

        selectInput("covariate",
                    label = "Choose a variable to plot",
                    choices = c("acronym", "sample_type", "disease",
                                "vital_status", "age_at_diagnosis", "stage",
                                "percent_tumor_nuclei","drug", "gender",
                                "race", "ethnicity", "platform", "organ",
                                "analysis_center", "year_of_diagnosis"),
                    selected = "acronym"),

        selectInput("covariate_alt",
                    label = "Choose a second variable to plot (optional)",
                    choices = c("acronym", "sample_type", "disease",
                                "vital_status", "age_at_diagnosis", "stage",
                                "percent_tumor_nuclei","drug", "gender",
                                "race", "ethnicity", "platform", "organ",
                                "analysis_center", "year_of_diagnosis", "None"),
                    selected = "None"),

        sliderInput("x_range",
                     label = "Enter x coordinate:",
                     value = 1,
                     min = 1,
                     max = 100,
                     step = 1),

        sliderInput("y_range",
                     label = "Enter y coordinate:",
                     value = 2,
                     min = 1, 
                     max = 100,
                     step = 1),

        radioButtons(inputId = "filetype", label = "Select the file type",
                     choices = list("png", "pdf"))

       # checkboxInput("interactive",
       #               label = "3D Interactive",
       #               value = FALSE)

        ),
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("pancanplot"),
       downloadButton(outputId = "download", label = "Download plot")
    )
  )
))
