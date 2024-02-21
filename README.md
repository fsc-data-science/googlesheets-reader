# googlesheets-reader
 Returns a PUBLIC google sheet's content as JSON, compatible with LiveQuery. Relies on the Ben Borgers implementation of opensheet https://github.com/benborgers/opensheet. Now also has a generalized CSV importer, best for raw githubcontent CSVs but works with any hosted CSV.

# General Hosted CSV

Use the same steps as below, but with the param `url` and the `readcsv` endpoint

```sql
with res AS (
SELECT
  livequery.live.udf_api(
    'GET',
    'https://science.flipsidecrypto.xyz/googlesheets/readcsv',
    { 'Content-Type': 'application/json' },
     { 
      'url': 'https://raw.githubusercontent.com/andrewhong5297/Crypto-Grants-Analysis/main/uploads/evm_grants.csv'
    }
  ) as result
from DUAL
)

select result:data as json_result_must_pivot from res;

```

# Google Sheets

1. Generate a Sharing link for google docs
 test data example: https://docs.google.com/spreadsheets/d/1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg/edit?usp=sharing
 
2. Identify the ID as the text after `/d/` and before `/edit`: `1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg`

3. Identify the Sheet Name (Defaults to `Sheet1` if not provided).

This API wraps Ben Borgers opensheet cloudflare worker (https://opensheet.elk.sh/) in an R Plumber API 
to isolate errors for logging and provide an additional security layer before allowing calls into LiveQuery.

# Result in Studio

This res contains details like bytes (we do enforce a maximum bytes on calls) alongside data.

```sql

with res AS (
SELECT
  livequery.live.udf_api(
    'GET',
    'https://science.flipsidecrypto.xyz/googlesheets/readsheet',
    { 'Content-Type': 'application/json' },
     { 
      'sheets_id' : '1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg', 
      'tab_name' : 'Sheet1'
    }
  ) as result
from DUAL
)

select result:data as json_result_must_pivot from res;

```
This returns a single row and single column containing the boxed JSON. 
NOTE: Extraction must occur using the Column names, and class coercion is expected.

```json
[
  {
    "Class": "Red",
    "ID": "1",
    "Value": "15"
  },
  {
    "Class": "Red",
    "ID": "2",
    "Value": "20"
  },
  {
    "Class": "Blue",
    "ID": "3",
    "Value": "8"
  },
  {
    "Class": "Blue",
    "ID": "4",
    "Value": "19"
  },
  {
    "Class": "Green",
    "ID": "5",
    "Value": "150"
  }
]
```

# Pivot & Flatten 

`LATERAL FLATTEN` can be used to convert this JSON into a tabular form. Note, you MUST
know the column names and classes to extract, SQL does not allow for dynamic column naming. 

```sql
with res AS (
SELECT
  livequery.live.udf_api(
    'GET',
    'https://science.flipsidecrypto.xyz/googlesheets/readsheet',
    { 'Content-Type': 'application/json' },
     { 
      'sheets_id' : '1isXwTpJlxMClz1Kg0tkSNMwhd8Z944IgprPULx_aqWg', 
      'tab_name' : 'Sheet1'
    }
  ) as result
from DUAL
),

data AS (
select result:data as json_result_must_pivot from res
)

SELECT
  d.value:"ID"::VARCHAR as ID, 
  TO_NUMBER(d.value:"Value") as Value, 
  d.value:"Class"::VARCHAR as Class 
    FROM
        data,
        LATERAL FLATTEN(input => data.json_result_must_pivot::VARIANT) d
        
```
 