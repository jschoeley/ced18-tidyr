# European time use survey
# Jonas Schöley
# 2018-07-12
# Source: Eurostat

library(tidyverse)
library(eurostat)
library(lubridate)

# Time spent, participation time and participation rate in the main activity
# by sex and self-declared labour status
eu_timeuse <- get_eurostat('tus_00selfstat', stringsAsFactors = FALSE)

eu_timeuse <-
  eu_timeuse %>%
  spread(unit, values) %>%
  mutate(
    # integer year
    year = as.integer(year(time)),
    # reformat time
    prtcp_time_min = PTP_TIME %>%
      str_pad(width = 4, side = 'left', pad = '0') %>%
      {str_c(str_sub(., 1, 2), ':', str_sub(., 3, 4))} %>%
      hm() %>% time_length(unit = 'minutes'),
    time_spent_min = TIME_SP %>%
      str_pad(width = 4, side = 'left', pad = '0') %>%
      {str_c(str_sub(., 1, 2), ':', str_sub(., 3, 4))} %>%
      hm() %>% time_length(unit = 'minutes'),
    # label activities and countries
    activity_name = label_eurostat(acl00, 'acl00', fix_duplicated = TRUE),
    country_name = label_eurostat(geo, 'geo', fix_duplicated = TRUE),
    wstatus_name = label_eurostat(wstatus, 'wstatus', fix_duplicated = TRUE)
  ) %>%
  select(country_code = geo, country_name,
         year, sex, wstatus_code = wstatus, wstatus_name,
         activity_code = acl00, activity_name,
         prtcp_rate = PTP_RT,
         prtcp_time_min, time_spent_min) %>%
  arrange(country_code, year, sex, wstatus_code, activity_code)

save(eu_timeuse, file = 'data/eu_timeuse/eu_timeuse.Rdata')

# time use survey for total population
eu_timeuse_tot <-
  eu_timeuse %>%
  filter(sex == 'T', wstatus_name == 'Population') %>%
  select(-sex, -wstatus_code, -wstatus_name)

save(eu_timeuse_tot, file = 'data/eu_timeuse/eu_timeuse_tot.Rdata')
