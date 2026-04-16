let( (cellId cdfId)
    cellId = ddGetObj("devicestack" "spfinhv")
    ; Delete existing CDF if you want to start fresh
    when( cdfId = cdfGetBaseCellCDF(cellId)
        cdfDeleteCDF(cdfId)
    )
    cdfId = cdfCreateBaseCellCDF(cellId)
    
    ;; Create the 'nstack' parameter for the "Q" menu
    cdfCreateParam(cdfId
        ?name           "nstack"
        ?prompt         "Number of Stacked Devices"
        ?defValue       "2"
        ?type           "string"
        ?display        "t"
        ?parseAsNumber  "yes"
    )
    
    cdfSaveCDF(cdfId)
    printf("CDF for spfinhv updated successfully.\n")
)
