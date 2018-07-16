---
title: Tidy R
author: Jonas Schöley
date: 2018-07-16
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib]
biblio-style: apalike
link-citations: yes
github-repo: jschoeley/ced18-tidyr
---

Before we start
===============



These are the packages we will use during this course.


```r
install.packages('devtools')

devtools::install_cran(
  pkgs = c(
    'tidyverse',     # tools for tidy data analysis
    'rmarkdown',     # literate programming
    'plotly',        # interactive visualization
    'ggmap',         # use online map-tiles with ggplot
    'eurostat',      # download data from eurostat
    'sf',            # tidy geo-computing
    'rnaturalearth', # download worldwide map data
    'gapminder',     # data from the gapminder world project
    'cowplot',       # ggplot multiple figures addon
    'skimr'          # nice dataframe summaries
  ),
  repos = "https://cran.rstudio.com/"
)
```