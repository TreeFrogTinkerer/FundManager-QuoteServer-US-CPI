###########################################################################
# Price Update for CPI for FundManager Import
# v3
#     -- New Choices -- All Data or last 3 years
#     -- Limitation: Start Year is hard coded for CPI-U data
#
# For Common Series / Name: https://data.bls.gov/cgi-bin/surveymost?bls
# Using API v1 (Limitations here: https://www.bls.gov/developers/api_faqs.htm#register1)
# 4/19/2026
###########################################################################

# Create date/time stamp filename and initialize the csv headers
#$Filename = Get-Date -Format "MM-dd-yyyy-hhmmsstt" 
$Filename = "CPIFM-BLS.csv"
#Add-Content -Path $Filename  -Value "SYMB,MM/DD/YY,NAV"
New-Item -Path $Filename -ItemType "File" -Value "SYMB,MM/DD/YY,NAV" -Force

# BLS Website for v1 API
$uri = 'https://api.bls.gov/publicAPI/v1/timeseries/data/'  

# Gets Current Year
$ThisYear = get-date -Format yyyy
   
    # Creates the year chunks
    $SpanYears = $ThisYear - 1913
    $ChunkCountRaw = $SpanYears/10
    $ChunkCount = [math]::ceiling($ChunkCountRaw)

    # Loops through the 10 year chunks to download data
   For ($i=0; $i -le $ChunkCount-1; $i++){
        $start = 1913 + $i*10
        $end = $start + 9
        if ($end -gt $ThisYear){
            $end=$ThisYear}
    
        # Assembles the JSON string for choosen options above per the API 
        $Body = "{`"seriesid`":[`"CUUR0000SA0`",`"CUUR0000AA0`",`"CWUR0000SA0`",`"CUURS49DSA0`",`"SUUR0000SA0`"],`"startyear`":`""+$start+"`",`"endyear`":`""+$end+"`"}"
        write-host $Body
        # Sends the requests and stores the returned data
        $response = Invoke-WebRequest -Uri $uri -Method 'POST' -Headers @{'Content-Type' = 'application/json; charset=utf-8'} -Body $Body
        # Ingest into Powershell from JSON
        $CPI = $response | ConvertFrom-Json


        foreach ($ii in $CPI.Results.series){
            # Reformats and writes each line to the csv file ready for import into FM
            foreach ($iii in $ii.data){
                $mo = $iii.period -replace "M",""
                $data= $ii.SeriesID+","+$mo+"/01/"+$iii.year+","+$iii.value
                Add-Content -Path $Filename  -Value $data
                #$data
                Start-Sleep -Milliseconds 125
            }
        }
    }


