# Life-table data by sex, age, period and country
# Jonas Schöley
# 2018-07-13
# Source: Human Mortality Database

library(tidyverse)
library(HMDHFDplus)

# HMD credentials
hmd_username <- 'jona.s@gmx.de'
hmd_password <- '1457615511'

# Download HMD period deaths, exposures and life-tables -------------------

hmd_cntry <- getHMDcountries()

# download HMD period deaths and exposures by sex
# and save in long format
hmd_counts <-
  data_frame(cntry = hmd_cntry) %>%
  # for each country...
  group_by(cntry) %>%
  do(
    {
      # ...download deaths
      deaths <- readHMDweb(CNTRY = .$cntry,
                           username = hmd_username,
                           password = hmd_password,
                           item = 'Deaths_1x1') %>%
        gather(key = sex, value = nDx, Female, Male, Total) %>%
        select(-OpenInterval)
      # ...download exposures
      exposures <- readHMDweb(CNTRY = .$cntry,
                              username = hmd_username,
                              password = hmd_password,
                              item = 'Exposures_1x1') %>%
        gather(key = sex, value = nEx, Female, Male, Total) %>%
        select(-OpenInterval)
      # ...combine deaths and exposures
      full_join(deaths, exposures, by = c('Year', 'Age', 'sex'))
    }
  ) %>%
  ungroup()

# download HMD period lifetables by sex
# and save in long format
hmd_lt <-
  data_frame(cntry = hmd_cntry) %>%
  # for each country...
  group_by(cntry) %>%
  do(
    {
      # ...download female lifetables
      female_lt <- readHMDweb(CNTRY = .$cntry,
                              username = hmd_username,
                              password = hmd_password,
                              item = 'fltper_1x1')
      # ...download male lifetables
      male_lt <- readHMDweb(CNTRY = .$cntry,
                            username = hmd_username,
                            password = hmd_password,
                            item = 'mltper_1x1')
      # ...download total lifetables
      total_lt <- readHMDweb(CNTRY = .$cntry,
                            username = hmd_username,
                            password = hmd_password,
                            item = 'bltper_1x1')
      # ...combine lifetables into long format data frame
      bind_rows(mutate(female_lt, sex = 'Female'),
                mutate(male_lt, sex = 'Male'),
                mutate(total_lt, sex = 'Total'))
    }
  ) %>%
  ungroup()

# merge counts and exposures
hmd <- full_join(hmd_counts, hmd_lt, by = c('cntry', 'Year', 'Age', 'sex'))

# Clean the data ----------------------------------------------------------

# country codes and names
cntry_code_name <-
  c('Australia' = 'AUS',
    'Austria' = 'AUT',
    'Belarus' = 'BLR',
    'Belgium' = 'BEL',
    'Bulgaria' = 'BGR',
    'Canada' = 'CAN',
    'Chile' = 'CHL',
    'Czech Republic' = 'CZE',
    'Denmark' = 'DNK',
    'East Germany' = 'DEUTE',
    'England & Wales' = 'GBRTENW',
    'Estonia' = 'EST',
    'Finland' = 'FIN',
    'France' = 'FRATNP',
    'Greece' = 'GRC',
    'Hungary' = 'HUN',
    'Iceland' = 'ISL',
    'Ireland' = 'IRL',
    'Israel' = 'ISR',
    'Italy' = 'ITA',
    'Japan' = 'JPN',
    'Latvia' = 'LVA',
    'Lithuania' = 'LTU',
    'Luxembourg' = 'LUX',
    'Netherlands' = 'NLD',
    'New Zealand' = 'NZL_NP',
    'Northern Ireland' = 'GBR_NIR',
    'Norway' = 'NOR',
    'Poland' = 'POL',
    'Portugal' = 'PRT',
    'Russia' = 'RUS',
    'Scotland' = 'GBR_SCO',
    'Slovakia' = 'SVK',
    'Slovenia' = 'SVN',
    'Spain' = 'ESP',
    'Sweden' = 'SWE',
    'Switzerland' = 'CHE',
    'Taiwan' = 'TWN',
    'U.S.A.' = 'USA',
    'Ukraine' = 'UKR',
    'West Germany' = 'DEUTW')

hmd <-
  hmd %>%
  # remove duplicate populations
  filter(
    # Exclude the German total population data as it overlaps with data for
    # east and west Germany but has the shorter timeline.
    cntry != 'DEUTNP',
    # Exclude French civil population data as it overlaps with total population
    # data and most country data is only available for total populations anyway.
    cntry != 'FRACNP',
    # Exclude New Zealand Maori and Non-Maori population data as it overlaps
    # with total population data.
    cntry != 'NZL_MA',
    cntry != 'NZL_NM',
    # Exclude Great Britain total population and England & Wales civilian
    # population as they overlap with data from England & Wales, Northern
    # Ireland and Scotland.
    cntry != 'GBR_NP',
    cntry != 'GBRCENW') %>%
  mutate(country_name =
           factor(cntry, levels = cntry_code_name,
                  labels = names(cntry_code_name)) %>% as.character()) %>%
  group_by(cntry, sex, Year) %>%
  mutate(nx = c(diff(Age), NA)) %>%
  select(country = cntry, country_name, sex, period = Year, age = Age, nx,
         nDx, nEx, nax = ax, nmx = mx, nqx = qx, lx, ndx = dx, nLx = Lx, Tx, ex) %>%
  ungroup()

save(hmd, file = 'data/hmd/hmd.RData', compress = 'xz')

# Derive smaller data sets ------------------------------------------------

# only the deaths and exposures
hmd_counts <-
  hmd %>%
  select(country, sex, period, age, nx, nDx, nEx)

save(hmd_counts, file = 'data/hmd/hmd_counts.RData', compress = 'xz')

# Swedish total deaths and exposures by age
hmd_swe <-
  hmd %>%
  filter(country == 'SWE', sex == 'Total') %>%
  select(period, age, nx, nDx, nEx)

save(hmd_swe, file = 'data/hmd/hmd_swe.RData', compress = 'xz')
