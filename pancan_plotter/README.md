# Visualizing pan-cancer with PanCan Plotter

*Shiny app for exploring latent space of reduced dimensionality pan-cancer data*

## Currently supports:

### Covariate information visualized with:

* Gene expression
  * [Variational Autoencoder](https://github.com/greenelab/vae_pancan) with 300 features

#### The covariate information currently consists of:

| Covariate | Description | E.g. |
|: ------- :|: --------- :|: -- :|
| acronym | cancer-type official TCGA symbol | GBM |
| sample type | type of tumor profiled | Metastatic |
| disease | full name of acronym | Glioblastoma |
| organ | organ site of tumor | Brain |
| vital status | if patient is alive | Alive/Dead |
| age at diagnosis | age when diagnosed | 75 |
| stage | tumor stage when diagnosed | Stage IV |
| percent tumor nuclei | Pathologist graded purity of excised tumor | 95 |
| drug | drug(s) the patient recieved as treatment | Doxorubicin |
| gender | gender of the patient | Male/Female |
| race | race of the patient | Asian |
| ethnicity | ethnicity of the patient | Hispanic or Latino |
| platform | gene expression platform used | Illumina HiSeq |
| analysis center | where the data was processed/analyzed | UNC |
| year of diagnosis | when the patient was first diagnosed | 2003 |

