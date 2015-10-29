******************************************************************
* This do-file 
* 	reads in the new version of ENIGH 2008-2014
* 	generates unit values to look at formal/informal consumption
*	generates unit value-quantity correlations for certain food products
*
* Created: 01/07/2015, by Yang Lu 
* This version:
******************************************************************

clear
set mem 500m

/*
THIS FILE USES ONLY CERTAIN FOOD PRODUCTS FROM THE ENIGH DATASET.
USED TO INVESTIGATE AND UNDERSTAND ANY PRICE DIFFERENTIAL BETWEEN INFORMAL AND FORMAL MARKETS
*/

cd "S:\EDePo\Fiscal analysis\Mexico Demand Papers"

global raw_data8     "M:\MEXICO DATA\ENIGH\2008"
global data_pro8	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2008"
global raw_data10     "M:\MEXICO DATA\ENIGH\2010"
global data_pro10	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2010"
global raw_data12     "M:\MEXICO DATA\ENIGH\2012"
global data_pro12	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2012"
global raw_data14     "M:\MEXICO DATA\ENIGH\2014"
global data_pro14	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2014"
global dofile   	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Do-files"
global results		"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Results"

cap log off
log using "$results\unitcorr"
log off

	***2008 DATA***

///*Generate Unit Value for specific product sold either informally or formally, for individual households*///

	use "$data_pro8\gastodiario_fpago_inf.dta", clear
	
	drop if gasto==0 | gasto==.
	drop if cantidad==0 | cantidad==.
	drop if informal==.
	
	collapse (sum) gasto cantidad (min)vat, by(clave folioviv foliohog informal) //we collapse here first in case method of payment etc. create two rows with the same household, clave and formality

	gen cantidad_inf=cantidad if informal==1
	gen cantidad_for=cantidad if informal==0

	gen unitval_hh=gasto/cantidad
	
	gen unitval_hh_inf = unitval_hh if informal==1 
	gen unitval_hh_for = unitval_hh if informal==0

	collapse (sum)  gasto cantidad_for cantidad_inf unitval_hh_inf unitval_hh_for (min)vat, by(clave folioviv foliohog) //collapse so we have one observation per HH per clave
	
	replace unitval_hh_inf=. if unitval_hh_inf==0
	replace unitval_hh_for=. if unitval_hh_for==0
	
	save "$data_pro8\gastohh_unit.dta", replace
	
	merge m:1 folioviv foliohog using "$data_pro8\Hogares_ubica.dta"

///*Now Collapse the Data at the Data at the Municipality Level. We sum up quantities across all HH but use the median for unit values to avoid outliers*///

	collapse (sum) gasto cantidad_for cantidad_inf (median) unitval_hh_inf unitval_hh_for (min) vat, by (ubica_geo clave)
	
	gen	rel_price=unitval_hh_for/unitval_hh_inf
	gen rel_quant=cantidad_for/cantidad_inf
	
	label var rel_price "relative price between formal and informal"
	label var rel_quant "relative quantity between formal and informal"
	
	save "$data_pro8\gastoubica_unit.dta", replace
	
	///*Generate Correlations and Tabulate*///
	
	mat table8 = (-9\-9\-9\-9\-9\-9\-9)

	local Y = 1
	foreach X in A004 A112 A120 A124 A176 A220 A245 {       
    corr rel_quant rel_price if clave=="`X'"
        mat A = r(C)
        mat B =A[2..2,1..1]
        mat table8[`Y',1] = B
	
	local Y = `Y'+1 
		}
	matrix rownames table8 = Tortilla Onion Chicken Tomato Coffee Coke Dinner 
	matrix colnames table8 = Correlation
	
	***2010 DATA***

///*Generate Unit Value for specific product sold either informally or formally, for individual households*///

	use "$data_pro10\gastodiario_fpago.dta", clear
	
		drop if gasto==0 | gas_mon==.
	drop if cantidad==0 | cantidad==.
	drop if informal==.
	
	collapse (sum)  gasto cantidad (min)vat, by(clave folioviv foliohog informal) //we collapse here first in case method of payment etc. create two rows with the same household, clave and formality

	gen cantidad_inf=cantidad if informal==1
	gen cantidad_for=cantidad if informal==0

	gen unitval_hh=gasto/cantidad
	
	gen unitval_hh_inf = unitval_hh if informal==1 
	gen unitval_hh_for = unitval_hh if informal==0

	collapse (sum) gasto cantidad_for cantidad_inf unitval_hh_inf unitval_hh_for (min)vat, by(clave folioviv foliohog) //collapse so we have one observation per HH per clave
	
	replace unitval_hh_inf=. if unitval_hh_inf==0
	replace unitval_hh_for=. if unitval_hh_for==0
	
	save "$data_pro10\gastohh_unit.dta", replace
	
	merge m:1 folioviv foliohog using "$data_pro10\Hogares_ubica.dta"

///*Now Collapse the Data at the Data at the Municipality Level. We sum up quantities across all HH but use the median for unit values to avoid outliers*///

	collapse (sum) gasto cantidad_for cantidad_inf (median) unitval_hh_inf unitval_hh_for (min) vat, by (ubica_geo clave)
	
	gen	rel_price=unitval_hh_for/unitval_hh_inf
	gen rel_quant=cantidad_for/cantidad_inf
	
	label var rel_price "relative price between formal and informal"
	label var rel_quant "relative quantity between formal and informal"
	
	save "$data_pro10\gastoubica_unit.dta", replace
		
///*Generate Correlations and Tabulate*///

	mat table10 = (-9\-9\-9\-9\-9\-9\-9)
		
		local Y = 1
	foreach X in A004 A112 A120 A124 A176 A220 A245 {       
    corr rel_quant rel_price if clave=="`X'"
        mat A = r(C)
        mat B =A[2..2,1..1]
        mat table10[`Y',1] = B
	
	local Y = `Y'+1 
		}
	
	matrix rownames table10 = Tortilla Onion Chicken Tomato Coffee Coke Dinner 
	matrix colnames table10 = Correlation

***2012 DATA***

///*Generate Unit Value for specific product sold either informally or formally, for individual households*///

use "$data_pro12\gastoshogares.dta", clear
	
	drop if gasto==0 | gasto==.
	drop if cantidad==0 | cantidad==.
	drop if informal==.
	
	collapse (sum) gasto  cantidad (min)vat , by(clave folioviv foliohog informal) //we collapse here first in case method of payment etc. create two rows with the same household, clave and formality

	gen cantidad_inf=cantidad if informal==1
	gen cantidad_for=cantidad if informal==0

	gen unitval_hh=gasto/cantidad
	
	gen unitval_hh_inf = unitval_hh if informal==1 
	gen unitval_hh_for = unitval_hh if informal==0
	
	collapse (sum) gasto cantidad cantidad_inf cantidad_for unitval_hh_inf unitval_hh_for (min)vat , by(clave folioviv foliohog) //collapse so we have one observation per HH per clave
	
	replace unitval_hh_inf=. if unitval_hh_inf==0
	replace unitval_hh_for=. if unitval_hh_for==0
	
	save "$data_pro12\gastohh_unit.dta", replace
	
	merge m:1 folioviv foliohog using "$data_pro12\Hogares_ubica.dta"

///*Now Collapse the Data at the Data at the Municipality Level. We sum up quantities across all HH but use the median for unit values to avoid outliers*///

	collapse (sum) gasto cantidad_for cantidad_inf (median) unitval_hh_inf unitval_hh_for (min) vat, by (ubica_geo clave)
	
	gen	rel_price=unitval_hh_for/unitval_hh_inf
	gen rel_quant=cantidad_for/cantidad_inf
	
	label var rel_price "relative price between formal and informal"
	label var rel_quant "relative quantity between formal and informal"
	
	save "$data_pro12\gastoubica_unit.dta", replace

///*Generate Correlations and Tabulate*///

mat table12 = (-9\-9\-9\-9\-9\-9\-9)
		
		local Y = 1
	foreach X in A004 A112 A120 A124 A176 A220 A245  {       
    corr rel_quant rel_price if clave=="`X'"
        mat A = r(C)
        mat B =A[2..2,1..1]
        mat table12[`Y',1] = B
	
	local Y = `Y'+1 
		}
	matrix rownames table12 = Tortilla Onion Chicken Tomato Coffee Coke Dinner 
	matrix colnames table12 = Correlation
	

	***2014 DATA***
	
	///*Generate Unit Value for specific product sold either informally or formally, for individual households*///

	use "$data_pro14\gastoshogares.dta", clear
	
	drop if gasto==0 | gasto==.
	drop if cantidad==0 | cantidad==.
	drop if informal==.
	
	collapse (sum) gasto cantidad (min)vat , by(clave folioviv foliohog informal) //we collapse here first in case method of payment etc. create two rows with the same household, clave and formality

	gen cantidad_inf=cantidad if informal==1
	gen cantidad_for=cantidad if informal==0

	gen unitval_hh=gasto/cantidad
	
	gen unitval_hh_inf = unitval_hh if informal==1 
	gen unitval_hh_for = unitval_hh if informal==0
	
	collapse (sum) gasto cantidad cantidad_inf cantidad_for unitval_hh_inf unitval_hh_for (min)vat , by(clave folioviv foliohog) //collapse so we have one observation per HH per clave
	
	replace unitval_hh_inf=. if unitval_hh_inf==0
	replace unitval_hh_for=. if unitval_hh_for==0
	
	save "$data_pro14\gastohh_unit.dta", replace
	
	merge m:1 folioviv foliohog using "$data_pro14\Hogares_ubica.dta"

	///*Now Collapse the Data at the Data at the Municipality Level. We sum up quantities across all HH but use the median for unit values to avoid outliers*///

	collapse (sum) gasto cantidad_for cantidad_inf (median) unitval_hh_inf unitval_hh_for (min) vat, by (ubica_geo clave)
	
	gen	rel_price=unitval_hh_for/unitval_hh_inf
	gen rel_quant=cantidad_for/cantidad_inf
	
	save "$data_pro14\gastoubica_unit.dta", replace
	
	///*Generate Correlations and Tabulate*///

mat table14 = (-9\-9\-9\-9\-9\-9\-9)
		
		local Y = 1
	foreach X in A004 A112 A120 A124 A176 A220 A245  {       
    corr rel_quant rel_price if clave=="`X'"
        mat A = r(C)
        mat B =A[2..2,1..1]
        mat table14[`Y',1] = B
	
	local Y = `Y'+1 
		}
	
	matrix rownames table14 = Tortilla Onion Chicken Tomato Coffee Coke Dinner 
	matrix colnames table14 = Correlation
	log on 

	mat list table8
	mat list table10
	mat list table12
	mat list table14
	
log off

