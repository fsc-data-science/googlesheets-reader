library(plumber)
library(httr)
library(jsonlite)

#* @apiTitle Google Sheets Reader
#* @apiDescription Returns a PUBLIC google sheet's content as JSON, compatible with LiveQuery. Relies on the 
#* Ben Borgers implementation of opensheet https://github.com/benborgers/opensheet

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