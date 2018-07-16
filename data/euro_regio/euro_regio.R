# European regional population statistics
# Jonas Schöley
# 2018-07-12
# Source: Eurostat

library(tidyverse)
library(eurostat)

# population on 1 January by NUTS 2 region
popnum <-
  get_eurostat('tgs00096', stringsAsFactors = FALSE) %>%
  select(geo, time, pop = values)

# population density  by NUTS 2 region
popdens <-
  get_eurostat('tgs00024', stringsAsFactors = FALSE) %>%
  select(geo, time, popdens = values)

# deaths by NUTS 2 region
deaths <-
  get_eurostat('tgs00098', stringsAsFactors = FALSE) %>%
  select(geo, time, deaths = values)

# population change by NUTS 2 region
# crude rates of total change, natural change and net migration
popchange <-
  get_eurostat('tgs00099', stringsAsFactors = FALSE) %>%
  spread(indic_de, values) %>%
  select(geo, time,
         netmigrate = CNMIGRATRT,
         growthrate = GROWRT,
         natgrowthrate = NATGROWRT)

# total fertility rate by NUTS 2 region
totfert <-
  get_eurostat('tgs00100', stringsAsFactors = FALSE) %>%
  select(geo, time, totfert = values)

# life expectancy at birth by NUTS 2 region
lifeexp <-
  get_eurostat('tgs00101', stringsAsFactors = FALSE) %>%
  filter(sex == 'T') %>%
  select(geo, time, lifeexp = values)

# disposable income of private households by NUTS 2 regions
income <-
  get_eurostat('tgs00026', stringsAsFactors = FALSE) %>%
  select(geo, time, income = values)

# regional gross domestic product by NUTS 2 regions - million EUR
gdp <-
  get_eurostat('tgs00003', stringsAsFactors = FALSE) %>%
  select(geo, time, gdp = values)

# unemployment rate by NUTS 2 regions
unemp <-
  get_eurostat('tgs00010', stringsAsFactors = FALSE) %>%
  filter(sex == 'T') %>%
  select(geo, time, unemp = values)

# european regional statistics
euro_regio <-
  # join all the tables
  popnum %>%
  full_join(popdens) %>%
  full_join(births) %>%
  full_join(deaths) %>%
  full_join(popchange) %>%
  full_join(totfert) %>%
  full_join(lifeexp) %>%
  full_join(income) %>%
  full_join(gdp) %>%
  full_join(unemp) %>%
  # only nuts regions not the countries
  filter(str_length(geo) == 4) %>%
  # make sure each region has the same nominal coverage, introduce NAs
  # wherever no data is available
  complete(geo, time) %>%
  mutate(
    # convert date to integer year
    time = as.integer(lubridate::year(time)),
    # country code is first two letters of nuts-2 code
    country_code = str_sub(geo, end = 2),
    country_name = label_eurostat(country_code, 'geo', fix_duplicated = TRUE),
    # add names for the NUTS-2 codes
    nuts2_name = label_eurostat(geo, 'geo', fix_duplicated = TRUE),
    # eu member
    eu_member = country_code %in% eu_countries$code,
    eu_candidate = country_code %in% eu_candidate_countries$code,
    efta_member = country_code %in% efta_countries$code,
    # add region
    region = fct_collapse(country_code,
                          eastern = c('AL', 'AT', 'BG', 'CZ', 'EE', 'HR', 'HU', 'LT',
                                      'LV', 'ME', 'MK', 'PL', 'RO', 'SI', 'SK'),
                          western = c('AT', 'BE', 'CH', 'DE', 'FR', 'IE', 'LI',
                                      'LU', 'NL', 'UK'),
                          southern = c('CY', 'EL', 'ES', 'IT', 'MT', 'PT', 'TR'),
                          northern = c('DK', 'FI', 'IS', 'NO', 'SE')) %>% as.character()
    ) %>%
  select(country_code, country_name, nuts2_code = geo, nuts2_name,
         year = time, pop, popdens, births, deaths,
         natgrowthrate, growthrate, netmigrate,
         totfert, lifeexp,
         income, gdp, unemp, region, eu_member, eu_candidate, efta_member) %>%
  arrange(nuts2_code, year)

save(euro_regio, file = 'data/euro_regio/euro_regio.Rdata', compress = 'xz')

euro_regio_eu <-
  euro_regio %>%
  filter(eu_member) %>%
  select(-eu_member, -eu_candidate, -efta_member)

save(euro_regio_eu, file = 'data/euro_regio/euro_regio_eu.Rdata', compress = 'xz')
