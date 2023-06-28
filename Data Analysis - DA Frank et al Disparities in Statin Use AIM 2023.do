/*

DESCRIPTION: Stata do file to analyze analytic dataset created from DATA PROCESSING FILE. Analyses described in Disparities in Guideline-Recommended Statin Use for Prevention of Atherosclerotic Cardiovascular Disease by Race, Ethnicity, and Gender: A Nationally Representative Cross-Sectional Analysis of Adults in the United States. Frank DA, Johnson AE, Hausmann LRM , Gellad WF, Roberts ET, and Vajravelu RK. Ann Intern Med. Jul 25 2023. https://doi.org/10.7326/M23-0720. 

DO FILE AUTHOR: Ravy K. Vajravelu MD MSCE -- University of Pittsburgh 

LAST UPDATED: June 28, 2023
*/

******
* DIRECTORIES
******

local folder = "[yourFolder]"

cd "`folder'"
global main `c(pwd)'

cd "`folder'/Data processing"
global project `c(pwd)'

cd "`folder'/Data processing/lookup"
global lookup `c(pwd)'

cd "`folder'/Data processing/temp"
global temp `c(pwd)'

cd "`folder'/Data processing/tables"
global tables `c(pwd)'



***********
* DESCRIPTIVE STATISTICS
***********

cd "$project"
use "statinDisparities_nhanes_analyticDataset.dta", clear


*** TOTAL NHANES 21-75	

	svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing)

	count if age >= 21 & age <= 75
	gen generalCohort = 1 if age >= 21 & age <= 75
	svy: total generalCohort
	
	
*** STATIN ELIGIBLE	

	*** Primary prevention

		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing)
		
		count if primary_prevention == 1
		svy: total primary_prevention 
		
		* Indications
	
			gen ldlCriteria = 0
			replace ldlCriteria = 1 if ldl190OrMore == 1 & age >= 21 & age <= 75
			svy, subpop(if primary_prevention == 1): tab ldlCriteria 
			gen diabetesCriteria = 0
			replace diabetesCriteria = 1 if diabetesBinary == 1 & age >= 40 & age <= 75
			svy, subpop(if primary_prevention == 1): tab diabetesCriteria 
			gen ascvdCriteria = 0
			replace ascvdCriteria = 1 if ascvd_riskPct >= 7.5 & ascvd_riskPct != .
			svy, subpop(if primary_prevention == 1): tab ascvdCriteria
			gen ascvd20OrMore = 0
			replace ascvd20OrMore = 1 if ascvd_riskPct >= 20 & ascvd_riskPct != .
			svy, subpop(if primary_prevention == 1): tab ascvd20OrMore
	
	*** Secondary prevention

		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing)
		
		count if secondary_prevention == 1
		svy: total secondary_prevention 
	
		* Indications
		
			svy, subpop(if secondary_prevention == 1): tab angina
				gen anginaOnly = 0
				replace anginaOnly = 1 if angina == 1 & chd_binary != 1 & mi_binary != 1 & stroke_binary != 1
				svy, subpop(if secondary_prevention == 1): tab anginaOnly
			svy, subpop(if secondary_prevention == 1): tab chd_binary
			svy, subpop(if secondary_prevention == 1): tab mi_binary
			svy, subpop(if secondary_prevention == 1): tab stroke_binary
			

		
***********
* TABLE 1 (unweighted, then weighted calculations, but only reported weighted)
***********	

cd "$project"
use "statinDisparities_nhanes_analyticDataset.dta", clear


*** Total NHANES 21-75 (won't show in Table 1, only in Supplement)

	svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
	
	* Demographics
		tab raceEthnicity female if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab raceEthnicity female, ci
		summ age if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean age

	
	* Disease severity
		summ ascvd_riskPct if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean ascvd_riskPct
		summ chd_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean chd_binary
		summ mi_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean mi_binary
		summ stroke_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean stroke_binary
		tab famHx_mi if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab famHx_mi, ci
		
		summ bmi if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean bmi

		summ cancerBinary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean cancerBinary
		summ ckd if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean ckd
			summ egfr_mdrd if age >= 21 & age <= 75
			svy, subpop(if age >= 21 & age <= 75): mean egfr_mdrd
		summ copdEtcBinary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean copdEtcBinary
		summ diabetesBinary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean diabetesBinary
			summ a1c if age >= 21 & age <= 75
			svy, subpop(if age >= 21 & age <= 75): mean a1c
		summ heartFailureBinary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean heartFailureBinary
		summ liverEverBinary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean liverEverBinary
		
		summ num_meds if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean num_meds
		summ fibrate if age >= 21 & age <= 75 == 1
		svy, subpop(if age >= 21 & age <= 75): mean fibrate
		tab numStatinIntolRf if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean numStatinIntolRf
			
		summ hc_visits_last_year if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean hc_visits_last_year
		tab hosp_last_year_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab hosp_last_year_binary, ci
		
		summ readyToEatFood if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): mean readyToEatFood
		tab atLeastModActivity if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab atLeastModActivity, ci
		tab self_preceived_health if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab self_preceived_health, ci
		
		
	* System factors
		tab health_insurance_cat if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab health_insurance_cat, ci
		tab rx_coverage_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab rx_coverage_binary, ci
		tab formal_education_level if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab formal_education_level, ci
		tab fam_pov_level_cat if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab fam_pov_level_cat, ci
		tab marital_status_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab marital_status_binary, ci
		tab place_for_hc_binary if age >= 21 & age <= 75
		svy, subpop(if age >= 21 & age <= 75): tab place_for_hc_binary, ci


	
*** Primary prevention

	svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
	
	* Statin type
		svy, subpop(if primary_prevention == 1 & statin == 1): tab statinName, ci
	
	* Demographics
		tab raceEthnicity female if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab raceEthnicity female, ci
		summ age if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean age

	
	* Disease severity
		summ ascvd_riskPct if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean ascvd_riskPct
		summ chd_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean chd_binary
		summ mi_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean mi_binary
		summ stroke_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean stroke_binary
		tab famHx_mi if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab famHx_mi, ci
		
		summ bmi if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean bmi

		summ cancerBinary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean cancerBinary
		summ ckd if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean ckd
			summ egfr_mdrd if primary_prevention == 1
			svy, subpop(if primary_prevention == 1): mean egfr_mdrd
		summ copdEtcBinary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean copdEtcBinary
		summ diabetesBinary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean diabetesBinary
			summ a1c if primary_prevention == 1
			svy, subpop(if primary_prevention == 1): mean a1c
		summ heartFailureBinary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean heartFailureBinary
		summ liverEverBinary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean liverEverBinary
		
		summ num_meds if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean num_meds
		summ fibrate if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean fibrate
		tab numStatinIntolRf if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean numStatinIntolRf
			
		summ hc_visits_last_year if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean hc_visits_last_year
		tab hosp_last_year_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab hosp_last_year_binary, ci
		
		summ readyToEatFood if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): mean readyToEatFood
		tab atLeastModActivity if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab atLeastModActivity, ci
		tab self_preceived_health if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab self_preceived_health, ci
		
		
	* System factors
		tab health_insurance_cat if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab health_insurance_cat, ci
		tab rx_coverage_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab rx_coverage_binary, ci
		tab formal_education_level if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab formal_education_level, ci
		tab fam_pov_level_cat if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab fam_pov_level_cat, ci
		tab marital_status_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab marital_status_binary, ci
		tab place_for_hc_binary if primary_prevention == 1
		svy, subpop(if primary_prevention == 1): tab place_for_hc_binary, ci
	
	
*** Secondary prevention

		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing)
		
	* Statin type
		svy, subpop(if secondary_prevention == 1 & statin == 1): tab statinName, ci
	
	* Demographics
		tab raceEthnicity female if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab raceEthnicity female, ci
		summ age if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean age

	
	* Disease severity
		summ ascvd_riskPct if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean ascvd_riskPct
		summ chd_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean chd_binary
		summ mi_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean mi_binary
		summ stroke_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean stroke_binary
		tab famHx_mi if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab famHx_mi, ci
		
		summ bmi if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean bmi

		summ cancerBinary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean cancerBinary
		summ ckd if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean ckd
			summ egfr_mdrd if secondary_prevention == 1
			svy, subpop(if secondary_prevention == 1): mean egfr_mdrd
		summ copdEtcBinary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean copdEtcBinary
		summ diabetesBinary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean diabetesBinary
			summ a1c if secondary_prevention == 1
			svy, subpop(if secondary_prevention == 1): mean a1c
		summ heartFailureBinary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean heartFailureBinary
		summ liverEverBinary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean liverEverBinary
		
		summ num_meds if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean num_meds
		summ fibrate if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean fibrate
		tab numStatinIntolRf if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean numStatinIntolRf
			
		summ hc_visits_last_year if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean hc_visits_last_year
		tab hosp_last_year_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab hosp_last_year_binary, ci
		
		summ readyToEatFood if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): mean readyToEatFood
		tab atLeastModActivity if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab atLeastModActivity, ci
		tab self_preceived_health if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab self_preceived_health, ci
		
		
	* System factors
		tab health_insurance_cat if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab health_insurance_cat, ci
		tab rx_coverage_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab rx_coverage_binary, ci
		tab formal_education_level if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab formal_education_level, ci
		tab fam_pov_level_cat if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab fam_pov_level_cat, ci
		tab marital_status_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab marital_status_binary, ci
		tab place_for_hc_binary if secondary_prevention == 1
		svy, subpop(if secondary_prevention == 1): tab place_for_hc_binary, ci
	
	
***********
*** TABLE 2: UNADJUSTED STATIN-USE 
***********

	gen raceEthnicityGender = raceEthnicity if female == 0
	replace raceEthnicityGender = raceEthnicity + 7 if female == 1
	label define raceEthnicityGender_name 1 "Mexican American men" 2 "Other Hispanic men" 3 "Non-Hispanic White men" 4 "Non-Hispanic Black men" 6 "Non-Hispanic Asian men" 7 "Other and Multi-Racial men" 8 "Mexican American women" 9 "Other Hispanic women" 10 "Non-Hispanic White women" 11 "Non-Hispanic Black women" 13 "Non-Hispanic Asian women" 14 "Other and Multi-Racial women"
	
	*** Primary prevention
	
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing)
	
		svy, subpop(if primary_prevention == 1): proportion statin
		
		svy, subpop(if (primary_prevention == 1) & female == 0): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 1): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 2): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 3): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 4): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 6): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 7): proportion statin 
		
		svy, subpop(if (primary_prevention == 1) & female == 1): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 8): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 9): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 10): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 11): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 13): proportion statin 
		svy, subpop(if (primary_prevention == 1) & raceEthnicityGender == 14): proportion statin 
		
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 1): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 2): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 3): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 4): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 6): proportion statin
		svy, subpop(if (primary_prevention == 1) & raceEthnicity == 7): proportion statin
		
		
	*** Secondary prevention
	
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing)
	
		svy, subpop(if secondary_prevention == 1): proportion statin
		
		svy, subpop(if (secondary_prevention == 1) & female == 0): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 1): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 2): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 3): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 4): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 6): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 7): proportion statin 
		
		svy, subpop(if (secondary_prevention == 1) & female == 1): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 8): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 9): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 10): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 11): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 13): proportion statin 
		svy, subpop(if (secondary_prevention == 1) & raceEthnicityGender == 14): proportion statin 
		
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 1): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 2): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 3): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 4): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 6): proportion statin
		svy, subpop(if (secondary_prevention == 1) & raceEthnicity == 7): proportion statin	
	

	
************
* MULTIPLE IMPUTATION
************

cd "$project"
use "statinDisparities_nhanes_analyticDataset.dta", clear

set seed 412

mdesc age ascvd_riskPct ascvd_riskPct_noRace famHx_mi bmi cancerBinary ckd egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds numStatinIntolRf hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary place_for_hc_binary pcsk9 fibrate if primary_prevention == 1, ab(32)

mdesc age ascvd_riskPct ascvd_riskPct_noRace chd_binary mi_binary stroke_binary famHx_mi bmi cancerBinary ckd egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds numStatinIntolRf hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary place_for_hc_binary pcsk9 fibrate if secondary_prevention == 1, ab(32)

mi set mlong
mi misstable summarize age ascvd_riskPct ascvd_riskPct_noRace chd_binary mi_binary stroke_binary famHx_mi bmi cancerBinary ckd egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds numStatinIntolRf hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary place_for_hc_binary pcsk9 fibrate

mi misstable patterns age ascvd_riskPct ascvd_riskPct_noRace chd_binary mi_binary stroke_binary famHx_mi bmi cancerBinary ckd egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds numStatinIntolRf hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary place_for_hc_binary pcsk9 fibrate 

display age ascvd_riskPct ascvd_riskPct_noRace chd_binary mi_binary stroke_binary famHx_mi bmi cancerBinary ckd egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds numStatinIntolRf hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary place_for_hc_binary pcsk9 fibrate

mi register imputed ascvd_riskPct ascvd_riskPct_noRace chd_binary mi_binary stroke_binary famHx_mi bmi cancerBinary egfr_mdrd copdEtcBinary diabetesBinary a1c heartFailureBinary liverEverBinary num_meds hc_visits_last_year hosp_last_year_binary readyToEatFood atLeastModActivity self_preceived_health health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat marital_status_binary 

mi impute chained (regress) ascvd_riskPct (regress) ascvd_riskPct_noRace (logit) chd_binary (logit) mi_binary (logit) stroke_binary (logit) famHx_mi (regress) bmi (logit) cancerBinary (regress) egfr_mdrd (logit) copdEtcBinary (logit) diabetesBinary (regress) a1c (logit) heartFailureBinary (logit) liverEverBinary (regress) num_meds (regress) hc_visits_last_year (logit) hosp_last_year_binary (regress) readyToEatFood (logit) atLeastModActivity (ologit)self_preceived_health (mlogit) health_insurance_cat (logit) rx_coverage_binary (ologit)formal_education_level (ologit) fam_pov_level_cat (logit) marital_status_binary, add(10) rseed(412) augment

		
cd "$project"
save "statinDisparities_nhanes_analyticDataset_mi.dta", replace


************
* PRIMARY PREVENTION ANALYSIS
************


*** STATIN-USE DIFFERENCE

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2


* PR for race-ethnicity-gender categories
preserve

	matrix diff_primary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if primary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix diff_primary[`i',1] = results[1,1]
				matrix diff_primary[`i',2] = results[5,1]
				matrix diff_primary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat diff_primary
	rename (diff_primary1 diff_primary2 diff_primary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "diff_primary.dta", replace

restore

* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2
	mimrgns i.cycle2, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]

	
*** STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
esttab using "disparity_primary_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace


* PR for race-ethnicity-gender categories
preserve

	matrix disparity_primary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if primary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix disparity_primary[`i',1] = results[1,1]
				matrix disparity_primary[`i',2] = results[5,1]
				matrix disparity_primary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat disparity_primary
	rename (disparity_primary1 disparity_primary2 disparity_primary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "disparity_primary.dta", replace

restore 

* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.cycle2, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]


	* Age
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean age
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(age=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* ASCVD risk
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean ascvd_riskPct
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(ascvd_riskPct=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]

	* Family history of MI
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.famHx_mi, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.famHx_mi] / _b[0.famHx_mi]
	
	* Fibrates
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.fibrate, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.fibrate] / _b[0.fibrate]
	
	* BMI 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean bmi
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(bmi=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Cancer
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.cancer, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.cancer] / _b[0.cancer]
	
	* CKD
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.ckd, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.ckd] / _b[0.ckd]
	
	* eGFR 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean egfr_mdrd
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(egfr_mdrd=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* COPD
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.copdEtcBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.copdEtcBinary] / _b[0.copdEtcBinary]
	
	* Diabetes
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.diabetesBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.diabetesBinary] / _b[0.diabetesBinary]	
	
	* A1c 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean a1c
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(a1c=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHF
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.heartFailureBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.heartFailureBinary] / _b[0.heartFailureBinary]	
	
	* Liver
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.liverEverBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.liverEverBinary] / _b[0.liverEverBinary]	
	
	* Number of medications 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean num_meds
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(num_meds=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]	
	
	* Statin intolerance risk factors
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean numStatinIntolRf
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(numStatinIntolRf=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Healthcare visits last years
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean hc_visits_last_year
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(hc_visits_last_year=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Hospitalization last year
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.hosp_last_year_binary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.hosp_last_year_binary] / _b[0.hosp_last_year_binary]
	
	* Ready to eat meals
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean readyToEatFood
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(readyToEatFood=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Physical activity
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.atLeastModActivity, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.atLeastModActivity] / _b[0.atLeastModActivity]
	
	* Self-perceived health
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.self_preceived_health, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[4.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[3.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[2.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[1.self_preceived_health] / _b[5.self_preceived_health]
	
	
	
*** UNEXPLAINED STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unexplainedDisparity_primary_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

* PR for race-ethnicity-gender categories
preserve

	matrix unexplainedDisparity_primary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if primary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix unexplainedDisparity_primary[`i',1] = results[1,1]
				matrix unexplainedDisparity_primary[`i',2] = results[5,1]
				matrix unexplainedDisparity_primary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat unexplainedDisparity_primary
	rename (unexplainedDisparity_primary1 unexplainedDisparity_primary2 unexplainedDisparity_primary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "unexplainedDisparity_primary.dta", replace
	
restore

* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.cycle2, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]


	* Age
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean age
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(age=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* ASCVD risk
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean ascvd_riskPct
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(ascvd_riskPct=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]

	* Family history of MI
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.famHx_mi, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.famHx_mi] / _b[0.famHx_mi]
	
	* Fibrates
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.fibrate, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.fibrate] / _b[0.fibrate]
	
	* BMI 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean bmi
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(bmi=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Cancer
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.cancer, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.cancer] / _b[0.cancer]
	
	* CKD
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.ckd, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.ckd] / _b[0.ckd]
	
	* eGFR 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean egfr_mdrd
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(egfr_mdrd=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* COPD
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.copdEtcBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.copdEtcBinary] / _b[0.copdEtcBinary]
	
	* Diabetes
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.diabetesBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.diabetesBinary] / _b[0.diabetesBinary]	
	
	* A1c 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean a1c
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(a1c=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHF
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.heartFailureBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.heartFailureBinary] / _b[0.heartFailureBinary]	
	
	* Liver
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.liverEverBinary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.liverEverBinary] / _b[0.liverEverBinary]	
	
	* Number of medications 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean num_meds
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(num_meds=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]	
	
	* Statin intolerance risk factors
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean numStatinIntolRf
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(numStatinIntolRf=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Healthcare visits last years
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean hc_visits_last_year
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(hc_visits_last_year=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Hospitalization last year
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.hosp_last_year_binary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.hosp_last_year_binary] / _b[0.hosp_last_year_binary]
	
	* Ready to eat meals
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if primary_prevention == 1): mean readyToEatFood
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(readyToEatFood=(`valueMean' `value1SdHigh')) subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Physical activity
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.atLeastModActivity, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.atLeastModActivity] / _b[0.atLeastModActivity]
	
	* Self-perceived health
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.self_preceived_health, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[4.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[3.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[2.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[1.self_preceived_health] / _b[5.self_preceived_health]
	
	* Health insurance
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.health_insurance_cat, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[2.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[3.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[4.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[5.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[6.health_insurance_cat] / _b[0.health_insurance_cat]
	
	* Rx coverage
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.rx_coverage_binary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.rx_coverage_binary] / _b[0.rx_coverage_binary]
	
	* Education
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.formal_education_level, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2.formal_education_level] / _b[1.formal_education_level]
	nlcom _b[3.formal_education_level] / _b[1.formal_education_level]
	
	* Household income
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.fam_pov_level_cat, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[2.fam_pov_level_cat] / _b[1.fam_pov_level_cat]
	nlcom _b[3.fam_pov_level_cat] / _b[1.fam_pov_level_cat]
	
	* Partnered
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.marital_status_binary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.marital_status_binary] / _b[0.marital_status_binary]
	
	* Place for health care
	qui mi estimate, or post: svy, subpop(if primary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.place_for_hc_binary, subpop(if primary_prevention == 1) predict(pr) post
	nlcom _b[1.place_for_hc_binary] / _b[0.place_for_hc_binary]
	
	

************
* SECONDARY PREVENTION ANALYSIS
************


*** STATIN-USE DIFFERENCE

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 

mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2

* PR for race-ethnicity-gender categories
preserve

	matrix diff_secondary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if secondary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix diff_secondary[`i',1] = results[1,1]
				matrix diff_secondary[`i',2] = results[5,1]
				matrix diff_secondary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat diff_secondary
	rename (diff_secondary1 diff_secondary2 diff_secondary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "diff_secondary.dta", replace

restore

* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2
	mimrgns i.cycle2, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]
	
	
	
*** STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
esttab using "disparity_secondary_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

* PR for race-ethnicity-gender categories
preserve

	matrix disparity_secondary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if secondary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix disparity_secondary[`i',1] = results[1,1]
				matrix disparity_secondary[`i',2] = results[5,1]
				matrix disparity_secondary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat disparity_secondary
	rename (disparity_secondary1 disparity_secondary2 disparity_secondary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "disparity_secondary.dta", replace
	
restore


* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.cycle2, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]

	* Age
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean age
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(age=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.chd_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.chd_binary] / _b[0.chd_binary]
	
	* MI
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.mi_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.mi_binary] / _b[0.mi_binary]
	
	* Stroke
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.stroke_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.stroke_binary] / _b[0.stroke_binary]

	* Family history of MI
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.famHx_mi, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.famHx_mi] / _b[0.famHx_mi]
	
	* Fibrates
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.fibrate, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.fibrate] / _b[0.fibrate]
	
	* BMI 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean bmi
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(bmi=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Cancer
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.cancer, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.cancer] / _b[0.cancer]
	
	* CKD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.ckd, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.ckd] / _b[0.ckd]
	
	* eGFR 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean egfr_mdrd
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(egfr_mdrd=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* COPD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.copdEtcBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.copdEtcBinary] / _b[0.copdEtcBinary]
	
	* Diabetes
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.diabetesBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.diabetesBinary] / _b[0.diabetesBinary]	
	
	* A1c 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean a1c
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(a1c=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHF
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.heartFailureBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.heartFailureBinary] / _b[0.heartFailureBinary]	
	
	* Liver
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.liverEverBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.liverEverBinary] / _b[0.liverEverBinary]	
	
	* Number of medications 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean num_meds
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(num_meds=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]	
	
	* Statin intolerance risk factors
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean numStatinIntolRf
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(numStatinIntolRf=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Healthcare visits last years
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean hc_visits_last_year
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(hc_visits_last_year=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Hospitalization last year
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.hosp_last_year_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.hosp_last_year_binary] / _b[0.hosp_last_year_binary]
	
	* Ready to eat meals
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean readyToEatFood
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns, at(readyToEatFood=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Physical activity
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.atLeastModActivity, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.atLeastModActivity] / _b[0.atLeastModActivity]
	
	* Self-perceived health
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.self_preceived_health, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[4.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[3.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[2.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[1.self_preceived_health] / _b[5.self_preceived_health]
	
	
	
*** UNEXPLAINED STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unexplainedDisparity_secondary_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

* PR for race-ethnicity-gender categories
preserve

	matrix unexplainedDisparity_secondary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if secondary_prevention == 1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix unexplainedDisparity_secondary[`i',1] = results[1,1]
				matrix unexplainedDisparity_secondary[`i',2] = results[5,1]
				matrix unexplainedDisparity_secondary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat unexplainedDisparity_secondary
	rename (unexplainedDisparity_secondary1 unexplainedDisparity_secondary2 unexplainedDisparity_secondary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "unexplainedDisparity_secondary.dta", replace

restore

* PR for covariates

	* Cycle
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.cycle2, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.cycle2] / _b[0.cycle2]

	* Age
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean age
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(age=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.chd_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.chd_binary] / _b[0.chd_binary]
	
	* MI
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.mi_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.mi_binary] / _b[0.mi_binary]
	
	* Stroke
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health
	mimrgns i.stroke_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.stroke_binary] / _b[0.stroke_binary]

	* Family history of MI
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.famHx_mi, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.famHx_mi] / _b[0.famHx_mi]
	
	* Fibrates
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.fibrate, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.fibrate] / _b[0.fibrate]
	
	* BMI 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean bmi
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(bmi=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Cancer
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.cancer, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.cancer] / _b[0.cancer]
	
	* CKD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.ckd, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.ckd] / _b[0.ckd]
	
	* eGFR 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean egfr_mdrd
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(egfr_mdrd=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* COPD
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.copdEtcBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.copdEtcBinary] / _b[0.copdEtcBinary]
	
	* Diabetes
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.diabetesBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.diabetesBinary] / _b[0.diabetesBinary]	
	
	* A1c 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean a1c
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(a1c=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* CHF
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.heartFailureBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.heartFailureBinary] / _b[0.heartFailureBinary]	
	
	* Liver
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.liverEverBinary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.liverEverBinary] / _b[0.liverEverBinary]	
	
	* Number of medications 
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean num_meds
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(num_meds=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]	
	
	* Statin intolerance risk factors
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight_mec], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean numStatinIntolRf
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(numStatinIntolRf=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Healthcare visits last years
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean hc_visits_last_year
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(hc_visits_last_year=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Hospitalization last year
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.hosp_last_year_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.hosp_last_year_binary] / _b[0.hosp_last_year_binary]
	
	* Ready to eat meals
	preserve
		cd "$project"
		use "statinDisparities_nhanes_analyticDataset.dta", clear
		svyset sdmvpsu [pweight = main_analysis_weight], strata(sdmvstra) vce(linearized) singleunit(missing) 
		svy, subpop(if secondary_prevention == 1): mean readyToEatFood
		matrix results = r(table)
		local total = `e(N_sub)'
		local valueMean = results[1,1]
		local value1SdHigh = `valueMean' + (results[2,1])*sqrt(`total')
		display `total'
		display `valueMean'
		display `value1SdHigh'
	restore
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns, at(readyToEatFood=(`valueMean' `value1SdHigh')) subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2._at] / _b[1._at]
	
	* Physical activity
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.atLeastModActivity, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.atLeastModActivity] / _b[0.atLeastModActivity]
	
	* Self-perceived health
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.self_preceived_health, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[4.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[3.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[2.self_preceived_health] / _b[5.self_preceived_health]
	nlcom _b[1.self_preceived_health] / _b[5.self_preceived_health]
	
	* Health insurance
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.health_insurance_cat, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[2.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[3.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[4.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[5.health_insurance_cat] / _b[0.health_insurance_cat]
	nlcom _b[6.health_insurance_cat] / _b[0.health_insurance_cat]
	
	* Rx coverage
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.rx_coverage_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.rx_coverage_binary] / _b[0.rx_coverage_binary]
	
	* Education
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.formal_education_level, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2.formal_education_level] / _b[1.formal_education_level]
	nlcom _b[3.formal_education_level] / _b[1.formal_education_level]
	
	* Household income
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.fam_pov_level_cat, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[2.fam_pov_level_cat] / _b[1.fam_pov_level_cat]
	nlcom _b[3.fam_pov_level_cat] / _b[1.fam_pov_level_cat]
	
	* Partnered
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.marital_status_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.marital_status_binary] / _b[0.marital_status_binary]
	
	* Place for health care
	qui mi estimate, or post: svy, subpop(if secondary_prevention==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
	mimrgns i.place_for_hc_binary, subpop(if secondary_prevention == 1) predict(pr) post
	nlcom _b[1.place_for_hc_binary] / _b[0.place_for_hc_binary]



************
************
* SENSITIVITY ANALYSES
************
************

************
* NO RACE ASCVD RISK - PRIMARY PREVENTION ANALYSIS 
************

*** UNEXPLAINED STATIN-USE DISPARITY


cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if primary_prevention_noRace==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct_noRace i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unexplainedDisparity_primary_noRace_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

matrix unexplainedDisp_primary_noRace = J(12,3,.)

mimrgns i.female#ib3.raceEthnicity, subpop(if primary_prevention_noRace == 1) predict(pr) post

local i = 0
forvalues f = 0(1)1 {
	forvalues r = 1(1)7 {
		if `r' == 5 {
			continue
		}
		local i = `i' + 1
		nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
			matrix results = r(table)
			matrix unexplainedDisp_primary_noRace[`i',1] = results[1,1]
			matrix unexplainedDisp_primary_noRace[`i',2] = results[5,1]
			matrix unexplainedDisp_primary_noRace[`i',3] = results[6,1]
	}
}

drop _all
set obs 12
gen row = _n
gen name = ""
	replace name = "Mexican American M" if row == 1
	replace name = "Non-Mexican Hispanic M" if row == 2
	replace name = "Non-Hispanic White M" if row == 3
	replace name = "Non-Hispanic Black M" if row == 4
	replace name = "Non-Hispanic Asian M" if row == 5
	replace name = "Other/Multiracial M" if row == 6
	replace name = "Mexican American W" if row == 7
	replace name = "Non-Mexican Hispanic W" if row == 8
	replace name = "Non-Hispanic White W" if row == 9
	replace name = "Non-Hispanic Black W" if row == 10
	replace name = "Non-Hispanic Asian W" if row == 11
	replace name = "Other/Multiracial W" if row == 12
svmat unexplainedDisp_primary_noRace
rename (unexplainedDisp_primary_noRace1 unexplainedDisp_primary_noRace2 unexplainedDisp_primary_noRace3) (pr ciLow ciHigh)
format pr ciLow ciHigh %9.2f
cd "$tables"
save "unexplainedDisparity_primary_noRace.dta", replace



************
*** SENSITIVITY ANALYSIS IF ALL NON-PRIMARY, NON-SECONDARY PREVENTION PEOPLE ARE ACTUALLY PRIMARY PREVENTION
************

*** UNEXPLAINED STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if expanded_primary_prev==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unexplainedDisparity_expandedPrimary_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

matrix unexplainedDisparity_primary = J(12,3,.)

mimrgns i.female#ib3.raceEthnicity, subpop(if expanded_primary_prev==1) predict(pr) post

local i = 0
forvalues f = 0(1)1 {
	forvalues r = 1(1)7 {
		if `r' == 5 {
			continue
		}
		local i = `i' + 1
		nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
			matrix results = r(table)
			matrix unexplainedDisparity_primary[`i',1] = results[1,1]
			matrix unexplainedDisparity_primary[`i',2] = results[5,1]
			matrix unexplainedDisparity_primary[`i',3] = results[6,1]
	}
}

drop _all
set obs 12
gen row = _n
gen name = ""
	replace name = "Mexican American M" if row == 1
	replace name = "Non-Mexican Hispanic M" if row == 2
	replace name = "Non-Hispanic White M" if row == 3
	replace name = "Non-Hispanic Black M" if row == 4
	replace name = "Non-Hispanic Asian M" if row == 5
	replace name = "Other/Multiracial M" if row == 6
	replace name = "Mexican American W" if row == 7
	replace name = "Non-Mexican Hispanic W" if row == 8
	replace name = "Non-Hispanic White W" if row == 9
	replace name = "Non-Hispanic Black W" if row == 10
	replace name = "Non-Hispanic Asian W" if row == 11
	replace name = "Other/Multiracial W" if row == 12
svmat unexplainedDisparity_primary
rename (unexplainedDisparity_primary1 unexplainedDisparity_primary2 unexplainedDisparity_primary3) (pr ciLow ciHigh)
format pr ciLow ciHigh %9.2f
cd "$tables"
save "unexplainedDisparity_expandedPrimary.dta", replace



************
*** SENSITIVITY ANALYSIS IF PRIMARY PREVENTION ASCVD THRESHOLD WAS 20%
************

*** UNEXPLAINED STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if highThreshold_primary_prev==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age ascvd_riskPct i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unExplainedDisparity_highTreshold_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

matrix unexplainedDisparity_primary = J(12,3,.)

mimrgns i.female#ib3.raceEthnicity, subpop(if highThreshold_primary_prev==1) predict(pr) post

local i = 0
forvalues f = 0(1)1 {
	forvalues r = 1(1)7 {
		if `r' == 5 {
			continue
		}
		local i = `i' + 1
		nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
			matrix results = r(table)
			matrix unexplainedDisparity_primary[`i',1] = results[1,1]
			matrix unexplainedDisparity_primary[`i',2] = results[5,1]
			matrix unexplainedDisparity_primary[`i',3] = results[6,1]
	}
}

drop _all
set obs 12
gen row = _n
gen name = ""
	replace name = "Mexican American M" if row == 1
	replace name = "Non-Mexican Hispanic M" if row == 2
	replace name = "Non-Hispanic White M" if row == 3
	replace name = "Non-Hispanic Black M" if row == 4
	replace name = "Non-Hispanic Asian M" if row == 5
	replace name = "Other/Multiracial M" if row == 6
	replace name = "Mexican American W" if row == 7
	replace name = "Non-Mexican Hispanic W" if row == 8
	replace name = "Non-Hispanic White W" if row == 9
	replace name = "Non-Hispanic Black W" if row == 10
	replace name = "Non-Hispanic Asian W" if row == 11
	replace name = "Other/Multiracial W" if row == 12
svmat unexplainedDisparity_primary
rename (unexplainedDisparity_primary1 unexplainedDisparity_primary2 unexplainedDisparity_primary3) (pr ciLow ciHigh)
format pr ciLow ciHigh %9.2f
cd "$tables"
save "unexplainedDisparity_highThreshold.dta", replace



************
*** SENSITIVITY ANALYSIS FOR SECONDARY PREVENTION NOT CONSIDERING ANGINA ONLY
************

*** UNEXPLAINED STATIN-USE DISPARITY

cd "$project"
use "statinDisparities_nhanes_analyticDataset_mi.dta", clear

gen secondary_prevWoAnginaOnly = secondary_prevention
	gen anginaOnly = 0
	replace anginaOnly = 1 if angina == 1 & chd_binary != 1 & mi_binary != 1 & stroke_binary != 1
	replace secondary_prevWoAnginaOnly = 0 if anginaOnly == 1

mi svyset sdmvpsu [pweight = main_analysis_weight_fasting], strata(sdmvstra) vce(linearized) singleunit(missing) 

cd "$tables"
eststo clear
eststo: mi estimate, or post: svy, subpop(if secondary_prevWoAnginaOnly==1): logistic statin i.female#ib3.raceEthnicity i.cycle2 age i.chd_binary i.mi_binary i.stroke_binary i.famHx_mi bmi i.cancerBinary i.ckd egfr_mdrd i.copdEtcBinary i.diabetesBinary a1c i.heartFailureBinary i.liverEverBinary num_meds numStatinIntolRf i.fibrate hc_visits_last_year i.hosp_last_year_binary readyToEatFood i.atLeastModActivity ib5.self_preceived_health ib0.health_insurance_cat i.rx_coverage_binary ib1.formal_education_level ib1.fam_pov_level_cat i.marital_status_binary i.place_for_hc_binary
esttab using "unexplainedDisparity_secondaryWoAnginaOnly_covariateORs.csv",  b(%9.2f) ci(%9.2f) wide eform plain label replace

* PR for race-ethnicity-gender categories


	matrix unexplainedDisparity_secondary = J(12,3,.)

	mimrgns i.female#ib3.raceEthnicity, subpop(if secondary_prevWoAnginaOnly==1) predict(pr) post

	local i = 0
	forvalues f = 0(1)1 {
		forvalues r = 1(1)7 {
			if `r' == 5 {
				continue
			}
			local i = `i' + 1
			nlcom _b[`f'.female#`r'.raceEthnicity] / _b[0.female#3.raceEthnicity]
				matrix results = r(table)
				matrix unexplainedDisparity_secondary[`i',1] = results[1,1]
				matrix unexplainedDisparity_secondary[`i',2] = results[5,1]
				matrix unexplainedDisparity_secondary[`i',3] = results[6,1]
		}
	}

	drop _all
	set obs 12
	gen row = _n
	gen name = ""
		replace name = "Mexican American M" if row == 1
		replace name = "Non-Mexican Hispanic M" if row == 2
		replace name = "Non-Hispanic White M" if row == 3
		replace name = "Non-Hispanic Black M" if row == 4
		replace name = "Non-Hispanic Asian M" if row == 5
		replace name = "Other/Multiracial M" if row == 6
		replace name = "Mexican American W" if row == 7
		replace name = "Non-Mexican Hispanic W" if row == 8
		replace name = "Non-Hispanic White W" if row == 9
		replace name = "Non-Hispanic Black W" if row == 10
		replace name = "Non-Hispanic Asian W" if row == 11
		replace name = "Other/Multiracial W" if row == 12
	svmat unexplainedDisparity_secondary
	rename (unexplainedDisparity_secondary1 unexplainedDisparity_secondary2 unexplainedDisparity_secondary3) (pr ciLow ciHigh)
	format pr ciLow ciHigh %9.2f
	cd "$tables"
	save "unexplainedDisparity_secondaryWoAnginaOnly.dta", replace


