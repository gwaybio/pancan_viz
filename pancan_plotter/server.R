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
      data_type <- input$data
      algorithm <- input$algorithm
      
      if (data_type == "RNA-seq") {
        base_file <- file.path("data", "RNAseq_")
      } else if (data_type == "Copy Number") {
        base_file <- file.path("data", "CopyNumber_")
      }
      
      if (algorithm == "PCA") {
        base_file <- paste0(base_file, "pca_results.tsv")
      } else if (algorithm == "NMF") {
        base_file <- paste0(base_file, "nmf_results.tsv")
      } else if (algorithm == "t-SNE") {
        base_file <- paste0(base_file, "tsne_results.tsv")
      } else if (algorithm == "Variational Autoencoder") {
        # Only RNAseq data has VAE support
        base_file <- file.path("data", "combined_clinical_encoded.tsv")
      }
      
      data_df <- readr::read_tsv(base_file)
      
      if (algorithm != "Variational Autoencoder") {
        clinical_col_df <- combined_df[, c(2, 304:ncol(combined_df))]
        data_df <- dplyr::full_join(data_df,
                                    clinical_col_df,
                                    by = c("tcga_id" = "sample_id"))
      }

      p <- ggplot(data_df,
             aes_string(x = data_df[[x_coord]],
                        y = data_df[[y_coord]],
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
