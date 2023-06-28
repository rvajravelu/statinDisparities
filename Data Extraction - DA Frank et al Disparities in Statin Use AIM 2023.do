/*

DESCRIPTION: Stata do file to extract data from NHANES used in Disparities in Guideline-Recommended Statin Use for Prevention of Atherosclerotic Cardiovascular Disease by Race, Ethnicity, and Gender: A Nationally Representative Cross-Sectional Analysis of Adults in the United States. Frank DA, Johnson AE, Hausmann LRM , Gellad WF, Roberts ET, and Vajravelu RK. Ann Intern Med. Jul 25 2023. https://doi.org/10.7326/M23-0720. 

DO FILE AUTHORS: David A. Frank MPH and Ravy K. Vajravelu MD MSCE -- University of Pittsburgh 

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


******
* VARIABLES
******

local nhanes_url = "https://wwwn.cdc.gov/Nchs/Nhanes"

local yearList = "2017-2020 2017-2018 2015-2016"
	
foreach year of local yearList {

	local year_url = "`year'"
	if "`year'" == "2017-2020" {
		local year_url = "2017-2018"
		local letter = "P"
	}
	if "`year'" == "2017-2018" {
		local letter = "J"
	}
	if "`year'" == "2015-2016" {
		local letter = "I"
	}
	
	
	******
	* DEMOGRAPHICS
	******

	if "`year'" == "2017-2020" {
		import sasxport5 "`nhanes_url'/`year_url'/`letter'_DEMO.XPT", clear
		
		rename (wtintprp wtmecprp) (interview_weight mec_weight)
	}
	if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
		import sasxport5 "`nhanes_url'/`year_url'/DEMO_`letter'.XPT", clear
		
		rename (wtint2yr wtmec2yr) (interview_weight mec_weight)
		
		gen dmdmartz = .
		replace dmdmartz = 1 if dmdmartl == 1 | dmdmartl == 6
		replace dmdmartz = 2 if dmdmartl == 2 | dmdmartl == 3 | dmdmartl == 4
		replace dmdmartz = 3 if dmdmartl == 5
		replace dmdmartz = 77 if dmdmartl == 77
		replace dmdmartz = 99 if dmdmartl == 99
		
	}
	
	* Label variable values
		label define sddsrvyr_name 9 "2015-2016" 10 "2017-2018" 66 "2017-2020"
		label values sddsrvyr sddsrvyr_name
		label define ridstatr_name 1 "interview only" 2 "interview and mec"
		label values ridstatr ridstatr_name
		label define riagendr_name 1 "male" 2 "female"
		label values riagendr riagendr_name
		label define ridreth1_name 1 "Mexican American" 2 "Other Hispanic" 3 "Non-Hispanic White" 4"Non-Hispanic Black" 5 "Other and Multi-Racial"
		label values ridreth1 ridreth1_name
		label define ridreth3_name 1 "Mexican American" 2 "Other Hispanic" 3 "Non-Hispanic White" 4"Non-Hispanic Black" 6 "Non-Hispanic Asian" 7 "Other and Multi-Racial"
		label values ridreth3 ridreth3_name
		label define ridexmon_name 1 "November-April" 2 "May-October"
		label values ridexmon ridexmon_name
		label define dmdeduc2_name 1 "Less than 9th grade" 2 "9-11th grade" 3 "High school graduate/GED or equivalent" 4 "Some college or AA degree" 5 "College. graduate or above" 7 "Refused" 9 "Don't know"
		label values dmdeduc2 dmdeduc2_name
		label define dmdmartz_name 1 "Married/Living with Partner" 2 "Widowed/Divorced/Separated" 3 "Never Married" 77 "Refused" 99 "Don't know"
		label values dmdmartz dmdmartz_name
		
		keep seqn-ridexmon dmdeduc2 dmdmartz interview_weight mec_weight sdmvpsu sdmvstra

	cd "$temp"
	save "DEMO_`year'.dta", replace


	******
	* QUESTIONNAIRES
	******

	* Medical Questionnaire
		
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_MCQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/MCQ_`letter'.XPT", clear
		}
		
		if "`year'" == "2017-2020" {
			keep seqn mcq160c mcd180c mcq160d mcd180d mcq160e mcd180e mcq160f mcd180f mcq300a mcq170l mcq170m mcq220 mcq160p mcq160b mcq160l
			rename (mcd180c mcd180d mcd180e mcd180f mcq170l mcq170m mcq220 mcq160p mcq160b mcq160l) (chd_age angina_age mi_age stroke_age liverConditionNow thyroidConditionNow cancer pulmObsDisease heartFailure liverDiseaseEver)  
		}
		
		if "`year'" == "2017-2018" {
			keep seqn mcq160c mcd180c mcq160d mcd180d mcq160e mcd180e mcq160f mcd180f mcq300a mcq170l mcq170m mcq220 mcq160g mcq160k mcq160o mcq160b mcq160l
			rename (mcd180c mcd180d mcd180e mcd180f mcq170l mcq170m mcq220 mcq160g mcq160k mcq160o mcq160b mcq160l) (chd_age angina_age mi_age stroke_age liverConditionNow thyroidConditionNow cancer emphysema chronicBronchitis copd  heartFailure liverDiseaseEver)  
			
			gen pulmObsDisease = .
			replace pulmObsDisease = 2 if emphysema == 1 & chronicBronchitis == 1 & copd == 1
			replace pulmObsDisease = 1 if emphysema == 1 | chronicBronchitis == 1 | copd == 1
			
		}
		
		if "`year'" == "2015-2016" {
			keep seqn mcq160c mcq180c mcq160d mcq180d mcq160e mcq180e mcq160f mcq180f mcq300a mcq170l mcq170m mcq220 mcq160g mcq160k mcq160o mcq160b mcq160l
			rename (mcq180c mcq180d mcq180e mcq180f mcq170l mcq170m mcq220 mcq160g mcq160k mcq160o mcq160b mcq160l) (chd_age angina_age mi_age stroke_age liverConditionNow thyroidConditionNow cancer emphysema chronicBronchitis copd heartFailure liverDiseaseEver) 
			
			gen pulmObsDisease = .
			replace pulmObsDisease = 2 if emphysema == 1 & chronicBronchitis == 1 & copd == 1
			replace pulmObsDisease = 1 if emphysema == 1 | chronicBronchitis == 1 | copd == 1
			
		}
		
		rename (mcq160c mcq160d mcq160e mcq160f mcq300a) (chd angina mi stroke relative_with_mi) 
		
		label define yn 1 "Yes" 2 "No" 7 "Refused" 9 "Don't Know"
		label define age2 80 ">=80" 77777 "Refused" 99999 "Don't Know"
		label values chd angina mi stroke liverConditionNow thyroidConditionNow cancer pulmObsDisease heartFailure liverDiseaseEver yn
		label values chd_age angina_age mi_age stroke_age age2
		
		gen ascvd_mcq = (chd==1 | angina==1 | mi==1 | stroke==1)
		
		cd "$temp"
		save "MCQ_`year'.dta", replace
	

	* Blood pressure and cholesterol
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_BPQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/BPQ_`letter'.XPT", clear
		}
	
		keep seqn bpq020 bpq030 bpd035 bpq040a bpq050a bpq060 bpq070 bpq080 bpq090d bpq100d
		rename bpq020 htn_bpq
		rename bpq030 htnx2
		rename bpd035 htn_age
		rename bpq040a htn_rx_told
		rename bpq050a htn_rx_now
		rename bpq060 chol_checked
		rename bpq070 chol_checked_time
		rename bpq080 chol
		rename bpq090d chol_rx_told
		rename bpq100d chol_rx_now
		label values htn_bpq htnx2 htn_rx_told htn_rx_now chol_checked chol chol_rx_told chol_rx_now yn
		label values htn_age age3
		
		cd "$temp"
		save "BPQ_`year'.dta", replace
		
	
	* Kidney
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_KIQ_U.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/KIQ_U_`letter'.XPT", clear
		}
		
		keep seqn kiq022 kiq025
		rename kiq022 weakKidneys_ever
		rename kiq025 dialysisThisYear
		label values weakKidneys_ever dialysisThisYear yn
		
		cd "$temp"
		save "KIQ_`year'.dta", replace
		
		
	* Smoking
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_SMQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/SMQ_`letter'.XPT", clear
		}
		
		keep seqn smq020 smq040
		rename (smq020 smq040) (ever_smoker current_smoker)
		label define smoke_now_name 1 "Every Day" 2 "Some Days" 3 "Not at All"
		gen smoke_now =(current_smoker==1 | current_smoker==2)
		label values current_smoker smoke_now_name
		
		cd "$temp"
		save "SMQ_`year'.dta", replace
		
		
	* Diabetes
		
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_DIQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/DIQ_`letter'.XPT", clear
		}
		
		keep seqn diq010 did040 diq160
		rename diq010 diabetes
		rename did040 diabetes_age
		rename diq160 prediabetes
		label define yndb 1 "Yes" 2 "No" 3 "Borderline" 7 "Refused" 9 "Don't Know"
		label values diabetes yndb
		label values prediabetes yn
		label values diabetes_age age3
		
		cd "$temp"
		save "DIQ_`year'.dta", replace
		
			
	
	* Health utilization
		
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_HUQ.XPT", clear
			
			keep seqn huq010 huq030 huq051 hud062 huq071
			rename (huq010 huq030 huq051 hud062 huq071) (gen_health place_for_hc times_hc_last_year time_since_last_hc hosp_last_year) 
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/HUQ_`letter'.XPT", clear
			
			keep seqn huq010 huq030 huq051 huq061 huq071
			rename (huq010 huq030 huq051 huq061 huq071) (gen_health place_for_hc times_hc_last_year time_since_last_hc_temp hosp_last_year)
			gen time_since_last_hc = 0 if time_since_last_hc_temp == 6, a(time_since_last_hc_temp)
			replace time_since_last_hc = 1 if time_since_last_hc_temp == 1 | time_since_last_hc_temp == 2
			replace time_since_last_hc = 2 if time_since_last_hc_temp == 3
			replace time_since_last_hc = 3 if time_since_last_hc_temp == 4
			replace time_since_last_hc = 4 if time_since_last_hc_temp == 5
			drop time_since_last_hc_temp
		}
		
		label define gen_health_name 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor" 7 "Refused" 9 "Don't know"
		label define place_for_hc_name 1 "Yes" 2 "There is no place" 3 "There is more than one place" 7 "Refused" 9 "Don't know"
		label define times_hc_last_year 0 "None" 1 "1" 2 "2 to 3" 3 "4 to 5" 4 "6 to 7" 5 "8 to 9" 6 "10 to 12" 7 "13 to 15" 8 "16 or more" 77 "Refused" 99 "Don't know"
		label define time_since_last_hc_name 0 "Never" 1 "≤12 months" 2 "1 to 2 years" 3 "2 to 5 years" 4 ">5 years" 77 "Refused" 99 "Don't know"
		label values gen_health gen_health_name
		label values place_for_hc place_for_hc_name
		label values times_hc_last_year times_hc_last_year_name
		label values time_since_last_hc time_since_last_hc_name
		label values hosp_last_year yn
		
		cd "$temp"
		save "HUQ_`year'.dta", replace
	
		
	* Health insurance
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_HIQ.XPT", clear
			
			rename hiq011 health_insurance
			label values health_insurance yn
			
			gen private_insurance = 1 if hiq032a == 1 | hiq032c == 3
			gen medicare = 1 if hiq032b == 2
			gen medicaid_or_chip = 1 if hiq032d == 4 | hiq032e == 5
			gen gov_insurance = 1 if hiq032h == 8 | hiq032i == 9
			
			egen num_types_insurance = rownonmiss(private_insurance medicare medicaid_or_chip gov_insurance)
		
		}
		
		if "`year'" == "2017-2018" {
			import sasxport5 "`nhanes_url'/`year_url'/HIQ_`letter'.XPT", clear
			
			rename hiq011 health_insurance
			label values health_insurance yn
			
			gen private_insurance = 1 if hiq031a == 14 | hiq031c == 16
			gen medicare = 1 if hiq031b == 15
			gen medicaid_or_chip = 1 if hiq031d == 17 | hiq031e == 18
			gen gov_insurance = 1 if hiq031f == 19 | hiq031h == 21 | hiq031i == 22
			
			egen num_types_insurance = rownonmiss(private_insurance medicare medicaid_or_chip gov_insurance)
		
		}
		
		if "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/HIQ_`letter'.XPT", clear
			
			rename hiq011 health_insurance
			label values health_insurance yn
			
			gen private_insurance = 1 if hiq031a == 14 | hiq031c == 16
			gen medicare = 1 if hiq031b == 15
			gen medicaid_or_chip = 1 if hiq031d == 17 | hiq031e == 18
			gen gov_insurance = 1 if hiq031f == 19 | hiq031g == 20 | hiq031h == 21 | hiq031i == 22
			
			egen num_types_insurance = rownonmiss(private_insurance medicare medicaid_or_chip gov_insurance)
		
		}
		
		gen health_insurance_type = .
		replace health_insurance_type = 1 if private_insurance == 1
		replace health_insurance_type = 2 if medicare == 1
		replace health_insurance_type = 3 if medicaid_or_chip == 1
		replace health_insurance_type = 4 if gov_insurance == 1
		replace health_insurance_type = 5 if num_types_insurance > 1 & num_types_insurance != .
		replace health_insurance_type = 6 if health_insurance == 1 & health_insurance_type == .
		
		label define health_insurance_type_name 1 "Private" 2 "Medicare" 3 "Medicaid/CHIP" 4 "Government" 5 "More than one type" 6 "Unspecified"
		label values health_insurance_type health_insurance_type_name
		
		rename hiq270 rx_coverage 
		label values rx_coverage yn
		rename hiq210 no_insurance_past_year
		label values no_insurance_past_year yn
		
		keep seqn health_insurance health_insurance_type rx_coverage no_insurance_past_year
		order seqn health_insurance health_insurance_type rx_coverage no_insurance_past_year
			
		cd "$temp"
		save "HIQ_`year'.dta", replace
		
		
	* Income
		
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_INQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/INQ_`letter'.XPT", clear
		}
		
		keep seqn indfmmpi indfmmpc
		
		cd "$temp"
		save "INQ_`year'.dta", replace
		
	
	* Alcohol use
		
		if "`year'" == "2017-2020" | "`year'" == "2017-2018" {
			
			if "`year'" == "2017-2020" {
				import sasxport5 "`nhanes_url'/`year_url'/`letter'_ALQ.XPT", clear
			}
			
			if "`year'" == "2017-2018" {
				import sasxport5 "`nhanes_url'/`year_url'/ALQ_`letter'.XPT", clear
			}
			
			keep seqn alq121 alq130
			rename (alq121 alq130) (howOftenDrink drinksPerDay)
		
			gen drinkingDaysPerWeek = .
			replace drinkingDaysPerWeek = 0 if howOftenDrink == 0
			replace drinkingDaysPerWeek = 7 if howOftenDrink == 1
			replace drinkingDaysPerWeek = 5.5 if howOftenDrink == 2
			replace drinkingDaysPerWeek = 3.5 if howOftenDrink == 3
			replace drinkingDaysPerWeek = 2 if howOftenDrink == 4
			replace drinkingDaysPerWeek = 1 if howOftenDrink == 5
			replace drinkingDaysPerWeek = 0.6 if howOftenDrink == 6
			replace drinkingDaysPerWeek = 0.23 if howOftenDrink == 7
			replace drinkingDaysPerWeek = 0.17 if howOftenDrink == 8
			replace drinkingDaysPerWeek = 0.09 if howOftenDrink == 9
			replace drinkingDaysPerWeek = 0.03 if howOftenDrink == 10
			replace drinksPerDay = . if drinksPerDay == 777 | drinksPerDay == 999
			gen drinksPerWeek = drinkingDaysPerWeek * drinksPerDay
			
		}
		
		if "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/ALQ_`letter'.XPT", clear
			
			keep seqn alq120q alq120u alq130
			rename (alq120q alq120u alq130) (numDrinks drinksFreq drinksPerDay)
			
			replace numDrinks = . if numDrinks == 777 | numDrinks == 999
			replace drinksFreq = . if drinksFreq == 7 | drinksFreq == 9
			
			gen drinkingDaysPerWeek = .
			replace drinkingDaysPerWeek = 0 if numDrinks == 0
			replace drinkingDaysPerWeek = numDrinks if drinksFreq == 1
			replace drinkingDaysPerWeek = (numDrinks/30)*7 if drinksFreq == 2
			replace drinkingDaysPerWeek = (numDrinks/365)*7 if drinksFreq == 3
			replace drinksPerDay = . if drinksPerDay == 777 | drinksPerDay == 999
			gen drinksPerWeek = drinkingDaysPerWeek * drinksPerDay
			
		}
		
		cd "$temp"
		save "ALQ_`year'.dta", replace
		
		
	* Diet
			
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_DBQ.XPT", clear
		}
		
		if "`year'" == "2017-2018" {
			import sasxport5 "`nhanes_url'/`year_url'/DBQ_`letter'.XPT", clear
		}
		
		if "`year'" == "2015-2016"  {
			import sasxport5 "`nhanes_url'/`year_url'/DBQ_`letter'.XPT", clear
		}
		
		keep seqn dbd905
		rename dbd905 readyToEatFood
		replace readyToEatFood = 91 if readyToEatFood == 6666
		replace readyToEatFood = . if readyToEatFood == 7777
		replace readyToEatFood = . if readyToEatFood == 9999
		
		cd "$temp"
		save "DBQ_`year'.dta", replace
		
	
	* Physical activity
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_PAQ.XPT", clear
		}
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/PAQ_`letter'.XPT", clear
		}
		
		keep seqn paq605 paq620 paq650 paq665
		
		gen atLeastModActivity = .
		replace atLeastModActivity = 1 if paq605 == 1 | paq620 == 1 | paq650 == 1 | paq665 == 1
		replace atLeastModActivity = 0 if atLeastModActivity != 1 & (paq605 == 2 | paq620 == 2 | paq650 == 2 | paq665 == 2)
		
		keep seqn atLeastModActivity
		
		cd "$temp"
		save "PAQ_`year'.dta", replace
		
		
		
	******
	* EXAMINATION
	******
	
	* Blood pressure
	
		if "`year'" == "2017-2020" | "`year'" == "2017-2018" {
			
			if "`year'" == "2017-2020" {
				import sasxport5 "`nhanes_url'/`year_url'/`letter'_BPXO.XPT", clear
			}
			
			
			if "`year'" == "2017-2018" {
				import sasxport5 "`nhanes_url'/`year_url'/BPXO_`letter'.XPT", clear
			}
			
			keep seqn bpxosy1 bpxodi1 bpxosy2 bpxodi2 bpxosy3 bpxodi3 
			rename bpxosy1 sbp1
			rename bpxodi1 dbp1
			rename bpxosy2 sbp2
			rename bpxodi2 dbp2
			rename bpxosy3 sbp3
			rename bpxodi3 dbp3
			
		}
		
		if "`year'" == "2015-2016" {
			
			import sasxport5 "`nhanes_url'/`year_url'/BPX_`letter'.XPT", clear
		
			keep seqn bpxsy1 bpxdi1 bpxsy2 bpxdi2 bpxsy3 bpxdi3 
			rename bpxsy1 sbp1
			rename bpxdi1 dbp1
			rename bpxsy2 sbp2
			rename bpxdi2 dbp2
			rename bpxsy3 sbp3
			rename bpxdi3 dbp3
			
		}
		
		egen mean_sbp = rowmean(sbp*)
		egen mean_dbp = rowmean(dbp*)
		
		cd "$temp"
		save "BPX_`year'.dta", replace
		
	
	* BMI

		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_BMX.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/BMX_`letter'.XPT", clear
		}
		
		keep seqn bmxbmi
		rename bmxbmi bmi
		
		cd "$temp"
		save "BMI_`year'.dta", replace
		
	******
	* LABORATORY
	******
	
	* HDL
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_HDL.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/HDL_`letter'.XPT", clear
		}
		
		rename lbdhdd hdl
		rename lbdhddsi hdl_si
		label var hdl "mg/dL"
		label var hdl_si "mmol/L"
		
		cd "$temp"
		save "HDL_`year'.dta", replace
		
	
	* Triglycerides
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_TRIGLY.XPT", clear
			
			rename wtsafprp fasting_weight
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/TRIGLY_`letter'.XPT", clear
			
			rename wtsaf2yr fasting_weight
		}
		
		keep seqn fasting_weight lbxtr lbdtrsi lbdldl lbdldlsi
		rename (lbxtr lbdtrsi lbdldl lbdldlsi) (triglycerides triglycerides_si ldl ldl_si)
		label var triglycerides "mg/dL"
		label var ldl "mg/dL"
		label var triglycerides_si "mmol/L"
		label var ldl_si "mmol/L"
		
		* Used Friedewald equation for LDL for 2017 on. That was only option for 2015-2016
		
		cd "$temp"
		save "TRIGLY_`year'.dta", replace
	
	
	* Total cholesterol
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_TCHOL.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/TCHOL_`letter'.XPT", clear	
		}
		
		rename lbxtc tchol
		rename lbdtcsi tchol_si
		label var tchol "mg/dL"
		label var tchol_si "mmol/L"
		
		cd "$temp"
		save "TCHOL_`year'.dta", replace
		
		
	* A1C
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_GHB.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/GHB_`letter'.XPT", clear	
		}
		
		rename lbxgh a1c

		cd "$temp"
		save "GHB_`year'.dta", replace
		
		
	* Creatinine
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_BIOPRO.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/BIOPRO_`letter'.XPT", clear	
		}
		
		keep seqn lbxscr
		rename lbxscr creatinine
		
		cd "$temp"
		save "CR_`year'.dta", replace
	
	******
	* PRESCRIPTIONS
	******		
	
	* Identify ASCVD in the medication indications
	
		if "`year'" == "2017-2020" {
			import sasxport5 "`nhanes_url'/`year_url'/`letter'_RXQ_RX.XPT", clear
		}
			
			
		if "`year'" == "2017-2018" | "`year'" == "2015-2016" {
			import sasxport5 "`nhanes_url'/`year_url'/RXQ_RX_`letter'.XPT", clear
		}
		
		rename rxddrug drugname
		rename rxddrgid drugcode
		rename rxddays days_taken_rx
		rename rxdrsc1 icd_code1
		rename rxdrsc2 icd_code2
		rename rxdrsc3 icd_code3
		rename rxdrsd1 icd_descript1
		rename rxdrsd2 icd_descript2
		rename rxdrsd3 icd_descript3
		rename rxdcount num_meds
		
		replace num_meds = 0 if rxduse == 2
		
		cd "$lookup"
		foreach var of varlist icd_code* {
			rename `var' code
			merge m:1 code using "ascvd icd10 code list.dta", keep(1 3) keepusing(ascvd) update nogenerate
			merge m:1 code using "htn icd10 code list.dta", keep(1 3) keepusing(htnDx) update nogenerate
			merge m:1 code using "type 2 diabetes icd10 code list.dta", keep(1 3) keepusing(t2dmDx) update nogenerate
			rename code `var'
		}
		
		rename (ascvd htnDx t2dmDx) (ascvd_rxq htn_rxq t2dm_rxq)
		
		preserve 
			collapse (max) ascvd_rxq htn_rxq num_meds t2dm_rxq, by(seqn)
			cd "$temp"
			save "RXQ_dx_`year'.dta", replace
		restore
		
	* Identify statins
	
		gen statin = (drugname=="ATORVASTATIN" | drugname =="FLUVASTATIN" | drugname=="LOVASTATIN" | drugname=="PITAVASTATIN" | drugname=="PRAVASTATIN" | drugname=="ROSUVASTATIN" | drugname=="SIMVASTATIN")
		gen atorvastatin = (drugname=="ATORVASTATIN")
		gen fluvastatin = (drugname=="FLUVASTATIN" )
		gen lovastatin = (drugname=="LOVASTATIN" )
		gen pitavastatin = (drugname=="PITAVASTATIN" )
		gen pravastatin = (drugname=="PRAVASTATIN" )
		gen rosuvastatin = (drugname=="ROSUVASTATIN")
		gen simvastatin = (drugname=="SIMVASTATIN")
		gen pos_high_intensity_statin = 0
		replace pos_high_intensity_statin = 1 if atorvastatin == 1 | rosuvastatin == 1
		gen low_intensity_statin = 0
		replace low_intensity_statin = 1 if fluvastatin==1 | lovastatin ==1| pitavastatin==1| pravastatin==1
		gen statinName = ""
		replace statinName = "pitavastatin" if pitavastatin == 1
		replace statinName = "fluvastatin" if fluvastatin == 1
		replace statinName = "lovastatin" if lovastatin == 1
		replace statinName = "pravastatin" if pravastatin == 1
		replace statinName = "simvastatin" if simvastatin == 1
		replace statinName = "atorvastatin" if atorvastatin == 1
		replace statinName = "rosuvastatin" if rosuvastatin == 1
		
	* Identify PCSK9 inhibitors
	
		gen pcsk9 = 1 if strpos(drugname, "ALIROCUMAB") != 0 | strpos(drugname, "EVOLOCUMAB") != 0 | strpos(drugname, "INCLISIRAN") != 0
		replace pcsk9 = 0 if pcsk9 == .
		
	* Identify fibrates
	
		gen fibrate = 1 if strpos(drugname, "GEMFIBROZIL") != 0 | strpos(drugname, "FENOFIBRATE") != 0 
		replace fibrate = 0 if fibrate == .
		
	* Identify interacting medications
	
		gen interactingMed = 1 if strpos(drugname, "AMLODIPINE") != 0 | strpos(drugname, "DILTIAZEM") != 0 | strpos(drugname, "VERAPAMIL") != 0 | strpos(drugname, "DIGOXIN") != 0 | strpos(drugname, "RANOLAZINE") != 0 | strpos(drugname, "CYCLOSPORINE") != 0 | strpos(drugname, "EVEROLIMUS") != 0 | strpos(drugname, "SIROLIMUS") != 0 | strpos(drugname, "TACROLIMUS") != 0 | strpos(drugname, "SACUBITRIL") != 0 | strpos(drugname, "VALSARTAN") != 0
	
		
	* Data cleaning medications
	
		collapse (max) statin pos_high_intensity_statin low_intensity_statin pcsk9 fibrate interactingMed (first) statinName, by(seqn)
		foreach var of varlist statin-interactingMed {
			replace `var' = 0 if `var' == .
		}
		replace low_intensity_statin = 0 if pos_high_intensity_statin == 1
			* if subject has prescriptions for both intensities of statins, giving benefit of the doubt that they are on pos_high_intensity_statin to be conservative
			
		cd "$temp"
		save "RXQ_meds_`year'.dta", replace
		
		
	******
	* MERGE DATASETS
	******
	
	cd "$temp"
	use "DEMO_`year'.dta", clear
	merge 1:1 seqn using "MCQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "BPQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "KIQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "SMQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "DIQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "HUQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "HIQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "INQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "ALQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "PAQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "DBQ_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "BPX_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "BMI_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "HDL_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "TRIGLY_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "TCHOL_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "GHB_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "CR_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "RXQ_dx_`year'.dta", keep(1 3) nogenerate
	merge 1:1 seqn using "RXQ_meds_`year'.dta", keep(1 3) nogenerate
	
	save "merged_`year'.dta", replace
		
}


******
* APPEND YEARS
******

clear
cd "$temp"
append using "merged_2015-2016.dta" "merged_2017-2018.dta" "merged_2017-2020.dta", gen(dataset_temp)
gen dataset = "2015-2016" if dataset_temp == 1
replace dataset = "2017-2018" if dataset_temp == 2
replace dataset = "2017-2020" if dataset_temp == 3
drop dataset_temp

order seqn dataset interview_weight mec_weight fasting_weight

gen main_analysis = 0, a(dataset)
replace main_analysis = 1 if dataset == "2015-2016" | dataset == "2017-2020"
gen sensi_analysis = 0, a(main_analysis)
replace sensi_analysis = 1 if dataset == "2015-2016" | dataset == "2017-2018"

gen main_analysis_weight = 0, a(main_analysis)
gen main_analysis_weight_mec = 0, a(main_analysis_weight)
gen main_analysis_weight_fasting = 0, a(main_analysis_weight_mec)
replace main_analysis_weight = (2/5.2) * interview_weight if dataset == "2015-2016"
replace main_analysis_weight_mec = (2/5.2) * mec_weight if dataset == "2015-2016"
replace main_analysis_weight_fasting = (2/5.2) * fasting_weight if dataset == "2015-2016"

replace main_analysis_weight = (3.2/5.2) * interview_weight if dataset == "2017-2020"
replace main_analysis_weight_mec = (3.2/5.2) * mec_weight if dataset == "2017-2020"
replace main_analysis_weight_fasting = (3.2/5.2) * fasting_weight if dataset == "2017-2020"

gen sensi_analysis_weight = 0, a(sensi_analysis)
gen sensi_analysis_weight_mec = 0, a(sensi_analysis_weight)
gen sensi_analysis_weight_fasting = 0, a(sensi_analysis_weight_mec)

replace sensi_analysis_weight = (2/4) * interview_weight if dataset == "2015-2016"
replace sensi_analysis_weight_mec = (2/4) * mec_weight if dataset == "2015-2016"
replace sensi_analysis_weight_fasting = (2/4) * fasting_weight if dataset == "2015-2016"

replace sensi_analysis_weight = (2/4) * interview_weight if dataset == "2017-2018"
replace sensi_analysis_weight_mec = (2/4) * mec_weight if dataset == "2017-2018"
replace sensi_analysis_weight_fasting = (2/4) * fasting_weight if dataset == "2017-2018"

replace main_analysis_weight_fasting = 0 if main_analysis_weight_fasting == .
replace sensi_analysis_weight_fasting = 0 if sensi_analysis_weight_fasting ==.

gen ascvd = 0
replace ascvd = 1 if ascvd_mcq == 1 ///| ascvd_rxq == 1 * Not counting ascvd ascertained from prescriptions as of 05/23/23

replace statin = 0 if statin == .

gen htn = 0
replace htn = 1 if htn_bpq == 1 | htn_rxq == 1

gen t2dm = 0
replace t2dm = 1 if (diabetes == 1 & diabetes_age >= 45) | t2dm_rxq == 1



cd "$project"
save "statinDisparities_nhanes_extractedData_2015To2020.dta", replace
