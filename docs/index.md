---
title: Lecture Notes for the Tidy R Seminar
subtitle: 'CED, Barcelona, Summer 2018.'
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



Prerequisites
-------------

Please run this chunk of code below in your R session. It will install all the packages we need during the course.


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
    'skimr',         # nice dataframe summaries
    'broom'          # convert R objects to tidy dataframes
  ),
  repos = "https://cran.rstudio.com/"
)
```

Literate programming in Rmarkdown
---------------------------------

[The official Rmarkdown cheat sheet.](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf)

### Excercise: Literate programming in Rmarkdown

- Rewrite any of your existing R-scripts into an Rmarkdown script. Demonstrate loading data from the hard disc, plot output, text blocks, headers and lists. Export to pdf.
