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
suppressMessages(library(threejs))

# Load the combined data frame where columns are different data and algorithms
combined_df <- suppressMessages(
  suppressWarnings(
    readr::read_tsv(file.path("data", "data_feature_encodings.tsv"))
    )
  )

# Load offician 
tcga_colors <- suppressMessages(
  suppressWarnings(
    readr::read_tsv(file.path("data", "tcga_colors.tsv"))
  )
)

tcga_colors <- tcga_colors[order(tcga_colors$`Study Abbreviation`), ]
match_colors <- match(combined_df$acronym, tcga_colors$`Study Abbreviation`)
combined_df$colors <- tcga_colors$`Hex Colors`[match_colors]

palette_order <- c("BRCA",
                   "PRAD", "TGCT", "KICH", "KIRP", "KIRC", "BLCA",
                   "OV", "UCS", "CESC", "UCEC",
                   "THCA", "PCPG", "ACC",
                   "SKCM",
                   "UVM", "HNSC",
                   "SARC",
                   "ESCA", "STAD", "COAD", "READ",
                   "CHOL", "PAAD", "LIHC",
                   "DLBC",
                   "MESO", "LUSC", "LUAD",
                   "GBM", "LGG",
                   "LAML", "THYM",
                   NA)

# Get important column name variables
major_colums <- c("sample_id", "platform", "portion_id", "age_at_diagnosis",
                  "stage", "vital_status", "race", "acronym", "disease",
                  "organ", "drug", "ethnicity", "percent_tumor_nuclei",
                  "gender", "sample_type", "analysis_center",
                  "year_of_diagnosis", "colors")
major_subset_df <- combined_df %>%
  dplyr::select(which(colnames(combined_df) %in% major_colums))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  
  # output$threejs <- renderScatterplotThree({
  #   if (input$interactive) {
  #     scatterplot3js(x = plot_df$`1`, y = plot_df$`2`,
  #                    z = plot_df$`3`, color = plot_df$colors, 
  #                    renderer = 'webgl', labels = plot_df$acronym,
  #                    size = 0.2)
  #   }
  # })
  # 

  # Setup reactive variables
  plot_df <- reactive({
    data_type <- input$data
    algorithm <- input$algorithm
    #interactive <- input$interactive

    base_head <- ""
    # Build column name subsets
    if (data_type == "RNA-seq") {
      base_head <- "_rna_"
    } else if (data_type == "Copy Number") {
      base_head <- "_copy_"
    }
    
    if (algorithm == "PCA") {
      base_head <- paste0(base_head, "pca")
    } else if (algorithm == "NMF") {
      base_head <- paste0(base_head, "nmf")
    } else if (algorithm == "t-SNE") {
      base_head <- paste0(base_head, "tsne")
    } else if (algorithm == "Variational Autoencoder") {
      # Only RNAseq data has VAE support
      base_head <- paste0(base_head, "vae")
    }
    
    # Select column subsets
    plot_df <- combined_df %>% select_if(grepl(base_head, colnames(.)))
    colnames(plot_df) <- 1:ncol(plot_df)
    
    # Combine with important info from combined
    plot_df <- dplyr::bind_cols(plot_df, major_subset_df)
    list(plot_item = plot_df, base_name = base_head)
  })
  
  x_coord <- reactive({
    paste(input$x_range)
  })

  y_coord <- reactive({
    paste(input$y_range)
  })

  color_ <- reactive({
    input$covariate
  })

  shape_ <- reactive({
    input$covariate_alt
  })

  # interactive <- reactive({
  #   input$interactive
  # })

  output$pancanplot <- renderPlot(
    {
      plot_df <- plot_df()[[1]]
      x_coord <- x_coord()
      y_coord <- y_coord()
      color_ <- color_()
      shape_ <- shape_()

      p <- ggplot(plot_df,
                  aes_string(x = plot_df[[x_coord]],
                             y = plot_df[[y_coord]],
                             color = color_)) + 
        xlab(paste("latent dimension", x_coord)) +
        ylab(paste("latent dimension", y_coord)) +
        theme_bw() +
        theme(text = element_text(size = 20))
      
      if (shape_ != "None") {
        p <- p + geom_point(aes_string(shape = shape_))
      } else {
        p <- p + geom_point()
      }
      
      if (color_ == 'acronym') {
        p <- p + scale_colour_manual(limits = tcga_colors$`Study Abbreviation`,
                                     values = tcga_colors$`Hex Colors`,
                                     na.value = 'black',
                                     breaks = palette_order)
      }
      print(p)
  })
  
  output$download <- downloadHandler(
    filename = function() {
      base <- plot_df()[[2]]
      base <- paste0(base, x_coord(), "_", y_coord())
      paste0("pancan_plot", base, ".", input$filetype)
    },

    content = function(file) {
      # same as renderplot
      plot_df <- plot_df()[[1]]
      x_coord <- x_coord()
      y_coord <- y_coord()
      color_ <- color_()
      shape_ <- shape_()
      
      p <- ggplot(plot_df,
                  aes_string(x = plot_df[[x_coord]],
                             y = plot_df[[y_coord]],
                             color = color_)) + 
        xlab(paste("latent dimension", x_coord)) +
        ylab(paste("latent dimension", y_coord)) +
        theme_bw()
      
      if (shape_ != "None") {
        p <- p + geom_point(aes_string(shape = shape_))
      } else {
        p <- p + geom_point()
      }
      
      if (color_ == 'acronym') {
        p <- p + scale_colour_manual(limits = tcga_colors$`Study Abbreviation`,
                                     values = tcga_colors$`Hex Colors`,
                                     na.value = 'black',
                                     breaks = palette_order)
      }
      p + ggsave(file, width = 6, height = 5)
    }
  )
})
