library(dplyr)

source("data/savedate.R")

todaydate<-readRDS("data/today.rds")

allcoords <- readRDS("data/coordsshps.rds")

allzips <- readRDS("data/superzip2.rds")

allzips$latitude <- (allzips$latitude)

allzips$longitude <- (allzips$longitude)

allzips$college <- allzips$college * 100

#allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")

row.names(allzips) <- allzips$zipcode



cleantable <- allzips %>%

  select(

    FirstName = city.x,

    LastName = state.x,

#    Zipcode = zipcode,

#    Rank = rank,

    Area = centile,

#    Population = adultpop,

    Lat = latitude,

    Long = longitude,
    
    System = adultpop

  )
