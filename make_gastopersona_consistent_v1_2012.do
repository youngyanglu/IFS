******************************************************************
* This do-file 
* 	reads in the new version of ENIGH 2012 AND 2014
* 	sets up the expenditure categories for the main 2012 and 2014 processed data do-file
* Created: 18/07/2015, by Yang Lu and Laura Abramovsky
* This version:
******************************************************************

/*
THIS FILE CREATES PROCESSED FILES FROM RAW FILES.
IT IS USED TO SORT OUT EXPENDITURE CATEGORIES FOR CLAVES IN THE G_person.dta FILE 
FOR BOTH ENIGH 2012 AND 2014 AS CLAVES HAVEN'T CHANGED BETWEEN YEARS
*/

***
*NB: As G_person.dta does not have information about where individuals purchased their products, 
*we have no proxy for informality and therefore we do not assign the variable informal to data
*and don't differentiate between them in the expnum 
*This is the only difference between the make_gastopersona_consistent file and the make_gasto_consistent file
***

*The origin of the the code (wehther from gastos, gastoeduca or gastodiario in the 2008 do-file) is labelled

/// Sort out expenditure categories in 2012 AND 2014 ///

     ** generate expenditure categories 1-40

    
	* gastos
	  gen     expnum="exp1"                           if (inlist(clave, "J001", "J004", "J005", "J007", "J008") | inlist(clave, "J013", "J016", "J017", "J018", "J036", "J039", "J062", "J072")) 
    replace expnum="exp31"                          if (inlist(clave, "J001", "J004", "J005", "J007", "J008") | inlist(clave, "J013", "J016", "J017", "J018", "J036", "J039", "J062", "J072")) 

    replace expnum="exp2"                           if ((clave>="E001"&clave<="E008") | inlist(clave, "E015", "E017", "T905")) 
    replace expnum="exp32"   						if ((clave>="E001"&clave<="E008") | inlist(clave, "E015", "E017", "T905")) 
	
	* gastoeduca
	replace     expnum="exp2"                       if ((clave>="E001"&clave<="E008") | inlist(clave, "E015", "E017", "T905"))
	
	* gastos
	replace expnum="exp3"                           if inlist(clave, "E029") 
    replace expnum="exp33"                          if inlist(clave, "E029") 

    replace expnum="exp4"                           if ((clave>="B001"&clave<="B007") | inlist(clave, "E013", "M001", "T902")) 
    replace expnum="exp34"                          if ((clave>="B001"&clave<="B007") | inlist(clave, "E013", "M001", "T902")) 

	* gastodiario
	replace     expnum="exp4"                 		if ((clave>="B001"&clave<="B007") | inlist(clave, "E013", "M001", "T902")) 
    replace expnum="exp34"                			if 	((clave>="B001"&clave<="B007") | inlist(clave, "E013", "M001", "T902")) 
	
	* gasto	
	replace expnum="exp5"                           if ((clave>="G002"&clave<="G006") | inlist(clave, "G011", "N006", "N007") | (clave>="N011"&clave<="N016")) 
    replace expnum="exp35"                          if ((clave>="G002"&clave<="G006") | inlist(clave, "G011", "N006", "N007") | (clave>="N011"&clave<="N016")) 

    replace expnum="exp6"                           if ((clave>="E022"&clave<="E024") | inlist(clave, "E028")) 
    replace expnum="exp36"                          if ((clave>="E022"&clave<="E024") | inlist(clave, "E028")) 

    replace expnum="exp7"                           if ((clave>="G011"&clave<="G019")) 
    replace expnum="exp37"                          if ((clave>="G011"&clave<="G019")) 


	* gastodiario
   replace expnum="exp8"                 			if ((clave>="A001"&clave<="A068") | (clave>="A072"&clave<="A197") | (clave>="A203"&clave<="A215") | inlist(clave, "A070", "A218", "A242")) 
   replace expnum="exp38"               			if ((clave>="A001"&clave<="A068") | (clave>="A072"&clave<="A197") | (clave>="A203"&clave<="A215") | inlist(clave, "A070", "A218", "A242")) 
	
	* gasto
    replace expnum="exp9"                           if inlist(clave, "E014") 
    replace expnum="exp39"                          if inlist(clave, "E014") 

    replace expnum="exp10"                          if inlist(clave, "G007") 
    replace expnum="exp40"                          if inlist(clave, "G007") 

    replace expnum="exp11"                          if inlist(clave, "L029") 
    replace expnum="exp41"                          if inlist(clave, "L029") 

    replace expnum="exp12"                          if (inlist(clave, "J009", "J010", "J014")|(clave>="J020"&clave<="J035") | inlist(clave, "J037", "J038", "J042")|(clave>="J040"&clave<="J059")| inlist(clave, "J063", "J064", "T910")) 
    replace expnum="exp42"                          if (inlist(clave, "J009", "J010", "J014")|(clave>="J020"&clave<="J035") | inlist(clave, "J037", "J038", "J042")|(clave>="J040"&clave<="J059")| inlist(clave, "J063", "J064", "T910")) 

    replace expnum="exp13"                          if inlist(clave, "J061") 
    replace expnum="exp43"                          if inlist(clave, "J061") 


	* gastodiario
    replace expnum="exp14"                			if (inlist(clave, "A069", "A071", "A216", "A217")) 
    replace expnum="exp44"                			if (inlist(clave, "A069", "A071", "A216", "A217")) 
	
	* gasto	
      replace expnum="exp15"                         if ((clave>="A198"&clave<="A202") | (clave>="A219"&clave<="A222") |(clave>="A243"&clave<="A247") |inlist(clave, "T901")) 
    replace expnum="exp45"                         if ((clave>="A198"&clave<="A202") | (clave>="A219"&clave<="A222") |(clave>="A243"&clave<="A247") |inlist(clave, "T901")) 
	
	* gastodiario
    replace expnum="exp15"                			if ((clave>="A198"&clave<="A202") | (clave>="A219"&clave<="A222") | (clave>="A243"&clave<="A247") | inlist(clave, "T901")) 
    replace expnum="exp45"                			if ((clave>="A198"&clave<="A202") | (clave>="A219"&clave<="A222") | (clave>="A243"&clave<="A247") | inlist(clave, "T901")) 
	
	* gasto
	replace expnum="exp16"                         if ((clave>="C001"&clave<="C024") | inlist(clave, "T903") |(clave>="G008"&clave<="G010") |(clave>="G020"&clave<="G022")|inlist(clave, "T909", "F007", "T911") |(clave>="I001"&clave<="I026")|(clave>="K001"&clave<="K044")|(clave>="L001"&clave<="L022")  |inlist(clave, "T907")) 
    replace expnum="exp46"                         if ((clave>="C001"&clave<="C024") | inlist(clave, "T903") |(clave>="G008"&clave<="G010") |(clave>="G020"&clave<="G022")|inlist(clave, "T909", "F007", "T911") |(clave>="I001"&clave<="I026")|(clave>="K001"&clave<="K044")|(clave>="L001"&clave<="L022")  |inlist(clave, "T907")) 

    replace expnum="exp17"                         if ((clave>="D001"&clave<="D026") | inlist(clave, "T904", "E019", "E020", "E021")) 
    replace expnum="exp47"                         if ((clave>="D001"&clave<="D026") | inlist(clave, "T904", "E019", "E020", "E021")) 

    replace expnum="exp18"                         if ((clave>="E009"&clave<="E012") | clave=="M005" |clave=="T915" |(clave>="M007"&clave<="M011")|(clave>="N008"&clave<="N010")) 
    replace expnum="exp48"                         if ((clave>="E009"&clave<="E012") | clave=="M005" |clave=="T915" |(clave>="M007"&clave<="M011")|(clave>="N008"&clave<="N010")) 

    replace expnum="exp19"                         if ((clave>="E023"&clave<="E025") | inlist(clave, "E027", "E028", "T912")|(clave>="E032"&clave<="E034")|(clave>="L023"&clave<="L028")|(clave>="N003"&clave<="N005")) 
    replace expnum="exp49"                         if ((clave>="E023"&clave<="E025") | inlist(clave, "E027", "E028", "T912")|(clave>="E032"&clave<="E034")|(clave>="L023"&clave<="L028")|(clave>="N003"&clave<="N005")) 

    replace expnum="exp20"                         if ((clave>="F010"&clave<="F014") | inlist(clave, "T906", "T913", "M006")|(clave>="M002"&clave<="M004")|(clave>="M012"&clave<="M018")) 
    replace expnum="exp50"                         if ((clave>="F010"&clave<="F014") | inlist(clave, "T906", "T913", "M006")|(clave>="M002"&clave<="M004")|(clave>="M012"&clave<="M018")) 

    replace expnum="exp21"                         if ((clave>="H001"&clave<="H136") | inlist(clave, "T908")) 
    replace expnum="exp51"                         if ((clave>="H001"&clave<="H136") | inlist(clave, "T908")) 

    replace expnum="exp22"                         if ((clave>="N001"&clave<="N002") | inlist(clave, "T914")) 
    replace expnum="exp52"                         if ((clave>="N001"&clave<="N002") | inlist(clave, "T914")) 

    replace expnum="exp23"                          if (inlist(clave, "J002", "J003", "J006", "J011", "J012") | inlist(clave, "J015", "J019", "J040", "J041", "J043", "J060")|(clave>="J065"&clave<="J071")) 
    replace expnum="exp53"                          if (inlist(clave, "J002", "J003", "J006", "J011", "J012") | inlist(clave, "J015", "J019", "J040", "J041", "J043", "J060")|(clave>="J065"&clave<="J071")) 

    replace expnum="exp24"                         if ((clave>="F007"&clave<="F009")) 
    replace expnum="exp54"                         if ((clave>="F007"&clave<="F009")) 

    replace expnum="exp25"                          if  inlist(clave, "R005", "R006", "F001", "F003", "F006", "R008", "F009", "F004") 
    replace expnum="exp55"                          if  inlist(clave, "R005", "R006", "F001", "F003", "F006", "R008", "F009", "F004")

	* gastodiario
    replace expnum="exp26"           	  		if (inlist(clave, "A228", "A231", "A234", "A232", "A238")) 
    replace expnum="exp56"                		if (inlist(clave, "A228", "A231", "A234", "A232", "A238")) 
	
	* gastodiario	
    replace expnum="exp27"               		 if (inlist(clave, "A226", "A237")) 
    replace expnum="exp57"               		 if (inlist(clave, "A226", "A237")) 
		
	* gastodiario	
    replace expnum="exp28"               		 if (inlist(clave, "A223", "A225", "A227", "A229", "A230", "A233", "A235", "A236")) 
    replace expnum="exp58"               		 if (inlist(clave, "A223", "A225", "A227", "A229", "A230", "A233", "A235", "A236")) 

	* gastodiario	
    replace expnum="exp29"               		 if (inlist(clave, "A224")) 
    replace expnum="exp59"               		if (inlist(clave, "A224")) 

	* gastodiario	
    replace expnum="exp30"               		 if (inlist(clave, "A239", "A240", "A241")) 
    replace expnum="exp60"                		if (inlist(clave, "A239", "A240", "A241")) 

	***Categories from MEXTAX***
	
	/** SET UP THE MEXTAX EXPENDITURE CATEGORIES */

	* untaxed food
	gen procat = 1 if (clave>="A001" & clave<="A197") |(clave>="A203" & clave<="A218") | clave=="A242"
	* taxed food
	replace procat = 2 if (clave>="A198" & clave<="A202") |(clave>="A219" & clave<="A222") |(clave>="A243" & clave<="A247") | clave=="T901"
	* alcohol and tobacco (taxed)
	replace procat = 3 if (clave>="A223" & clave<="A241")
	* taxed clothing and footware
	replace procat = 4 if (clave>="H001" & clave<="H136") | clave=="T908"
	* taxed hhold goods, services, communications and electronics
	replace procat = 5 if (clave>="C001" & clave<="C024") | inlist(clave, "G009", "R003", "R005" "R006" "R008" "F004" "F006" "F007" "F009")| (clave>="G014" & clave<="G016")| (clave>="I001" & clave<="I026")| (clave>="K001" & clave<="K045")| (clave>="L001" & clave<="L022")| clave=="T903"| clave=="T907" | clave=="T910" | clave=="T912" | clave=="R001"
	* non-taxed household goods, services etc
	replace procat = 6 if (clave>="G005" & clave<="G013") | clave=="R002"| clave=="R004"
	* taxed trasport goods, services and petrol
	replace procat = 7 if (clave>="F010" & clave<="F017") |(clave>="M002" & clave<="M004") | clave=="M006" |(clave>="M012" & clave<="M018") | clave=="T902"| clave=="T906"| clave=="T914"
	* untaxed trasport goods, services and petrol
	replace procat = 8 if (clave>="B001" & clave<="B007") |clave=="M001" | clave=="E013"
	* gen non-taxed health and educ
	replace procat = 9 if (clave>="J020" & clave<="J035") |(clave>="J044" & clave<="J059") | clave=="J001"| clave=="J004"| clave=="J005"| clave=="J007"| clave=="J008"| clave=="J013"| clave=="J016"| clave=="J017"| clave=="J018"| clave=="J036"| clave=="J039"| clave=="J062"| clave=="J072"| clave=="J009"| clave=="J010"| clave=="J014"| clave=="J037"| clave=="J038"| clave=="J042"| clave=="J059"| clave=="J063"| clave=="J064"| clave=="T910" | clave=="E014" | clave=="E016"
	* gen taxed personal goods and services
	replace procat = 10 if (clave>="J065" & clave<="J071") |(clave>="D001" & clave<="D026") | clave=="E017"| clave=="E020"| clave=="E021"| clave=="T905"| clave=="J002"| clave=="J003"| clave=="J006"| clave=="J011"| clave=="J012"| clave=="J015"| clave=="J019"| clave=="J040"| clave=="J041"| clave=="J043"| clave=="J060"| clave=="J061"| clave=="T904"
	* gen leisure and hotels
	replace procat = 11 if (clave>="E022" & clave<="E034") | (clave>="L023" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="T913"
	* gen other
	replace procat = 12 if clave=="N001" | clave=="N002" | clave=="T913"

	label var procat "MEXTAX expenditure categories"
	label define procat 1 "Non-VAT food" 2 "VAT food and meals out" 3 "VAT and Excise Drinks and Tobacco" 4 "VAT clothing and footwear"	5 "VAT Hhold goods, services and communications" 6 "Non-VAT Hhold goods, services and communications" 7 "VAT transport services and petrol"	8 "Non-VAT transport services" 9 "Non-VAT health and education" 10 "VAT health and personal goods and services" 11 "Leisure and hotels"
	label values procat procat
		
    ** NOW DO THE CATEGORIES FOR SPENDING THAT APPEAR IN NATIONAL ACCOUNTS ***
	
	*gasto
	
	    ** generate expenditure categories
    gen clave_letter=substr(clave, 1,1)
	
	gen exptype = .
	replace exptype = 4 if clave>="C001" & clave<="C019"
	replace exptype = 10 if clave>="C020" & clave<="C022"
	replace exptype = 3 if clave>="C023" & clave<="C024"

	replace exptype = 10 if clave>="D001" & clave<="D026"

	replace exptype = 8 if clave>="E001" & clave<="E021"
	replace exptype = 7 if clave>="E022" & clave<="E034"

	replace exptype = 10 if clave>="F001" & clave<="F009"
	replace exptype = 6 if clave>="F010" & clave<="F017"

	replace exptype = 3 if clave_letter=="G"

	replace exptype = 2 if clave>="H001" & clave<="H136"

	replace exptype = 4 if clave_letter=="I"

	replace exptype = 5 if clave_letter=="J"

	replace exptype = 4 if clave>="K001" & clave<="K037"
	replace exptype = 4 if clave>="K037" & clave<="K045"

	replace exptype = 7 if clave_letter=="L"

	replace exptype = 6 if clave_letter=="M"

	replace exptype = 10 if clave>="N001" & clave<="N002"
	replace exptype = 9 if clave>="N003" & clave<="N005" | /*gastodiario*/ clave>="A243" & clave<="A247"
	replace exptype = 7 if clave=="N006"
	replace exptype = 10 if clave=="N007"
	replace exptype = 6 if clave=="N008"
	replace exptype = 10 if clave=="N009"

	replace exptype = - 1 if clave=="T901" | /*gastodiario*/(clave>="A001" & clave<="A214")
	replace exptype = 6 if clave=="T902"
	replace exptype = 4 if clave=="T903"
	replace exptype =10 if clave=="T904"
	replace exptype = 7 if clave=="T905"
	replace exptype = 6 if clave=="T906"| /*gastodiario*/ clave>="B001"
	replace exptype = 6 if clave_letter=="B" /*non-mon*/
	replace exptype = 4 if clave=="T907"
	replace exptype = 2 if clave=="T909"
	replace exptype = 4 if clave=="T910"
	replace exptype = 5 if clave=="T911"
	replace exptype = 4 if clave=="T912"
	replace exptype = 7 if clave=="T913"
	replace exptype = 6 if clave=="T914"
	replace exptype = 10 if clave=="T915"
	
	*gastodiario
	replace exptype = 0 if clave>="A215" & clave<="A222"
	replace exptype = 1 if clave>="A223" & clave<="A241"


	gen     expcat="VATzero_health_and_medicine"            if clave_letter=="J" & vat==2
    replace expcat="VATexempted_health_and_medicine"        if clave_letter=="J" & (vat==1|vat==.)
    replace expcat="VATable_health_and_medicine"            if clave_letter=="J" & vat==3
    replace expcat="petrol_gasoline"        if inlist(clave, "F007","F008", "F009")
    replace expcat="telecoms"               if inlist(clave, "F001","R005","F005","F006","F007","F009","F008","F009")
    replace expcat="lottery"                if inlist(clave, "E031")
    replace expcat="transfers"              if inlist(clave, "N011", "N012", "N013","N014", "N015", "N016")
    replace expcat="cigarettes"             if inlist(clave, "A239")
    replace expcat="othertobacco"           if inlist(clave, "A240", "A241")
    replace expcat="public_transport"       if clave_letter=="B"
    replace expcat="informal_beer"          if inlist(clave, "A224")
    replace expcat="informal_alc_under14"  if inlist(clave, "A228", "A231" ,"A234", "A232", "A238")
    replace expcat="informal_alc_14_20"    if inlist(clave, "A226", "A237")
    replace expcat="informal_alc_over20"   if inlist(clave, "A223", "A225", "A227", "A229", "A230", "A233", "A235", "A236")
    replace expcat="education"              if inlist(clave, "E001","E002","E003", "E004","E005", "E006","E007")
    replace expcat="informal_VATable_food"  if expcat=="" & clave_letter=="A" & vat==3
    replace expcat="VATzero_food"        if expcat=="" & clave_letter=="A" & inlist(vat,2)
    replace expcat="VATexempted_other_nonfood"       if expcat=="" & clave_letter!="A" & inlist(vat,1,.)
    replace expcat="informal_VATable_other_nonfood" if expcat=="" & clave_letter!="A" & inlist(vat,3)
