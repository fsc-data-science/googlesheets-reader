library(plumber)
library(httr)
library(jsonlite)

#* @apiTitle Google Sheets Reader
#* @apiDescription Returns a PUBLIC google sheet's content as JSON, compatible with LiveQuery. Relies on the 
#* Ben Borgers implementation of opensheet https://github.com/benborgers/opensheet. 
#* Also has a generalized CSV importer, best for raw githubcontent CSVs but works with any hosted CSV.

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
    list(msg = paste0("The message is: '", msg, "'"))
}

#* @param sheets_id A **PUBLIC** Google Sheet ID, e.g., 1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg
#* @param tab_name The Tab you'd like read in JSON form, e.g., Sheet1
#* @get /readsheet
function(sheets_id = '1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg', tab_name = 'Sheet1'){

  
  # Define the URL for the Google Sheet in CSV format
  url <- paste0("https://opensheet.elk.sh/", sheets_id, "/",tab_name)
  
  # Fetch the JSON data
  data <- fromJSON(url)
  
  return(data)
  
}


#* @param url A **PUBLIC** CSV file, e.g. https://raw.githubusercontent.com/username....csv
#* @get /readcsv
function(url = 'https://raw.githubusercontent.com/andrewhong5297/Crypto-Grants-Analysis/main/uploads/evm_grants.csv'){
  
  # Read everything as character to avoid EVM address class risks (0x...)
  # has to be coerced by SQL anyway 
  csv_ <- read.csv(url, colClasses = 'character')
  
  json_ <- jsonlite::toJSON(csv_, auto_unbox = TRUE)
  # Fetch the JSON data
  data <- jsonlite::fromJSON(json_)
  return(data)
  
}
