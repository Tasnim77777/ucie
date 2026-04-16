pcDefinePCell(
    list(ddGetObj("devicestack") "spfinhv" "schematic" "schematic")
    ( (nstack string "2") )

    let( (cv master pinMaster inst prevInst gateNet bodyNet srcNet drnNet 
          i yStep lastY curY pY nY gX bX sX textHeight busGX busBX nStackInt pinInst)
        
        cv = pcCellView
        
        ; Robust type handling for the nstack variable
        nStackInt = cond(
            (stringp(nstack) atoi(nstack))
            (fixp(nstack)    nstack)
            (t               2)
        )
        if( (nStackInt < 1) nStackInt = 1 )

        ; --- GRID & SPACING ---
        yStep = -1.25  
        pY = 0.1875    nY = -0.1875   
        gX = 0.0       bX = 0.25      sX = 0.25      
        busGX = -1.0   busBX = 1.0   
        textHeight = 0.125 
        
        master = dbOpenCellViewByType("gpdk090" "pmos1v" "symbol")
        pinMaster = dbOpenCellViewByType("basic" "iopin" "symbol")

        if( master && pinMaster then
            ; 1. Create Nets
            gateNet = dbCreateNet(cv "Gate")
            bodyNet = dbCreateNet(cv "Body")
            srcNet  = dbCreateNet(cv "Source")
            drnNet  = dbCreateNet(cv "Drain")

            ; 2. The Stack Loop
            for(i 0 nStackInt-1
                curY = i * yStep
                inst = dbCreateInst(cv master sprintf(nil "M%d" i) list(0 curY) "R0")

                dbCreateConnByName(gateNet inst "G")
                dbCreateConnByName(bodyNet inst "B")

                ; Parallel wiring to the side buses
                dbCreateLine(cv list("wire" "drawing") list(list(gX curY) list(busGX curY)))
                dbCreateLine(cv list("wire" "drawing") list(list(bX curY) list(busBX curY)))

                ; Series wiring logic
                if( i == 0 then
                    dbCreateConnByName(srcNet inst "S")
                else
                    let( (midNet)
                        midNet = dbCreateNet(cv sprintf(nil "mid_%d" i))
                        dbCreateConnByName(midNet inst "S")
                        dbCreateConnByName(midNet prevInst "D")
                        dbCreateLine(cv list("wire" "drawing") 
                            list(list(sX (i-1)*yStep + nY) list(sX i*yStep + pY)))
                    )
                )
                if( i == nStackInt-1 then dbCreateConnByName(drnNet inst "D") )
                prevInst = inst
            )

            ; 3. Vertical Bus Lines
            lastY = (nStackInt-1)*yStep
            dbCreateLine(cv list("wire" "drawing") list(list(busGX 0) list(busGX lastY)))
            dbCreateLine(cv list("wire" "drawing") list(list(busBX 0) list(busBX lastY)))

            ; 4. ALL PINS RESTORED
            
            ; --- GATE PIN ---
            pinInst = dbCreateInst(cv pinMaster "G_PIN" list(busGX 0.5) "R0")
            dbCreateConnByName(gateNet pinInst "pin")
            dbCreateLine(cv list("wire" "drawing") list(list(busGX 0.5) list(busGX 0)))
            dbCreateLabel(cv list("text" "drawing") list(busGX 0.7) "Gate" "lowerCenter" "R0" "stick" textHeight)

            ; --- BODY PIN ---
            pinInst = dbCreateInst(cv pinMaster "B_PIN" list(busBX 0.5) "R0")
            dbCreateConnByName(bodyNet pinInst "pin")
            dbCreateLine(cv list("wire" "drawing") list(list(busBX 0.5) list(busBX 0)))
            dbCreateLabel(cv list("text" "drawing") list(busBX 0.7) "Body" "lowerCenter" "R0" "stick" textHeight)

            ; --- SOURCE PIN (At the top of stack) ---
            pinInst = dbCreateInst(cv pinMaster "S_PIN" list(sX pY+0.5) "R90")
            dbCreateConnByName(srcNet pinInst "pin")
            dbCreateLine(cv list("wire" "drawing") list(list(sX pY+0.5) list(sX pY)))
            dbCreateLabel(cv list("text" "drawing") list(sX pY+0.7) "Source" "lowerCenter" "R0" "stick" textHeight)

            ; --- DRAIN PIN (At the bottom of stack) ---
            pinInst = dbCreateInst(cv pinMaster "D_PIN" list(sX lastY+nY-0.5) "R270")
            dbCreateConnByName(drnNet pinInst "pin")
            dbCreateLine(cv list("wire" "drawing") list(list(sX lastY+nY-0.5) list(sX lastY+nY)))
            dbCreateLabel(cv list("text" "drawing") list(sX lastY+nY-0.7) "Drain" "lowerCenter" "R0" "stick" textHeight)

            dbCheck(cv)
            dbSave(cv)
        )
    )
)
