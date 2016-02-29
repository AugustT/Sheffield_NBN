#################
### rnbn demo ###
#################

## Tom August ##

# The package is on CRAN so install as normal
install.packages('rnbn')

# Load the package
library(rnbn)

# Sometimes it is good to read the manual before you start
# but dont break a habit
vignette('rnbn_vignette')

# To use the gateway you need to login
browseURL('https://data.nbn.org.uk/User/Register')

# The development version can be installed
# from github
library(devtools)
install_github('ropensci/rnbn')




##################
### Logging in ###
##################

# Option 1 - Secure
occ <- getOccurrences(tvks = 'NBNSYS0000002010')

# Option 2 - Reproducible
nbnLogin(username = 'myUN',
         password = 'myPwd')

# Option 3 - A bit of both
load('login_details.rdata')
nbnLogin(username = login_details$un,
         password = login_details$pwd,
         verbose = TRUE)

# Why do we need to login?




###############################
### Searching for a species ###
###############################

### TVKS ###

# Easiest is to use a Taxon Version Key (TVK)
occ <- getOccurrences(tvks = 'NBNSYS0000002010')

### What the data looks like ###
dim(occ)
View(occ) # View only works in Rstudio

# What do all those columns mean?
browseURL('https://data.nbn.org.uk/Documentation/Web_Services/Web_Services-REST/resources/restapi/ns0_taxonObservation.html')

# It has some attributes too
# Make sure you get your permissions
View(attr(occ, 'providers'))

### Species names ###

# But often we don't know the the species TVK
# so we can search
dt <- getTVKQuery(query = "badger")

# What does this give us?
View(dt)
#Find out more here
browseURL('https://data.nbn.org.uk/Documentation/Web_Services/Web_Services-REST/resources/restapi/ns0_taxon.html')

# Some useful arguements
dt <- getTVKQuery(query = "Tropidia scita", 
                  species_only = TRUE,
                  top = TRUE) 

# And here is our TVK
dt$ptaxonVersionKey

### Using TVKs to get data ###

species <- getTVKQuery('grouse')
tvks <- unique(species$ptaxonVersionKey)

# WAIT! this is gonna be a lot of data
# occ <- getOccurrences(tvks = tvks)



#############################
### Using grid references ###
#############################

# There is a real risk to asking for too much
# Here are some ways to only get what you want

### Grid references
# If you only want data for a certain location
# us the hectad filter
occ <- getOccurrences(tvks = 'NHMSYS0000530674',
                      gridRef = 'TL3490')

# Do a few hectads
multi_hectad <- function(x){
occ <- getOccurrences(tvks = 'NHMSYS0000530674',
                      gridRef = x)
}

# Note you could parallelise here
occ_multi_hectad <- sapply(X = c('TL3490', 'TL3590', 'TL3690'),
                           FUN = multi_hectad)
occ_multi_hectad <- do.call(rbind, occ_multi_hectad)

# I recommend this approach as it is efficient

# Here is a good resource for getting grid references
browseURL('http://www.brc.ac.uk/vcgrid')




#########################
### Using group names ###
#########################

# AKA the quick way to a coffee break

# What groups are there?
groups <- listGroups()
View(groups)

# Get some data for a group
occ <- getOccurrences(group = 'reptile',
                      gridRef = 'TL3490',
                      acceptTandC = TRUE)
# YAWN #

# Or just do this
occ <- getOccurrences(gridRef = 'TL3490',
                      acceptTandC = TRUE)

# Eh?! #
# This is a result of how the APIs and
# servers are set up

# Tip: avoid using groups unless you really
# need to




################################
### Using datasets you trust ###
################################

# This doesn't work - BUG - for a good reason
datasets <- listDatasets()

# Actually better to browse online
browseURL('https://data.nbn.org.uk/Datasets')

# Use the dataset key you are interested in
occ <- getOccurrences(gridRef = 'SU68',
                      datasets = 'GA001171')

# We can also get information on the species
# that are present in a dataset
ds_species <- datasetTaxa('GA001171')
View(ds_species)




######################################
### Select data from a time period ###
######################################
# Get what you need
# increases your speed

# Here is the original data
# Use the dataset key you are interested in
system.time({
  occ <- getOccurrences(gridRef = 'SU68',
                        datasets = 'GA001171')
})


# Let's plot the years this data comes from
hist(as.numeric(format(occ$endDate, '%Y')), breaks = 5)


# Use the dataset key you are interested in
# and specify the years of interest
system.time({
  occ <- getOccurrences(gridRef = 'SU68',
                        datasets = 'GA001171',
                        startYear = 2014, 
                        endYear = 2015)
})  

# Let's plot the years this data comes from
hist(as.numeric(format(occ$endDate, '%Y')), breaks = 2)




###################
### Vice-county ###
###################

# WARNING: Big download danger

# Here are the vice-counties
VCs <- listVCs()
View(VCs)

# Here is an example that behaves
occ <- getOccurrences(VC = 'Oxfordshire',
                      tvks = 'NHMSYS0000712592',
                      datasets = 'GA001171',
                      startYear = 2014, 
                      endYear = 2015)
View(occ)

# Tip: it might be better to loop
# through grid refs if the data is
# big




######################
### Other features ###
######################

## Getting attribute data

# Get TVK for wild cat
tvkQuery <- getTVKQuery(query = 'wildcat',
                        top = TRUE)

# Now I'm going to get the data with attributes
WCresults <- getOccurrences(tvks = tvkQuery$ptaxonVersionKey,
                            startYear = 1999,
                            endYear = 1999,
                            attributes = TRUE,
                            silent = TRUE,
                            acceptTandC = TRUE)

### Hmm that was quiet ###
View(WCresults)



##############################################
### Case study: All the data for Sheffield ###
##############################################

rm(list = ls())

library(rnbn)

# Which hectads are around Sheffield 
shef_hec_tab <- read.csv('south-west-yorkshire-10km-squares.csv', stringsAsFactors = FALSE)
shef_hec <- shef_hec_tab$Square
shef_hec

# Function for doing a few hectads
# Beefed up a bit
multi_hectad <- function(x){
  # read in
  load(file = 'login_details.rdata')
  # login
  nbnLogin(username = login_details$un,
           password = login_details$pwd)
  # get data
  occ <- getOccurrences(gridRef = x,
                        startYear = 2005,
                        endYear = 2010)
  # write out
  write.table(x = occ, file = 'shef_table.csv', sep = ',', append = TRUE, col.names = TRUE)
  
  return(occ)
  
}

### Run it in series (2 hectads)
t1 <- system.time({
  s1 <- do.call(rbind, lapply(shef_hec[1:2], multi_hectad))
})

### Run in parallel
# Load libraries for parallelising
library(parallel)
library(snowfall)

# Start our (very mini) cluster (I need a new laptop)
# This uses all your cores
sfInit(parallel = TRUE, type = 'SOCK', cpus = detectCores())

# Send all our parameters and our function to the cluster
sfExportAll()

# Send the rnbn package to the cluster
sfLibrary(rnbn)

# Run our 2 hectads in parallel
# Running in parallel is silent - nothing will appear in your console
t2 <- system.time({
  s2 <- do.call(rbind, sfClusterApplyLB(shef_hec[1:2], multi_hectad))
})

# Close the cluster
sfStop()

# we can test that our results are the same
library(testthat)
expect_equal(s1, s2)

# Speed up 
t1/t2


### So lets run it for real ###
# Wait! BIG JOB

sfInit(parallel = TRUE, type = 'SOCK', cpus = detectCores())
sfExportAll()
sfLibrary(rnbn)

# Run
t3 <- system.time({
  shef_data <- do.call(rbind, sfClusterApplyLB(shef_hec, multi_hectad))
})

sfStop()

save(shef_data, file = 'data/shef_data.rdata')




##########################
### Lets have some fun ###
##########################

# Interactive visualisations are the next big thing in R
# They harness the power of the web
rm(list = ls())

# Load our data from the parallel run about
load(file = 'data/shef_data.rdata')

# Google vis
library(googleVis)

# Lets summarise the data by species
# number of records
Records <- tapply(shef_data$pTaxonName, shef_data$pTaxonName, length)

# Number od surveys 
Surveys <- tapply(shef_data$surveyKey, shef_data$pTaxonName, function(x) length(unique(x)))

# number of observers
Recorders <- tapply(shef_data$recorder, shef_data$pTaxonName, function(x) length(unique(x)))

# number of locations
Locations <- tapply(shef_data$location, shef_data$pTaxonName, function(x) length(unique(x)))

# Proportion of records at 100m
Proportion_100m <- tapply(shef_data$resolution, shef_data$pTaxonName,
                          function(x) sum(grepl('100m',x))/length(x))

# Build into a data.frame
shef_sum <- cbind(Records, Surveys, Recorders, Locations, Proportion_100m)
shef_sum <- as.data.frame(shef_sum)

# Add an explicit species column
shef_sum$Species <- row.names(shef_sum)

# Add dummy year column (needed for the plot I'm going to do)
shef_sum$Year <- 2000

# Keep species with aleast a few records
shef_sum_sub <- subset(shef_sum, Records > 500)

View(shef_sum_sub)

# Lets make a plot
M1 <- gvisMotionChart(data = shef_sum_sub,
                      timevar = 'Year',
                      idvar = 'Species',
                      xvar = 'Locations',
                      yvar = 'Proportion_100m',
                      colorvar = 'Surveys',
                      sizevar = 'Records',
                      options = list(height = 500,
                                     width = 1000))
plot(M1)

# Save out the summary data
save(shef_sum_sub, file = 'data/dataMotion.rdata')




################
### Sub-zero ###
################

### shiny app

browseURL('https://tomaugust.shinyapps.io/Sheffield_NBN/')
