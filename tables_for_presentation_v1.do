	///Generation of VAT categories for Food VAT and no VAT///

cd "W:\Mexico_Fiscal_Reforms2\Hector's Model"

cd "S:\EDePo\Fiscal analysis\Mexico Demand Papers"

global raw_data8     "M:\MEXICO DATA\ENIGH\2008"
global data_pro8 	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2008"
global raw_data10     "M:\MEXICO DATA\ENIGH\2010"
global data_pro10 	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2010"
global raw_data12     "M:\MEXICO DATA\ENIGH\2012"
global data_pro12	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2012"
global raw_data14     "M:\MEXICO DATA\ENIGH\2014"
global data_pro14	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Processed Data\2014"
global results   	"S:\EDePo\Fiscal analysis\Mexico Demand Papers\Results"

cap log close
log using "$results\procat.log", replace

log off

use "S:\EDePo\Fiscal analysis\Mexico Demand Papers\Hector's Model\clave e iva_sortclave", clear

	gen exptype =. 
	
	**********************************************************************
	*1 is alcohol and tobacco; 0 is food on which VAT is levied; -1 is
	*food on which there is no VAT
	**********************************************************************
	
	replace exptype = -1 if clave>="A001" & clave<="A214" | clave=="A218"
	replace exptype = 0 if clave>="A215" & clave<="A222" & clave!="A218" | clave== "A069" | clave== "A071" | clave>="A198" & clave<="A202"
	replace exptype = 1 if clave>="A223" & clave<="A241" | clave=="T901"

	drop if exptype==.
		
	rename exptype category
	
	save "$data_pro8\tables_for_presentation.dta", replace

	///Understanding Percentage of Non-Monetary Expenditure///
	
			///***2008 Dataset***///

	
	***
	*First we append together (monthly)expenditure data that is either monetary or non-monetary
	*and we merge that with information on household location and whether they recieve benefits
	***
		
	use "$data_pro8\gastos_procat.dta", clear

	rename gas_mon gas_mon_nofood
	
	merge 1:1 folioviv foliohog procat informal using "$data_pro8\gastodiario_procat.dta"
	
	replace gas_mon_nofood=0 if gas_mon_nofood==.
	rename gas_mon gas_mon_food
	replace gas_mon_food=0 if gas_mon_food==.

	gen gas_mon = gas_mon_food+gas_mon_nofood 
	
	drop gas_mon_nofood gas_mon_food
	
	rename _merge merge_foods
	
	save "$data_pro8\gasto_all_categ.dta", replace
				
	append using "$data_pro8\nomon_procat.dta"
	
	sort folioviv foliohog procat cons_method
	
	merge m:1 folioviv foliohog using "$data_pro8\Hogares_ubica"
	
	rename _merge merge_ubica
	
	merge m:1 folioviv foliohog using "$data_pro8\hhtype_v1"
	
	rename _merge merge_hhtype
	
	decode tipogasto, generate (tipogastostring)
	replace tipogasto= 1
	replace tipogasto=2 if informal==1
	replace tipogasto=3 if tipogastostring=="Autoconsumo"
	replace tipogasto=4 if tipogastostring=="Transferencias en especie de instituciones"
	replace tipogasto=5 if tipogastostring=="Regalos provenientes de otros hogares"
	replace tipogasto=6 if tipogastostring=="Remuneraciones en especie"
	
	label define tipogasto 1 "Formal Monetary" 2 "Informal Monetary" 3 "Autoconsumption" 4 "Institutional Transfers" 5 "Other Gifts" 6 "Renum in Kind", replace
	label values tipogasto tipogasto
	
	/*gen auto_gasto = gas_mon if tipogasto==3
	replace auto_gasto = 0 if tipogasto!=3
	
	gen transfer_instit = gas_mon if tipogastostring== "Transferencias en especie de instituciones"
	replace transfer_instit = 0 if tipogastostring!= "Transferencias en especie de instituciones"

	gen transfers_inkind = gas_mon if tipogastostring== "Remuneraciones en especie"
	replace transfers_inkind = 0 if tipogastostring!= "Remuneraciones en especie"

	gen other_gifts= gas_mon if tipogastostring== "Regalos provenientes de otros hogares"
	replace other_gifts= 0 if tipogastostring!= "Regalos provenientes de otros hogares"*/
	
	merge m:1 folioviv foliohog using "$data_pro8\ingresos_mon_net_agg"
	
	gen total_inc= inc_emp+inc_semp+inc_cap+inc_tran+inc_oemp+inc_other+inc_mgains
	
	keep folioviv foliohog procat gas_mon tipogasto tipogastostring ///
	ubica_geo adultos_income opor_income opor segpop  ///
	informal cons_method inc_emp inc_semp inc_cap ///
	inc_tran inc_oemp inc_other inc_mgains total_inc rural
	
	gen benefits = 1 if adultos_income==1 | opor_income==1 | opor==1 | segpop==1
	replace benefits = 0 if benefits==.
	label var benefits "Receives Benefits"
	label define benefits 1 "Yes" 0 "No"

	label variable tipogastostring "Type of Expenditure"
		
	save "$data_pro8\nomonperc.dta", replace

	****
	*Now we will compute the percentage of monetary informal, monetary formal and all 4 types of non-monetary expenditure
	*by product category
	****
	preserve 
	
	collapse (sum) gas_mon, by (procat tipogasto) 
		
	egen exp_total = total(gas_mon), by(procat)

	gen experc= gas_mon/exp_total
	
	/*foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
		}*/
		
	drop if procat==.
	
	gen autoperc= experc if tipogasto==3
	
	gen monperc=.
	
	foreach num of numlist 1/12{
		egen test= total(experc) if procat==`num' & (tipogasto==1 | tipogasto==2)
		replace monperc=test if procat==`num'
		drop test
		}
	
	replace monperc=0 if monperc==.
		
	gen inforperc=.
	
	foreach num of numlist 1/12 {
		replace inforperc= experc/monperc if procat==`num' & tipogasto==2
		}
		
	replace inforperc=0 if inforperc==.
	gen year=2008
	
	save "$data_pro8\nomonperc_categ.dta", replace
	
	****
	*Now we will compute the percentage of monetary formal, monetary informal and all 4 types of non-monetary expenditure
	*by region and product categories
	****
	
	restore
	
	preserve
	

	*This is just to find the total informal monetary, formal monetary an autoconsumption for each product category 
	*in each region. I tried to do this with a loop, but there are too many regions/categories so collapsing to 
	*find the sum and then merging is much more efficient

	collapse (sum) gas_mon, by (procat ubica_geo tipogasto) 
 
	egen exp_total= total(gas_mon), by (procat ubica_geo)
	egen exp_total_tipo= total (gas_mon), by (procat ubica_geo tipogasto) 
		
	gen experc= exp_total_tipo/ exp_total
	
	/*gen autoperc= autocon_total/exp_total*/
	
	gen experc_mon= experc if tipogasto==1 | tipogasto==2
	egen monperc=total(experc_mon), by(procat ubica_geo)
	
	gen inforperc= exp_total_tipo/monperc if tipogasto==2
	replace inforperc=0 if inforperc==.
	
	destring ubica_geo, replace	
	gen Year=2008
	save "$data_pro8\nomonperc_ubica_geo.dta", replace  
	
	restore 
	preserve
	
	*Here we collapse by product category and household, so we can investigate how informal/formal 
	*expenditure varies with income decile, household location, benefit recipients etc.

	collapse (sum) gas_mon total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro8\nomonperc_merge_folioviv.dta"

	egen incomebins= cut(total_inc), group(10) icodes
	replace incomebins= incomebins+1
	label var incomebins "Income Decile"
	
	collapse (sum) gas_mon total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat incomebins tipogastostring cons_method)
	
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2008
	
	save "$data_pro8\nomonperc_decile.dta", replace  
	
	restore
	preserve
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro8\nomonperc_merge_folioviv.dta"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat benefits tipogastostring cons_method)
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2008
	save "$data_pro8\nomonperc_benefits.dta", replace  
	
	restore
	
	collapse (sum) gas_mon auto_gasto transfer_instit transfers_inkind other_gifts, by (procat tipogasto rural)
	
	gen exp_total=.
	
	egen grouping=group(procat rural)
	
	foreach num of numlist 1/24 {
		egen test = total(gas_mon) if grouping==`num'
		replace exp_total = test if grouping== `num'
		drop test
	}

	gen experc=.
	
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
		}
	/*there isn't enough variation in rural and urban for this to work in the 08 dataset*/
		
	save "$data_pro8\nonmonperc_rural.dta", replace

		///***2010 Dataset***///

		
	use "$data_pro10\gastos_procat.dta", clear

	rename gas_mon gas_mon_nofood
	
	merge 1:1 folioviv foliohog procat informal using "$data_pro10\gastodiario_procat.dta"
	
	replace gas_mon_nofood=0 if gas_mon_nofood==.
	rename gas_mon gas_mon_food
	replace gas_mon_food=0 if gas_mon_food==.

	gen gas_mon = gas_mon_food+gas_mon_nofood 
	
	drop gas_mon_nofood gas_mon_food
	
	rename _merge merge_foods
	
	save "$data_pro10\gasto_all_categ.dta", replace
				
	append using "$data_pro10\nomon_procat.dta"
	
	sort folioviv foliohog procat cons_method
	
	merge m:1 folioviv foliohog using "$data_pro10\Hogares_ubica"
	
	rename _merge merge_ubica
	
	merge m:1 folioviv foliohog using "$data_pro10\hhtype_v1"
	
	rename _merge merge_hhtype
	
	rename tipogasto tipogastostring
	
	gen auto_gasto = gas_mon if tipogastostring== "1"
	replace auto_gasto = 0 if tipogastostring!= "1"
	
	gen transfer_instit = gas_mon if tipogastostring== "4"
	replace transfer_instit = 0 if tipogastostring!= "4"

	gen transfers_inkind = gas_mon if tipogastostring== "2"
	replace transfers_inkind = 0 if tipogastostring!= "2"

	gen other_gifts= gas_mon if tipogastostring== "3"
	replace other_gifts= 0 if tipogastostring!= "3"
	
	merge m:1 folioviv foliohog using "$data_pro10\ingresos_mon_net_agg"
	
	gen total_inc= inc_emp+inc_semp+inc_cap+inc_tran+inc_oemp+inc_other+inc_mgains
	
	keep folioviv foliohog procat gas_mon tipogastostring ///
	ubica_geo adultos_income opor_income opor segpop auto_gasto transfer_instit ///
	transfers_inkind other_gifts informal cons_method inc_emp inc_semp inc_cap ///
	inc_tran inc_oemp inc_other inc_mgains total_inc
	
	gen benefits = 1 if adultos_income==1 | opor_income==1 | opor==1 | segpop==1
	replace benefits = 0 if benefits==.
	label var benefits "Receives Benefits"
	label define benefits 1 "Yes" 0 "No"
	
	replace tipogastostring= "Informal Monetary" if tipogastostring=="" & cons_method==1
	replace tipogastostring= "Formal Monetary" if tipogastostring=="" & cons_method==0
	replace tipogastostring= "Autoconsumption" if tipogastostring=="1"
	replace tipogastostring= "Other Gifts" if tipogastostring=="3"
	replace tipogastostring= "Renum in Kind" if tipogastostring=="2"
	replace tipogastostring= "Institution Transfers" if tipogastostring== "4"

	label variable tipogastostring "Type of Expenditure"
		
	save "$data_pro10\nomonperc.dta", replace

	****
	*Now we will compute the percentage of monetary informal, monetary formal and all 4 types of non-monetary expenditure
	*by product category
	****
	preserve 
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat tipogasto cons_method) 
		
	gen exp_total=.
	
	foreach num of numlist 1/12 {
		egen test = total(gas_mon) if procat==`num'
		replace exp_total = test if procat== `num'
		drop test
	}

	gen experc=.
	
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
		}
		
	drop if procat==.
	
	gen autoperc= experc if auto_gasto!=0
	
	gen monperc=.
	
	foreach num of numlist 1/12 {
		egen test= total(experc) if  procat==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if procat==`num'
		drop test
		}
	replace monperc=0 if monperc==.
		
	gen inforperc=.
	
	foreach num of numlist 1/12 {
		replace inforperc= experc/monperc if procat==`num' & tipogastostring== "Informal Monetary"
		}
	replace inforperc=0 if inforperc==.
	gen year=2010
	save "$data_pro10\nomonperc_categ.dta", replace
	
	****
	*Now we will compute the percentage of monetary formal, monetary informal and all 4 types of non-monetary expenditure
	*by region and product categories
	****
	
	restore
	
	preserve
	

	*This is just to find the total informal monetary, formal monetary an autoconsumption for each product category 
	*in each region. I tried to do this with a loop, but there are too many regions/categories so collapsing to 
	*find the sum and then merging is much more efficient

	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat ubica_geo)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total
	
	save "$data_pro10\nomonperc_merge_ubica.dta", replace
 
	restore
	preserve
	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat folioviv)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total

	save "$data_pro10\nomonperc_merge_folioviv.dta", replace

	restore
	preserve
	
	*Here we collapse by product category and location. We use this to find means/sd etc. of key 
	*stats across regions by product category
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat ubica_geo tipogastostring cons_method)
	
	merge m:1 procat ubica_geo using "$data_pro10\nomonperc_merge_ubica.dta"
 
 	save "$data_pro10\nomonperc_ubica_geo.dta", replace 
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen inforperc= moninf_total/exp_total 
	replace inforperc=0 if inforperc==.
	
	destring ubica_geo, replace	
	gen Year=2010
	save "$data_pro10\nomonperc_ubica_geo.dta", replace  
	
	restore 
	preserve
	
	*Here we collapse by product category and household, so we can investigate how informal/formal 
	*expenditure varies with income decile, household location, benefit recipients etc.

	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (procat folioviv tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro10\nomonperc_merge_folioviv.dta"

	egen incomebins= cut(total_inc), group(10) icodes
	replace incomebins= incomebins+1
	label var incomebins "Income Decile"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat incomebins tipogastostring cons_method)
	
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2010
	save "$data_pro10\nomonperc_decile.dta", replace  
	
	restore
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro10\nomonperc_merge_folioviv.dta"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat benefits tipogastostring cons_method)
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2010
	save "$data_pro10\nomonperc_benefits.dta", replace  
	
	
	///***2012 Dataset***///
		
	use "$data_pro12\gastos_procat.dta", clear
	
	merge 1:1 folioviv foliohog procat tipogastostring using "$data_pro12\gastopersona_procat.dta"
	
	rename _merge merge_gasto
	rename gas_mon gas_mon_monet 
	gen gas_mon= gas_mon_monet+gas_nm_mon ///because there are two types of gas_tri for monetary and non-monetary in the raw data, we combine them hear on the premise that one of the two categories must be 0
	
	save "$data_pro12\gasto_all_categ.dta", replace
					
	sort folioviv foliohog procat tipogastostring 
	
	merge m:1 folioviv foliohog using "$data_pro12\Hogares_ubica"
	
	rename _merge merge_ubica
	
	merge m:1 folioviv foliohog using "$data_pro12\hhtype_v1"
	
	rename _merge merge_hhtype
	
	merge m:1 folioviv foliohog using "$data_pro12\ingresos_mon_net_agg"
	
	gen total_inc= inc_emp+inc_semp+inc_cap+inc_tran+inc_oemp+inc_other+inc_mgains
	
	keep folioviv foliohog procat gas_mon tipogastostring ///
	ubica_geo adultos_income opor_income opor segpop auto_gasto transfer_instit ///
	transfers_inkind other_gifts cons_method inc_emp inc_semp inc_cap ///
	inc_tran inc_oemp inc_other inc_mgains total_inc ambito front
	
	gen benefits = 1 if adultos_income==1 | opor_income==1 | opor==1 | segpop==1
	replace benefits = 0 if benefits==.
	label var benefits "Receives Benefits"
	label define benefits 1 "Yes" 0 "No"
	
	label variable tipogastostring "Type of Expenditure"
		
	save "$data_pro12\nomonperc.dta", replace

	****
	*Now we will compute the percentage of monetary informal, monetary formal and all 4 types of non-monetary expenditure
	*by product category
	****
	preserve 
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat tipogasto) 
		
	gen exp_total=.
	
	foreach num of numlist 1/12 {
		egen test = total(gas_mon) if procat==`num'
		replace exp_total = test if procat== `num'
		drop test
	}

	gen experc=.
	
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
		}
		
	drop if procat==.
	
	gen autoperc= experc if auto_gasto!=0
	
	gen monperc=.
	
	foreach num of numlist 1/12 {
		egen test= total(experc) if  procat==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if procat==`num'
		drop test
		}
	replace monperc=0 if monperc==.
		
	gen inforperc=.
	
	foreach num of numlist 1/12 {
		replace inforperc= experc/monperc if procat==`num' & tipogastostring== "Informal Monetary"
		}
	replace inforperc=0 if inforperc==.
	gen year=2012	
	save "$data_pro12\nomonperc_categ.dta", replace
	
	****
	*Now we will compute the percentage of monetary formal, monetary informal and all 4 types of non-monetary expenditure
	*by region and product categories
	****
	
	restore
	
	preserve
	

	*This is just to find the total informal monetary, formal monetary an autoconsumption for each product category 
	*in each region. I tried to do this with a loop, but there are too many regions/categories so collapsing to 
	*find the sum and then merging is much more efficient

	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat ubica_geo)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total

	save "$data_pro12\nomonperc_merge_ubica.dta", replace
 
	restore
	preserve
	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat folioviv)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total

	save "$data_pro12\nomonperc_merge_folioviv.dta", replace

	restore
	preserve
	
	*Here we collapse by product category and location. We use this to find means/sd etc. of key 
	*stats across regions by product category
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat ubica_geo tipogastostring)
	
	merge m:1 procat ubica_geo using "$data_pro12\nomonperc_merge_ubica.dta"
 
 	save "$data_pro12\nomonperc_ubica_geo.dta", replace 
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen inforperc= moninf_total/exp_total 
	replace inforperc=0 if inforperc==.
	
	gen Year=2012
		
	save "$data_pro12\nomonperc_ubica_geo.dta", replace  
	
	restore 
	preserve
	
	*Here we collapse by product category and household, so we can investigate how informal/formal 
	*expenditure varies with income decile, household location, benefit recipients etc.

	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro12\nomonperc_merge_folioviv.dta"

	egen incomebins= cut(total_inc), group(10) icodes
	replace incomebins= incomebins+1
	label var incomebins "Income Decile"
	
		collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat incomebins tipogastostring cons_method)
	
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2012
	save "$data_pro12\nomonperc_decile.dta", replace  
	
	restore
	preserve 
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro12\nomonperc_merge_folioviv.dta"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat benefits tipogastostring cons_method)
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2012
	save "$data_pro12\nomonperc_benefits.dta", replace  

	restore
	preserve
	
	collapse (sum) gas_mon auto_gasto transfer_instit transfers_inkind other_gifts, by (procat ambito tipogasto)
				
	egen grouping=group(procat ambito)

	gen exp_total=.
	foreach num of numlist 1/24 {
		egen test = total(gas_mon) if grouping==`num'
		replace exp_total = test if grouping== `num'
		drop test
	}

	gen experc=.
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
	}

	gen monperc=.
	foreach num of numlist 1/24 {
		egen test= total(experc) if  grouping==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if grouping==`num'
		drop test
	}
	replace monperc=0 if monperc==.
	
	gen inforperc=.
	foreach num of numlist 1/24 {
		replace inforperc= experc/monperc if grouping==`num' & tipogastostring== "Informal Monetary"
	}
	replace inforperc=0 if inforperc==.
	
	gen infperctotal=.
	foreach num of numlist 1/24 {
	replace infperctotal= experc if grouping==`num' & tipogastostring== "Informal Monetary"
	}
	replace infperctotal=0 if infperctotal==.
		
	drop if ambito=="".
	drop if procat==12 | procat==.
	gen year=2012
	save "$data_pro12\nonmonperc_ambito.dta", replace
	
	restore
	
	collapse (sum) gas_mon auto_gasto transfer_instit transfers_inkind other_gifts, by (procat tipogasto front)
		
	gen exp_total=.
		
	egen grouping=group(procat front)
		
	foreach num of numlist 1/24 {
		egen test = total(gas_mon) if grouping==`num'
		replace exp_total = test if grouping== `num'
		drop test
	}

	gen experc=.
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
	}

	gen monperc=.
	foreach num of numlist 1/24 {
		egen test= total(experc) if  grouping==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if grouping==`num'
		drop test
	}
	replace monperc=0 if monperc==.
	
	gen inforperc=.
	foreach num of numlist 1/24 {
		replace inforperc= experc/monperc if grouping==`num' & tipogastostring== "Informal Monetary"
	}
	replace inforperc=0 if inforperc==.
	
	gen infperctotal=.
	foreach num of numlist 1/24 {
	replace infperctotal= experc if grouping==`num'  & tipogastostring== "Informal Monetary"
		}
	replace infperctotal=0 if infperctotal==.
	
	drop if front==.
	drop if procat==12 | procat==.
	gen year=2012

	save "$data_pro12\nonmonperc_front.dta", replace
	

	///***2014 Dataset***///
		
	use "$data_pro14\gastos_procat.dta", clear
	
	merge 1:1 folioviv foliohog procat tipogastostring using "$data_pro14\gastopersona_procat.dta"
	
	rename _merge merge_gasto
	rename gas_mon gas_mon_monet 
	gen gas_mon= gas_mon_monet+gas_nm_mon ///because there are two types of gas_tri for monetary and non-monetary in the raw data, we combine them hear on the premise that one of the two categories must be 0
	
	save "$data_pro14\gasto_all_categ.dta", replace
					
	sort folioviv foliohog procat tipogastostring 
	
	merge m:1 folioviv foliohog using "$data_pro14\Hogares_ubica"
	
	rename _merge merge_ubica
	
	merge m:1 folioviv foliohog using "$data_pro14\hhtype_v1"
	
	rename _merge merge_hhtype
	
	merge m:1 folioviv foliohog using "$data_pro14\ingresos_mon_net_agg"
	
	gen total_inc= inc_emp+inc_semp+inc_cap+inc_tran+inc_oemp+inc_other+inc_mgains
	
	keep folioviv foliohog procat gas_mon tipogastostring ///
	ubica_geo adultos_income opor_income opor segpop auto_gasto transfer_instit ///
	transfers_inkind other_gifts cons_method inc_emp inc_semp inc_cap ///
	inc_tran inc_oemp inc_other inc_mgains total_inc ambito front
	
	gen benefits = 1 if adultos_income==1 | opor_income==1 | opor==1 | segpop==1
	replace benefits = 0 if benefits==.
	label var benefits "Receives Benefits"
	label define benefits 1 "Yes" 0 "No"
	
	label variable tipogastostring "Type of Expenditure"
		
	save "$data_pro14\nomonperc.dta", replace

	****
	*Now we will compute the percentage of monetary informal, monetary formal and all 4 types of non-monetary expenditure
	*by product category
	****
	preserve 
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat tipogasto) 
		
	gen exp_total=.
	
	foreach num of numlist 1/12 {
		egen test = total(gas_mon) if procat==`num'
		replace exp_total = test if procat== `num'
		drop test
	}

	gen experc=.
	
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
		}
		
	drop if procat==.
	
	gen autoperc= experc if auto_gasto!=0
	
	gen monperc=.
	
	foreach num of numlist 1/12 {
		egen test= total(experc) if  procat==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if procat==`num'
		drop test
		}
	replace monperc=0 if monperc==.
		
	gen inforperc=.
	
	foreach num of numlist 1/12 {
		replace inforperc= experc/monperc if procat==`num' & tipogastostring== "Informal Monetary"
		}
	replace inforperc=0 if inforperc==.
	gen year=2014	
	save "$data_pro14\nomonperc_categ.dta", replace
	
	****
	*Now we will compute the percentage of monetary formal, monetary informal and all 4 types of non-monetary expenditure
	*by region and product categories
	****
	
	restore
	
	preserve
	

	*This is just to find the total informal monetary, formal monetary an autoconsumption for each product category 
	*in each region. I tried to do this with a loop, but there are too many regions/categories so collapsing to 
	*find the sum and then merging is much more efficient

	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat ubica_geo)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total
	
	save "$data_pro14\nomonperc_merge_ubica.dta", replace
 
	restore
	preserve
	
	gen monfor= gas_mon if tipogastostring== "Formal Monetary"
	gen moninf= gas_mon if tipogastostring== "Informal Monetary"
	gen autocon= gas_mon if tipogastostring== "Autoconsumption"
	
	collapse (sum) gas_mon monfor moninf autocon, by (procat folioviv)
	
	rename gas_mon exp_total
	rename monfor monfor_total
	rename moninf moninf_total
	rename autocon autocon_total

	save "$data_pro14\nomonperc_merge_folioviv.dta", replace

	restore
	preserve
	
	*Here we collapse by product category and location. We use this to find means/sd etc. of key 
	*stats across regions by product category
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts, by (procat ubica_geo tipogastostring)
	
	merge m:1 procat ubica_geo using "$data_pro14\nomonperc_merge_ubica.dta"
 
 	save "$data_pro14\nomonperc_ubica_geo.dta", replace 
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen inforperc= moninf_total/exp_total 
	replace inforperc=0 if inforperc==.
	
	gen Year=2014
		
	save "$data_pro14\nomonperc_ubica_geo.dta", replace  
	
	restore 
	preserve
	
	*Here we collapse by product category and household, so we can investigate how informal/formal 
	*expenditure varies with income decile, household location, benefit recipients etc.

	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro14\nomonperc_merge_folioviv.dta"

	egen incomebins= cut(total_inc), group(10) icodes
	replace incomebins= incomebins+1
	label var incomebins "Income Decile"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat incomebins tipogastostring cons_method)
	
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2014
	save "$data_pro14\nomonperc_decile.dta", replace  
	
	restore
	preserve 
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other benefits, ///
	by (folioviv procat tipogastostring cons_method)
	
	merge m:1 procat folioviv using "$data_pro14\nomonperc_merge_folioviv.dta"
	
	collapse (sum) gas_mon auto_gasto transfer_instit ///
	transfers_inkind other_gifts total_inc inc_emp inc_semp ///
	exp_total monfor_total moninf_total autocon_total ///
	(max) inc_cap inc_tran inc_oemp inc_mgains inc_other, ///
	by (procat benefits tipogastostring cons_method)
		
	gen experc= gas_mon/ exp_total
	
	gen autoperc= autocon_total/exp_total 
	
	gen monperc= (monfor_total+moninf_total)/exp_total
	replace monperc=0 if monperc==.
		
	gen infperctotal= moninf_total/exp_total 
	replace infperctotal=0 if infperctotal==.
	
	gen inforperc= moninf_total/(monfor_total+moninf_total)
	replace inforperc=0 if inforperc==.
	gen Year=2014
	save "$data_pro14\nomonperc_benefits.dta", replace  

	restore
	preserve
	
	collapse (sum) gas_mon auto_gasto transfer_instit transfers_inkind other_gifts, by (procat tipogasto ambito)
		
	gen exp_total=.
		
	egen grouping=group(procat ambito)
		
	foreach num of numlist 1/24 {
		egen test = total(gas_mon) if grouping==`num'
		replace exp_total = test if grouping== `num'
		drop test
	}

	gen experc=.
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
	}

	gen monperc=.
	foreach num of numlist 1/24 {
		egen test= total(experc) if  grouping==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if grouping==`num'
		drop test
	}
	replace monperc=0 if monperc==.
	
	gen inforperc=.
	foreach num of numlist 1/24 {
		replace inforperc= experc/monperc if grouping==`num' & tipogastostring== "Informal Monetary"
	}
	replace inforperc=0 if inforperc==.
	
		gen infperctotal=.
	foreach num of numlist 1/24 {
	replace infperctotal= experc if grouping==`num' & tipogastostring== "Informal Monetary"
		}
	replace infperctotal=0 if infperctotal==.
		
	drop if ambito=="".
	drop if procat==12 | procat==.
	gen year=2014
	save "$data_pro14\nonmonperc_ambito.dta", replace
	
	restore
	
	collapse (sum) gas_mon auto_gasto transfer_instit transfers_inkind other_gifts, by (procat tipogasto front)
		
	gen exp_total=.
		
	egen grouping=group(procat front)
		
	foreach num of numlist 1/24 {
		egen test = total(gas_mon) if grouping==`num'
		replace exp_total = test if grouping== `num'
		drop test
	}

	gen experc=.
	foreach x of varlist gas_mon auto_gasto transfer_instit transfers_inkind other_gifts {
		replace experc = `x' / exp_total if `x'!=0
	}

	gen monperc=.
	foreach num of numlist 1/24 {
		egen test= total(experc) if  grouping==`num' & (tipogastostring=="Formal Monetary" | tipogastostring=="Informal Monetary")
		replace monperc= test if grouping==`num'
		drop test
	}
	replace monperc=0 if monperc==.
	
	gen inforperc=.
	foreach num of numlist 1/24 {
		replace inforperc= experc/monperc if grouping==`num' & tipogastostring== "Informal Monetary"
	}
	replace inforperc=0 if inforperc==.
	
	gen infperctotal=.
	foreach num of numlist 1/24 {
	replace infperctotal= experc if grouping==`num'  & tipogastostring== "Informal Monetary"
		}
	replace infperctotal=0 if infperctotal==.
	
	drop if front==.
	drop if procat==12 | procat==.
		
	gen year=2014
	save "$data_pro14\nonmonperc_front.dta", replace
	
	///table generating code///
	
	//For Excel Exporting//
	
		**% of Autoconsumption, Monetary Consumption and Informal Purchases (of total monetary) by Categories**

	use "$data_pro14\nomonperc_categ.dta", replace
	append using "$data_pro12\nomonperc_categ.dta"
	append using "$data_pro10\nomonperc_categ.dta"
	append using "$data_pro8\nomonperc_categ.dta"
	drop if procat==12 | procat==.
	
	preserve
	keep if tipogastostring=="Informal Monetary"
	
	keep procat year inforperc
	
	rename inforperc y
	forma y* %4.2f
	
	reshape wide y, i(procat) j(year)
	
	label var procat "Demand System Category"
	
	label var y2008 2008
	label var y2010 2010
	label var y2012 2012
	label var y2014 2014
	
	export excel using "$results\ExpenditureTypes.xlsx",  firstrow(varlabels) sheet(1.Informal_Share) sheetrep
	
	restore
	preserve
	
	keep if tipogastostring=="Autoconsumption"
	
	keep procat year autoperc
	
	rename autoperc y
	forma y* %4.2f
	
	reshape wide y, i(procat) j(year)
	
	label var procat "Demand System Category"
	label var y2008 2008
	label var y2010 2010
	label var y2012 2012
	label var y2014 2014

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(2.Autocon_Share) sheetrep

	restore
	
	keep if tipogastostring=="Formal Monetary"
	
	keep procat year monperc
	
	rename monperc y
	forma y* %4.2f
	
	reshape wide y, i(procat) j(year)
	
	label var procat "Demand System Category"
	label var y2008 2008
	label var y2010 2010
	label var y2012 2012
	label var y2014 2014
	

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(3.Monetary_Share) sheetrep	
	
	**Stats by Ubica_geo of % Autoconsumption, Monetary Consumption and Informal Purchases (of total monetary) by Categories**
	
	use "$data_pro14\nomonperc_ubica_geo.dta", replace
	append using "$data_pro12\nomonperc_ubica_geo.dta"
	append using "$data_pro10\nomonperc_ubica_geo.dta"
	append using "$data_pro8\nomonperc_ubica_geo.dta"
	drop if procat==12
	
	preserve
	
	keep if tipogastostring=="Autoconsumption"
	
	keep procat Year autoperc
	
	egen mean=mean(autoperc), by(procat Year)
	egen sd=sd(autoperc), by(procat Year)
	egen min=min(autoperc), by(procat Year)
	egen max=max(autoperc), by(procat Year)

	drop autoperc
	
	collapse (mean) mean sd min max, by(Year procat)
	
	reshape wide mean sd min max, i(procat) j(Year)
	
	label var procat "Demand System Category"
	export excel using "$results\ExpenditureTypes.xlsx",  firstrow(varlabels) sheet(4.autoperc_stats) sheetrep
	
	restore
	preserve
	
	keep if tipogastostring=="Informal Monetary"
	
	keep procat Year inforperc
	
	egen mean=mean(inforperc), by(procat Year)
	egen sd=sd(inforperc), by(procat Year)
	egen min=min(inforperc), by(procat Year)
	egen max=max(inforperc), by(procat Year)

	drop inforperc
	
	collapse (mean) mean sd min max, by(Year procat)
	
	reshape wide mean sd min max, i(procat) j(Year)
	
	label var procat "Demand System Category"
	export excel using "$results\ExpenditureTypes.xlsx",  firstrow(varlabels) sheet(5.inforperc_stats) sheetrep
	
	restore
	
	keep if tipogastostring=="Formal Monetary"
	
	keep procat Year monperc
	
	egen mean=mean(monperc), by(procat Year)
	egen sd=sd(monperc), by(procat Year)
	egen min=min(monperc), by(procat Year)
	egen max=max(monperc), by(procat Year)

	drop monperc
	
	collapse (mean) mean sd min max, by(Year procat)
	
	reshape wide mean sd min max, i(procat) j(Year)
	
	label var procat "Demand System Category"

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(5.monperc_stats)	sheetrep
	
	**Overview of Percentage of Expenditure via different mechanisms for 4 different waves**

	use "$data_pro14\nomonperc_categ.dta", clear
		keep procat experc tipogastostring
		drop if procat==12 | procat==.

		gen tipogasto = 1
		replace tipogasto = 2 if tipogastostring=="Informal Monetary"
		replace tipogasto = 3 if tipogastostring=="Autoconsumption"
		replace tipogasto = 4 if tipogastostring=="Institution Transfers"
		replace tipogasto = 5 if tipogastostring=="Other Gifts"
		replace tipogasto = 6 if tipogastostring=="Renum in Kind"
		
		drop tipogastostring
		
		reshape wide experc, i(procat) j(tipogasto)
		
		rename experc1 formal_monetary
		rename experc2 informal_monetary 
		rename experc3 autoconsumption
		rename experc4 institution_transfers
		rename experc5 other_gifts
		rename experc6 renumeration_in_kind

export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(6.2014_experc) sheetrep
	
	use "$data_pro12\nomonperc_categ.dta", clear
		keep procat experc tipogastostring
		drop if procat==12 | procat==.
	
		gen tipogasto = 1
		replace tipogasto = 2 if tipogastostring=="Informal Monetary"
		replace tipogasto = 3 if tipogastostring=="Autoconsumption"
		replace tipogasto = 4 if tipogastostring=="Institution Transfers"
		replace tipogasto = 5 if tipogastostring=="Other Gifts"
		replace tipogasto = 6 if tipogastostring=="Renum in Kind"
		
		drop tipogastostring
		
		reshape wide experc, i(procat) j(tipogasto)
		
		rename experc1 formal_monetary
		rename experc2 informal_monetary 
		rename experc3 autoconsumption
		rename experc4 institution_transfers
		rename experc5 other_gifts
		rename experc6 renumeration_in_kind
				
		export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(7.2012experc) sheetrep
	
	use "$data_pro10\nomonperc_categ.dta", clear
		keep procat experc tipogastostring
		drop if procat==12 | procat==.

		gen tipogasto = 1
		replace tipogasto = 2 if tipogastostring=="Informal Monetary"
		replace tipogasto = 3 if tipogastostring=="Autoconsumption"
		replace tipogasto = 4 if tipogastostring=="Institution Transfers"
		replace tipogasto = 5 if tipogastostring=="Other Gifts"
		replace tipogasto = 6 if tipogastostring=="Renum in Kind"
		
		drop tipogastostring
		
		reshape wide experc, i(procat) j(tipogasto)
		
		rename experc1 formal_monetary
		rename experc2 informal_monetary 
		rename experc3 autoconsumption
		rename experc4 institution_transfers
		rename experc5 other_gifts
		rename experc6 renumeration_in_kind
				
		export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(8.2010experc) sheetrep
		
		use "$data_pro8\nomonperc_categ.dta", clear
		keep procat experc tipogastostring
		drop if procat==12 | procat==.
	
		gen tipogasto = 1
		replace tipogasto = 2 if tipogastostring=="Informal Monetary"
		replace tipogasto = 3 if tipogastostring=="Autoconsumption"
		replace tipogasto = 4 if tipogastostring=="Institution Transfers"
		replace tipogasto = 5 if tipogastostring=="Other Gifts"
		replace tipogasto = 6 if tipogastostring=="Renum in Kind"
		
		drop tipogastostring
		
		reshape wide experc, i(procat) j(tipogasto)
		
		rename experc1 formal_monetary
		rename experc2 informal_monetary 
		rename experc3 autoconsumption
		rename experc4 institution_transfers
		rename experc5 other_gifts
		rename experc6 renumeration_in_kind
				
		export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(9.2008experc) sheetrep		

		**Informality in Income Deciles (1= lowest 10=highest) 

use "$data_pro14\nomonperc_decile.dta", clear		
	foreach var of varlist inforperc infperctotal{ 	
	use "$data_pro14\nomonperc_decile.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' incomebins procat Year
	reshape wide `var', i(procat) j(incomebins)
	save "$data_pro14\nomonperc_decileshape.dta", replace
	
	use "$data_pro12\nomonperc_decile.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' incomebins procat Year
	reshape wide `var', i(procat) j(incomebins)
	save "$data_pro12\nomonperc_decileshape.dta", replace
	
	use "$data_pro10\nomonperc_decile.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' incomebins procat Year
	reshape wide `var', i(procat) j(incomebins)
	save "$data_pro10\nomonperc_decileshape.dta", replace
	
	use "$data_pro8\nomonperc_decile.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' incomebins procat Year
	reshape wide `var', i(procat) j(incomebins)
	save "$data_pro8\nomonperc_decileshape.dta", replace
	
	use "$data_pro14\nomonperc_decileshape.dta", clear
	append using "$data_pro12\nomonperc_decileshape.dta"
	append using "$data_pro10\nomonperc_decileshape.dta"
	append using "$data_pro8\nomonperc_decileshape.dta"
	
	tostring procat, g(procat1)
	
	rename `var'1 one
	rename `var'2 two
	rename `var'3 three
	rename `var'4 four
	rename `var'5 five
	rename `var'6 six
	rename `var'7 seven
	rename `var'8 eight
	rename `var'9 nine
	rename `var'10 ten
	
	reshape wide procat1 , i(one two three four five six seven eight nine ten) j(Year)
		
		gen year=.
		foreach num of numlist 2008 2010 2012 2014{
		replace year= `num' if procat1`num'!="". 
		}
		
		keep year procat one two three four five six seven eight nine ten
		sort procat year
		order procat year one two three four five six seven eight nine ten
		
	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(10.`var'_decile) sheetrep		
}
	
**Informality Conditional on Whether receives benefits or not**

use "$data_pro14\nomonperc_benefits.dta", clear

foreach var of varlist inforperc infperctotal{ 	
	use "$data_pro14\nomonperc_benefits.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' benefits procat Year
	reshape wide `var', i(procat) j(benefits)
	save "$data_pro14\nomonperc_benefitsshape.dta", replace
	
	use "$data_pro12\nomonperc_benefits.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' benefits procat Year
	reshape wide `var', i(procat) j(benefits)
	save "$data_pro12\nomonperc_benefitsshape.dta", replace
	
	use "$data_pro10\nomonperc_benefits.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' benefits procat Year
	reshape wide `var', i(procat) j(benefits)
	save "$data_pro10\nomonperc_benefitsshape.dta", replace
	
	use "$data_pro8\nomonperc_benefits.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' benefits procat Year
	reshape wide `var', i(procat) j(benefits)
	save "$data_pro8\nomonperc_benefitsshape.dta", replace
	
	use "$data_pro14\nomonperc_benefitsshape.dta", clear
	append using "$data_pro12\nomonperc_benefitsshape.dta"
	append using "$data_pro10\nomonperc_benefitsshape.dta"
	append using "$data_pro8\nomonperc_benefitsshape.dta"
	
	rename `var'0 no_benefits
	rename `var'1 benefits
	
	
	reshape wide no_benefits benefits , i(procat) j(Year)
	label var procat "Demand System Category"

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(11.`var'_benefits) sheetrep		

	}
		**Informality in Rural vs Urban areas**

	use "$data_pro14\nonmonperc_ambito.dta", replace	
	foreach var of varlist inforperc infperctotal{ 	
	use "$data_pro14\nonmonperc_ambito.dta", replace	
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' ambito procat year
	reshape wide `var', i(procat) j(ambito) string
	save "$data_pro14\nonmonperc_ambitoshape.dta", replace
	
	use "$data_pro12\nonmonperc_ambito.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' ambito procat year
	reshape wide `var', i(procat) j(ambito) string
	save "$data_pro12\nonmonperc_ambitoshape.dta", replace
	
	use "$data_pro14\nonmonperc_ambitoshape.dta", clear
	append using "$data_pro12\nonmonperc_ambitoshape.dta"
	
	rename `var'U urban
	rename `var'R rural
	
	reshape wide urban rural , i(procat) j(year)
	label var procat "Demand System Category"

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(12.`var'_ambito) sheetrep		

	}
		**Informality (pct of Monetary and Total) in Border vs Non-Border areas**

		use "$data_pro14\nonmonperc_front.dta", replace	
	foreach var of varlist inforperc infperctotal{ 	
	use "$data_pro14\nonmonperc_front.dta", replace	
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' front procat year
	reshape wide `var', i(procat) j(front) 
	save "$data_pro14\nonmonperc_frontshape.dta", replace
	
	use "$data_pro12\nonmonperc_front.dta", clear
	drop if procat==12 | procat==.
	drop if tipogastostring!="Informal Monetary"
	keep `var' front procat year
	reshape wide `var', i(procat) j(front) 
	save "$data_pro12\nonmonperc_frontshape.dta", replace
	
	use "$data_pro14\nonmonperc_frontshape.dta", clear
	append using "$data_pro12\nonmonperc_frontshape.dta"
	
	rename `var'0 no_border
	rename `var'1 border
	
	reshape wide no_border border , i(procat) j(year)
	label var procat "Demand System Category"

	export excel using "$results\ExpenditureTypes.xlsx", firstrow(varlabels) sheet(13.`var'_front) sheetrep		

	}
	
	//For Stata use or Latex Exporting//
	
	**% of Autoconsumption, Monetary Consumption and Informal Purchases (of total monetary) by Categories**
	
	use "$data_pro14\nomonperc_categ.dta", clear
	append using "$data_pro12\nomonperc_categ.dta"
	append using "$data_pro10\nomonperc_categ.dta"
	append using "$data_pro8\nomonperc_categ.dta"
	drop if procat==12
	
		table procat year, c(max autoperc) format(%4.2f)
		table procat year, c(max monperc) format(%4.2f)
		table procat year, c(max inforperc) format(%4.2f)

	
 	**Stats by Ubica_geo of % Autoconsumption, Monetary Consumption and Informal Purchases (of total monetary) by Categories**

	use "$data_pro14\nomonperc_ubica_geo.dta", clear
	append using "$data_pro12\nomonperc_ubica_geo.dta"
	append using "$data_pro10\nomonperc_ubica_geo.dta"
	append using "$data_pro8\nomonperc_ubica_geo.dta"
	drop if procat==12
			
		table Year, by(procat) c(mean autoperc sd autoperc min autoperc max autoperc) format(%4.2f) 
		table Year, by(procat) c(mean monperc sd monperc min monperc max monperc) format(%4.2f) 
		table Year, by(procat) c(mean inforperc sd inforperc min inforperc max inforperc) format(%4.2f) 
	
	**Overview of Percentage of Expenditure via different mechanisms**
	
	use "$data_pro14\nomonperc_categ.dta", replace
		table procat tipogastostring, c (mean experc) format(%4.2f)
	use "$data_pro12\nomonperc_categ.dta", replace
		table procat tipogastostring, c (mean experc) format(%4.2f)
	use "$data_pro10\nomonperc_categ.dta", replace
		table procat tipogastostring, c (mean experc) format(%4.2f)
	use "$data_pro8\nomonperc_categ.dta", replace
		table procat tipogastostring, c (mean experc) format(%4.2f)	

	**Informality in Income Deciles (1= lowest 10=highest) and Whether receives benefits or not**
	use "$data_pro14\nomonperc_decile.dta", replace
	append using "$data_pro12\nomonperc_decile.dta"
	append using "$data_pro10\nomonperc_decile.dta"
	append using "$data_pro8\nomonperc_decile.dta"
	drop if procat==12

	table Year incomebins, by(procat) c(mean infperctotal) format(%4.2f)
	table Year incomebins, by(procat) c(mean inforperc) format(%4.2f)

	use "$data_pro14\nomonperc_benefits.dta", replace	
	append using "$data_pro12\nomonperc_benefits.dta"
	append using "$data_pro10\nomonperc_benefits.dta"
	append using "$data_pro8\nomonperc_benefits.dta"
		drop if procat==12
		
	table Year benefits,by(procat)  c(mean infperctotal) format(%4.2f)
	table Year benefits,by(procat)  c(mean inforperc) format(%4.2f)
		
	**Informality in Rural vs Urban areas**
	use "$data_pro14\nonmonperc_ambito.dta", replace
	append using "$data_pro12\nonmonperc_ambito.dta"

		*of total expenditure
		table year ambito, by(procat) c(max infperctotal) format(%4.2f)		
		*of monetary expenditure
		table year ambito, by(procat) c(max inforperc) format(%4.2f)		
		
	**Informality (pct of Monetary and Total) in Border vs Non-Border areas**
	use "$data_pro14\nonmonperc_front.dta", replace
	append using "$data_pro12\nonmonperc_front.dta"

		*of total expenditure
		table year front, by(procat) c(max infperctotal) format(%4.2f)
		*of monetary expenditure
		table year front, by(procat) c(max inforperc) format(%4.2f)

