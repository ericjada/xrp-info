# This script retrieves real-time cryptocurrency information about XRP (Ripple) 
# from the CoinMarketCap API, performs data analysis and visualization, and 
# exports the data to a CSV file. The script makes use of several R libraries 
# including httr, jsonlite, tidyverse, and ggplot2. The API call is made to the 
# CoinMarketCap API and the relevant information about XRP is extracted, 
# including its price, market capitalization, trading volume, and 24-hour 
# percentage change. The data is then saved to a CSV file, which is read back 
# into R for analysis and visualization. The script creates a line graph 
# showing XRP's price over time using the data from the CSV file.

# https://coinmarketcap.com/api/documentation/v1


# Load required libraries
library(httr)
library(jsonlite)
library(tidyverse)
library(ggplot2)

# API endpoint
url <- "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"

# API key
api_key <- "API KEY"

# API parameters
params <- list(start=1, limit=100, convert="USD", sort="market_cap_strict")

# API call
res <- GET(url, query=params, add_headers("X-CMC_Pro_API_Key"=api_key))

# Parse API response
result <- fromJSON(content(res, as="text"))

# Filter for XRP
xrp <- result$data[grep("XRP", result$data$symbol),]

# Check if xrp has at least 1 row
if (nrow(xrp) == 0) {
  stop("No XRP data found in API response")
}

# Extract relevant data
xrp_info <- data.frame(date_time = as.Date(format="%Y-%m-%d", Sys.time()),
                       symbol = xrp$symbol,
                       price = xrp$quote$USD$price,
                       market_cap = xrp$quote$USD$market_cap,
                       volume_24h = xrp$quote$USD$volume_24h,
                       percent_change_24h = xrp$quote$USD$percent_change_24h
)



# Export to csv
if (file.exists("xrp_info.csv")) {
  old_data <- read.csv("xrp_info.csv")
  write.table(rbind(old_data, xrp_info), 
              file = "xrp_info.csv", 
              col.names = FALSE, 
              row.names = FALSE, 
              append = TRUE, 
              sep = ",", quote = FALSE)
} else {
  write.table(xrp_info, 
              file = "xrp_info.csv", 
              row.names = FALSE, 
              sep = ",", quote = FALSE)
}

# Read csv file into a data frame
xrp_info_csv <- read.csv("xrp_info.csv")

# Convert date column to date format
# xrp_info_csv$date_time <- as.Date(xrp_info_csv$date, format = "%Y-%m-%d")

# Plot line graph of XRP price over time
ggplot(xrp_info_csv, aes(x = date_time, y = price)) +
  geom_line() +
  ggtitle("XRP Price over Time") +
  xlab("Date") +
  ylab("Price (USD)")
