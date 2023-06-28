/*

DESCRIPTION: Stata do file to process NHANES data extracted from DATA EXTRACTION file. Data used for Disparities in Guideline-Recommended Statin Use for Prevention of Atherosclerotic Cardiovascular Disease by Race, Ethnicity, and Gender: A Nationally Representative Cross-Sectional Analysis of Adults in the United States. Frank DA, Johnson AE, Hausmann LRM , Gellad WF, Roberts ET, and Vajravelu RK. Ann Intern Med. Jul 25 2023. https://doi.org/10.7326/M23-0720. 

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

cd "`folder'/Data processing/temp"
global temp `c(pwd)'

cd "`folder'/Data processing/tables"
global tables `c(pwd)'


************
* VARIABLES
************

local analysis_type = "main" // alternative is "sensi"

cd "$project"
use "statinDisparities_nhanes_extractedData_2015To2020.dta", clear

keep if `analysis_type'_analysis == 1


************
* SECONDARY PREVENTION DATA PROCESSING
************

* Eligible for secondary prevention
	gen secondary_prevention = 0 
	replace secondary_prevention = 1 if (ascvd == 1 & ridageyr>=21 & ridageyr<=75)
	
* Covariates

	gen mi_binary = .
	replace mi_binary = 1 if mi == 1
	replace mi_binary = 0 if mi == 2
	gen stroke_binary = .
	replace stroke_binary = 1 if stroke == 1
	replace stroke_binary = 0 if stroke == 2
	gen chd_binary = .
	replace chd_binary = 1 if chd == 1
	replace chd_binary = 0 if chd == 2


************
* PRIMARY PREVENTION DATA PROCESSING
************

gen ldl190OrMore = .
replace ldl190OrMore = 0 if ldl < 190
replace ldl190OrMore = 1 if ldl >= 190 & ldl != . 
gen ldl70to189 = .
replace ldl70to189 = 0 if ldl < 70 | ldl190OrMore == 1
replace ldl70to189 = 1 if ldl >= 70 & ldl < 190 & ldl != .

* ASCVD risk
	
	* ASCVD risk calculator (https://www.merckmanuals.com/medical-calculators/ACCAHA2013-ja.htm & Appendix 7 of the 2013 AHA guidelines https://www.ahajournals.org/doi/10.1161/01.cir.0000437741.48606.98#d3e1148 )
	
	gen ln_age= ln(ridageyr)
	gen ln_age_sq = ln_age^2
	gen ln_tchol = ln(tchol)
	gen ln_hdl = ln(hdl)
	gen ascvd_calc_htn_med = 0
		replace ascvd_calc_htn_med = 1 if htn_rx_now == 1
	gen ascvd_calc_not_htn_med = 0
		replace ascvd_calc_not_htn_med = 1 if ascvd_calc_htn_med == 0
	gen ln_sbp = ln(mean_sbp)
	gen ascvd_calc_smoker = 0
		replace ascvd_calc_smoker = 1 if smoke_now == 1
	gen ascvd_calc_diabetes = 0
		replace ascvd_calc_diabetes = 1 if diabetes == 1
	
	gen ascvd_risk = .
	gen ascvd_risk_noRaceEthnicity = .
	
	* Black female
		
		replace ascvd_risk = ///
			1 - ///
			( ///	
				0.9533 ///
				^ ///
				exp( ///
					( ///
						( ///
							17.114 * ln_age + ///
							0 * ln_age_sq + ///
							0.94 * ln_tchol + ///
							0 * ln_age * ln_tchol + ///
							-18.92 * ln_hdl + ///
							4.475 * ln_age * ln_hdl + ///
							29.291 * ascvd_calc_htn_med * ln_sbp + ///
							-6.432 * ascvd_calc_htn_med * ln_age * ln_sbp + ///
							27.82 * ascvd_calc_not_htn_med * ln_sbp + ///
							-6.087 * ascvd_calc_not_htn_med * ln_age * ln_sbp + ///
							0.691 * ascvd_calc_smoker + ///
							0 * ascvd_calc_smoker * ln_age + ///
							0.874 * ascvd_calc_diabetes ///
						)  ///
						- ///
						86.61 ///
					) ///
				) ///
			) ///
			if ridreth3 == 4 & riagendr == 2
			
	
	* Non-black female
	
		replace ascvd_risk_noRaceEthnicity = ///
			1 - ///
			( ///	
				0.9665 ///
				^ ///
				exp( ///
					( ///
						( ///
							-29.799 * ln_age + ///
							4.884 * ln_age_sq + ///
							13.54 * ln_tchol + ///
							-3.114 * ln_age * ln_tchol + ///
							-13.578 * ln_hdl + ///
							3.149 * ln_age * ln_hdl + ///
							2.019 * ascvd_calc_htn_med * ln_sbp + ///
							0 * ascvd_calc_htn_med * ln_age * ln_sbp + ///
							1.957 * ascvd_calc_not_htn_med * ln_sbp + ///
							0 * ascvd_calc_not_htn_med * ln_age * ln_sbp + ///
							7.574 * ascvd_calc_smoker + ///
							-1.665 * ascvd_calc_smoker * ln_age + ///
							0.661 * ascvd_calc_diabetes ///
						)  ///
						- ///
						-29.18 ///
					) ///
				) ///
			) ///
			if riagendr == 2
			
		replace ascvd_risk = ascvd_risk_noRaceEthnicity if ridreth3 != 4 & riagendr == 2
			
	
	* Black male
	
		replace ascvd_risk = ///
			1 - ///
			( ///	
				0.8954 ///
				^ ///
				exp( ///
					( ///
						( ///
							2.469 * ln_age + ///
							0 * ln_age_sq + ///
							0.302 * ln_tchol + ///
							0 * ln_age * ln_tchol + ///
							-0.307 * ln_hdl + ///
							0 * ln_age * ln_hdl + ///
							1.916 * ascvd_calc_htn_med * ln_sbp + ///
							0 * ascvd_calc_htn_med * ln_age * ln_sbp + ///
							1.809 * ascvd_calc_not_htn_med * ln_sbp + ///
							0 * ascvd_calc_not_htn_med * ln_age * ln_sbp + ///
							0.549 * ascvd_calc_smoker + ///
							0 * ascvd_calc_smoker * ln_age + ///
							0.645 * ascvd_calc_diabetes ///
						)  ///
						- ///
						19.54 ///
					) ///
				) ///
			) ///
			if ridreth3 == 4 & riagendr == 1
		
		
	* Non-black male
	
		replace ascvd_risk_noRaceEthnicity = ///
			1 - ///
			( ///	
				0.9144 ///
				^ ///
				exp( ///
					( ///
						( ///
							12.344 * ln_age + ///
							0 * ln_age_sq + ///
							11.853 * ln_tchol + ///
							-2.664 * ln_age * ln_tchol + ///
							-7.99 * ln_hdl + ///
							1.769 * ln_age * ln_hdl + ///
							1.797 * ascvd_calc_htn_med * ln_sbp + ///
							0 * ascvd_calc_htn_med * ln_age * ln_sbp + ///
							1.764 * ascvd_calc_not_htn_med * ln_sbp + ///
							0 * ascvd_calc_not_htn_med * ln_age * ln_sbp + ///
							7.837 * ascvd_calc_smoker + ///
							-1.795 * ascvd_calc_smoker * ln_age + ///
							0.658 * ascvd_calc_diabetes ///
						)  ///
						- ///
						61.18 ///
					) ///
				) ///
			) ///
			if  riagendr == 1
			
			replace ascvd_risk = ascvd_risk_noRaceEthnicity if ridreth3 != 4 & riagendr == 1
	
	*bro seqn ridreth3 riagendr ridageyr mean_sbp tchol hdl ascvd_calc_* ascvd_risk
	
	drop ln_age-ascvd_calc_smoker
	
	gen high_ascvd_risk = .
	replace high_ascvd_risk = 1 if ascvd_risk >= 0.075 & ascvd_risk != .
	
	
* Eligible for primary prevention
	gen primary_prevention = 0 
	replace primary_prevention = 1 if (ldl190OrMore == 1 & ridageyr>=21 & ridageyr<=75)  | ///
									  (diabetes == 1 & ridageyr>=40 & ridageyr<=75)  | ///
									  (ascvd_risk >= 0.075 & ascvd_risk != .)
	replace primary_prevention = 0 if ascvd == 1	
	
	gen primary_prevention_noRace = 0 
	replace primary_prevention_noRace = 1 if (ldl190OrMore == 1 & ridageyr>=21 & ridageyr<=75)  | ///
									  (diabetes == 1 & ridageyr>=40 & ridageyr<=75)  | ///
									  (ascvd_risk_noRaceEthnicity >= 0.075 & ascvd_risk_noRaceEthnicity != .)
	replace primary_prevention_noRace = 0 if ascvd == 1
	
	gen highThreshold_primary_prev = 0 
	replace highThreshold_primary_prev = 1 if (ldl190OrMore == 1 & ridageyr>=21 & ridageyr<=75)  | ///
									  (diabetes == 1 & ridageyr>=40 & ridageyr<=75)  | ///
									  (ascvd_risk >= 0.20 & ascvd_risk != .)
	replace highThreshold_primary_prev = 0 if ascvd == 1	
	

************
* PROCESS COVARIATES
************

gen female = 0
	replace female = 1 if riagendr == 2
gen age = ridageyr
gen formal_education_level = .
	replace formal_education_level = 1 if dmdeduc2 == 1 | dmdeduc2 == 2
	replace formal_education_level = 2 if dmdeduc2 == 3 | dmdeduc2 == 4
	replace formal_education_level = 3 if dmdeduc2 == 5
	replace formal_education_level = . if dmdeduc2 == 7 | dmdeduc2 == 9
	label define formal_education_level_name 1 "Less than high-school diploma" 2 "High-school diploma, GED, some college, or AA degree" 3 "College or more"
	label values formal_education_level formal_education_level_name
gen marital_status_binary = .
	replace marital_status_binary = 1 if dmdmartz == 1
	replace marital_status_binary = 0 if dmdmartz == 2 | dmdmartz == 3
	replace marital_status = . if dmdmartz == 77 | dmdmartz == 99
	label define martial_status_name 1 "Married/Living with Partner" 0 "Widowed/Divorced/Separated/Never Married"
	label values marital_status marital_status_name
gen fam_pov_level_index = indfmmpi
gen fam_pov_level_cat = indfmmpc
	replace fam_pov_level_cat = . if fam_pov_level_cat == 7 | fam_pov_level_cat == 9
	label define fam_pov_level_cat_name 1 "Monthly poverty level index = 1.30" 2 "1.30 < Monthly poverty level index = 1.85" 3 "Monthly poverty level index >1.85"
	label values fam_pov_level_cat fam_pov_level_cat_name
gen famHx_mi = .
	replace famHx_mi = 0 if relative_with_mi == 2 | relative_with_mi == 7 | relative_with_mi == 9
	replace famHx_mi = 1 if relative_with_mi == 1
gen self_preceived_health = gen_health
	replace self_preceived_health = . if gen_health == 7 | gen_health == 9
	label define self_preceived_health_name 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor"
	label values self_preceived_health self_preceived_health_name
gen hc_visits_last_year = . // using median in in the range to make continuous. Some bias for the 16+
	replace hc_visits_last_year = 0 if times_hc_last_year == 0
	replace hc_visits_last_year = 1 if times_hc_last_year == 1
	replace hc_visits_last_year = 2.5 if times_hc_last_year == 2
	replace hc_visits_last_year = 4.5 if times_hc_last_year == 3
	replace hc_visits_last_year = 6.5 if times_hc_last_year == 4
	replace hc_visits_last_year = 8.5 if times_hc_last_year == 5
	replace hc_visits_last_year = 11 if times_hc_last_year == 6
	replace hc_visits_last_year = 14 if times_hc_last_year == 7
	replace hc_visits_last_year = 16 if times_hc_last_year == 8
gen place_for_hc_binary = .
	replace place_for_hc_binary = 1 if place_for_hc == 1 | place_for_hc == 3
	replace place_for_hc_binary = 0 if place_for_hc == 2
gen hosp_last_year_binary = .
	replace hosp_last_year_binary = 0 if hosp_last_year == 2
	replace hosp_last_year_binary = 1 if hosp_last_year == 1
gen health_insurance_cat = .
	replace health_insurance_cat = health_insurance_type 
	replace health_insurance_cat = 0 if health_insurance == 2
	label define health_insurance_cat_name 0 "None" 1 "Private" 2 "Medicare" 3 "Medicaid/CHIP" 4 "Government" 5 "More than one type" 6 "Unspecified"
	label values health_insurance_cat health_insurance_cat_name
gen rx_coverage_binary = .
	replace rx_coverage_binary = 0 if rx_coverage == 2
	replace rx_coverage_binary = 1 if rx_coverage == 1
gen heavyDrinking = .
	replace heavyDrinking = 0 if drinksPerWeek <= 14 & female == 0
	replace heavyDrinking = 1 if drinksPerWeek > 14 & drinksPerWeek != . & female == 0
	replace heavyDrinking = 0 if drinksPerWeek <= 7 & female == 1
	replace heavyDrinking = 1 if drinksPerWeek > 7 & drinksPerWeek != . & female == 1	
gen ckd = 0
	replace ckd = 1 if weakKidneys_ever == 1 | dialysisThisYear == 1
gen egfr_mdrd = .
	replace egfr_mdrd = 175 * (creatinine^-1.154) * (age^-0.203) if ridreth3 != 4 & riagendr == 1
	replace egfr_mdrd = 175 * (creatinine^-1.154) * (age^-0.203) * 1.212 if ridreth3 == 4 & riagendr == 1
	replace egfr_mdrd = 175 * (creatinine^-1.154) * (age^-0.203) * 0.742 if ridreth3 != 4 & riagendr == 2
	replace egfr_mdrd = 175 * (creatinine^-1.154) * (age^-0.203) * 1.212 * 0.742 if ridreth3 == 4 & riagendr == 2
egen numStatinIntolRf = rowtotal(ckd liverConditionNow thyroidConditionNow heavyDrinking interactingMed)
	replace numStatinIntolRf = 0 if numStatinIntolRf == .
gen cancerBinary = .
	replace cancerBinary = 1 if cancer == 1
	replace cancerBinary = 0 if cancer == 2
gen copdEtcBinary = .
	replace copdEtcBinary = 1 if pulmObsDisease == 1
	replace copdEtcBinary = 0 if pulmObsDisease == 2
gen diabetesBinary = .
	replace diabetesBinary = 1 if diabetes == 1
	replace diabetesBinary = 0 if diabetes == 2
	replace diabetesBinary = 0 if diabetes == 3
gen heartFailureBinary = .
	replace heartFailureBinary = 1 if heartFailure == 1
	replace heartFailureBinary = 0 if heartFailure == 2
gen liverEverBinary = .
	replace liverEverBinary = 1 if liverDiseaseEver == 1
	replace liverEverBinary = 0 if liverDiseaseEver == 2
egen numComorbidities = rowtotal(cancerBinary ckd copdEtcBinary diabetesBinary heartFailureBinary liverEverBinary)
gen ascvd_riskPct = ascvd_risk * 100
gen ascvd_riskPct_noRace = ascvd_risk_noRaceEthnicity * 100

rename ridreth3 raceEthnicity

*** Drop unneeded covariates

keep seqn dataset main_analysis_weight main_analysis_weight_mec main_analysis_weight_fasting sddsrvyr sdmvpsu sdmvstra raceEthnicity ridexmon statin pos_high_intensity_statin low_intensity_statin pcsk9 fibrate primary_prevention primary_prevention_noRace secondary_prevention female age mi_binary stroke_binary chd_binary ascvd_riskPct ascvd_riskPct_noRace formal_education_level marital_status_binary fam_pov_level_index fam_pov_level_cat famHx_mi self_preceived_health hc_visits_last_year place_for_hc_binary hosp_last_year_binary health_insurance_cat rx_coverage_binary numStatinIntolRf cancerBinary copdEtcBinary diabetesBinary heartFailureBinary liverEverBinary num_meds ldl190OrMore a1c ckd egfr_mdrd angina fibrate pcsk9 atLeastModActivity readyToEatFood bmi interactingMed statinName highThreshold_primary_prev

order ///
	seqn dataset main_analysis_weight main_analysis_weight_mec main_analysis_weight_fasting sddsrvyr sdmvpsu sdmvstra ridexmon ///
	raceEthnicity female age ///
	statin statinName pos_high_intensity_statin low_intensity_statin pcsk9 fibrate ///
	primary_prevention primary_prevention_noRace secondary_prevention ///
	ascvd_riskPct ascvd_riskPct_noRace ///
	chd_binary mi_binary stroke_binary angina ///
	famHx_mi self_preceived_health hc_visits_last_year place_for_hc_binary hosp_last_year_binary numStatinIntolRf bmi cancerBinary copdEtcBinary diabetesBinary heartFailureBinary liverEverBinary num_meds ldl190OrMore a1c ckd egfr_mdrd readyToEatFood atLeastModActivity self_preceived_health ///
	health_insurance_cat rx_coverage_binary formal_education_level fam_pov_level_cat fam_pov_level_index marital_status_binary place_for_hc_binary ///
	interactingMed
	
gen expanded_primary_prev = primary_prevention, a(secondary_prevention)
replace expanded_primary_prev = 1 if statin == 1 & secondary_prevention != 1

gen cycle2 = 1 if dataset != "2015-2016", a(dataset)
replace cycle2 = 0 if dataset == "2015-2016"

cd "$project"
save "statinDisparities_nhanes_analyticDataset.dta", replace
