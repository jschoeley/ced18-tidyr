What is tidy R?
===============



Differences between tidy and base R
-----------------------------------

The Gompertz Law describes the exponential relationship between age and mortality rate in human populations. Its two parameters $a$ and $b$ describe the overall mortality level and the relative rate of mortality inrease over age. It is well known that both parameters correlate with each other. The code below demonstrates this co-variance by fitting the Gompertz equation to Swedish birth cohorts and plotting the parameter estimates against each other.

$$
\mu(x) = ae^{bx}
$$


```r
# load data
load('data/hmd/hmd_counts.RData')

# select ages 30 to 80, drop total counts, drop NAs
hmd_sub <-
  na.omit(subset(hmd_counts, age >= 30 & age < 80 & sex != 'Total'))
# split the data by sex, country and year
hmd_split <-
  split(hmd_sub, list(hmd_sub$sex, hmd_sub$country, hmd_sub$period),
        drop = TRUE)
# run a linear regression on each subset
hmd_regress <-
  lapply(hmd_split,
         function (lt) glm(round(nDx, 0) ~ I(age-30) + offset(log(nEx)),
                           family = 'poisson', data = lt))
# extract the coefficients from each regression model
hmd_coef <- t(sapply(hmd_regress, coef))
# plot a versus b coefficients
plot(x = hmd_coef[,1], y = hmd_coef[,2],
     main = 'Gompertz correlation', xlab = 'a', ylab = 'b')
```

![](01-what_is_tidy_r_files/figure-epub3/unnamed-chunk-1-1.png)<!-- -->

Here's how I would write the same program today, using the `tidyverse`.


```r
library(tidyverse)
# load data
load('data/hmd/hmd_counts.RData')

hmd_counts %>%
  # select ages 30 to 80, drop total counts
  filter(age >= 30, age < 80, sex != 'Total') %>%
  # drop NAs
  drop_na() %>%
  # for each period...
  group_by(period, country, sex) %>%
  # ...run a Poisson regression of deaths versus age
  do(lm = glm(round(nDx, 0) ~ I(age-30) + offset(log(nEx)),
              family = 'poisson', data = .)) %>%
  # extract the regression coefficients
  mutate(a = coef(lm)[1], b = coef(lm)[2]) %>%
  # plot a versus b coefficients and label with year
  ggplot() +
  geom_point(aes(x = a, y = b), shape = 1, size = 3) +
  labs(title = 'Gompertz correlation')
```

![](01-what_is_tidy_r_files/figure-epub3/unnamed-chunk-2-1.png)<!-- -->

What are the differences?

![In base R we stores intermediate results often.](assets/assignment.png)

![In tidy R a single *data pipeline* often gets us from raw data to finished result.](assets/pipes.png)

![In base R data structures change often.](assets/various_data_structures.png)

![In tidy R the dataframe is the most important data structure.](assets/single_data_structure.png)

![In base R we have to use various indexing styles.](assets/various_indexing_styles.png)

![In tidy R we use a single indexing style.](assets/single_indexing_style.png)

![In base R important information is sometimes stored in row names.](assets/info_in_rownames.png)

![In tidy R all information exists in the form of data frame columns.](assets/variable_in_its_own_column.png)

### Excercise: Differences between tidy and base R

- Discuss the differences.

Literate programming in Rmarkdown
---------------------------------

[The official Rmarkdown cheat sheet.](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf)

### Excercise: Literate programming in Rmarkdown

- Rewrite any of your existing R-scripts into an Rmarkdown script. Demonstrate loading data from the hard disc, plot output, text blocks, headers and lists. Export to pdf.

First steps in tidy data analysis
---------------------------------

