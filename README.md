# statinDisparities

DESCRIPTION: Statistical programming code for Stata to implement analyses from Disparities in Guideline-Recommended Statin Use for Prevention of Atherosclerotic Cardiovascular Disease by Race, Ethnicity, and Gender: A Nationally Representative Cross-Sectional Analysis of Adults in the United States. Frank DA, Johnson AE, Hausmann LRM , Gellad WF, Roberts ET, and Vajravelu RK. Ann Intern Med. Jul 25 2023. https://doi.org/10.7326/M23-0720. 



FOLDER STRUCTURE: Change folder local macro in “DIRECTORIES” section of each file to your desired directory. Create subfolder titled “Data processing” within your directory. Create subfolders titled “lookup”, “temp”, and “tables” within “Data processing”. Save files “ascvd icd10 code list.dta”, “htn icd10 code list.dta”, and “type 2 diabetes icd10 code list.dta” in “lookup”.


DATA EXTRACTION: Extract required data from NHANES cycles 2015-2016, 2017-2018, and 2017-2020 and organize them in a single file called “statinDisparities_nhanes_extractedData_2015To2020.dta”

DATA PROCESSING: Processes “statinDisparities_nhanes_extractedData_2015To2020.dta” into an analytic dataset. Saves analytic data set as “statinDisparities_nhanes_analyticDataset.dta”
	* Variables:
		- analysis_type (STRING): “main” to use 2015-2016 and 2017-2020 NHANES cycles versus “sensi” to use 2015-2016 and 2017-2018 NHANES cycles.

DATA ANALYSIS: Analyze “statinDisparities_nhanes_analyticDataset.dta” to generate study results described in paper. Calculates descriptive statistics, Table 1 (Participant characteristics), and Table 2 (Unadjusted stain use). Multiply imputes missing data. Adjusted odds ratios for Models 1, 2, and 3 saved in “tables” subfolder as “.csv” files. Adjusted prevalence ratios for race-ethnicty-gender groups for Models 1, 2, and 3 saved in “tables” subfolder as “.dta” files. Adjusted prevalence ratios for covariates for Models 1, 2, and 3 calculated only for main analyses and display in Stata window. Saves the multiply imputed analytic dataset as "statinDisparities_nhanes_analyticDataset_mi.dta”
	* Dependency: mimrgns package
