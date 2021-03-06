/*==============================================================================
purpose: 		    evaluate linkage for the NEP-PD RCT
date 
created: 		    03/04/2019
last updated: 	29/04/2019
last updated: 	21/04/2020 
author: 	    	maximiliane verfuerden
===============================================================================*/
clear
cd          "$projectdir"
capture 	  log close
log 		    using "${logdir}\04-ev_linkage_trial_3 $S_DATE.log", replace 
use 		    "${datadir}\linktable.dta", clear 
duplicates 	tag studyid, gen(dup_studyid)
********************************************************************************
*           merge in trial                    						   
********************************************************************************
merge 		  m:1 studyid using "${datadir}\populationforfft_deidentified 2.dta", keepusing(trial)
drop if		  _merge==1
gen			    unmatched =0
replace		  unmatched =1 if _merge==2
drop        _merge
drop		    tableid
********************************************************************************
*           merge in birth characteristics
********************************************************************************
merge 		  m:1 studyid using "${datadir}\all\attributedataset_randomised.dta", update keepusing(byr bayley_PDI bayley_MDI parity smokdur matage matedu alcdur apgar5m kps_fullscore iq_score centre gestage bwt multiple address_tot age_firstadd age_lastaddgrp age_lastadd fup*)
replace		  unmatched =1 if _merge==2
drop		    _merge
********************************************************************************
*           keep only those from NEP-PD RCT
********************************************************************************
keep if		trial==3
********************************************************************************
*           merge in academic year info                                
********************************************************************************
merge 		m:1 pupilreference using "${datadir}\alldatawide.dta", keepusing(*acy* obs)
drop if		_merge == 2 // some pupilrefs dont have a linked studyid (drop these) 
drop		  _merge // but keep unmatched study IDs
egen		  rct3_avg1stacyr = mean(first_acyr)
lab var		rct3_avg1stacyr "RCT 3 average first academic year"
********************************************************************************
*           are there any study ID duplicates?                           
********************************************************************************
count if	dup_studyid>0 & dup_studyid !=.
count if	studyid1=="" 
********************************************************************************
*           are there any pupil ID duplicates?                            
********************************************************************************
duplicates 	tag pupilref if pupilref!=. , gen(dup_pupilid)
count if	  dup_pupilid>0 & dup_pupilid<.
/*==============================================================================*/
save		  "${datadir}\04-ev_linkage_t3.dta", replace
log 		  close
