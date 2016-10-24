


// 1. Insheeting all the FTP and Cita Files

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2007-1_re.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2007_1.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2007-2_re.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2007_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\SNEE_CONSECUTIVO_FINAL 2008-1.txt", clear names
rename  estu_consecutivo_ftp ftp_consecutivo
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2008_1.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\SNEE_CONSECUTIVO_FINAL 2008-2_1.txt", clear names
rename  estu_consecutivo_ftp ftp_consecutivo
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2008_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2009-2 especificos_re.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2009_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2009-2 genericos_re.dsv", clear names
append using "${mydir_Data_SBPro_FTP_Cita}\SBPro2009_2.dta"
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2009_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2010-2 especifico.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2010-2 generico.dsv", clear names
append using "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_2.dta"
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_2.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2010-3 especifico_re.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_3.dta", replace


insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2010-3 generico_re.dsv", clear names
append using "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_3.dta"
duplicates drop
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2010_3.dta", replace


insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2011-1 generico_re.dsv", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2011_1.dta", replace

insheet using "${mydir_Data_SBPro_FTP_Cita}\saber pro 2011-2 generico_re.txt", clear names
save "${mydir_Data_SBPro_FTP_Cita}\SBPro2011_2.dta", replace


// 2. Appending all the files


use "${mydir_Data_SBPro_FTP_Cita}\SBPro2007_1.dta", clear
save "${mydir_Data_SB11_FTP_Cita}\SaberPro_FTP_Cita.dta", replace

foreach u of numlist 2007/2011{
	foreach v of numlist 1/3{

		if (`u'==2007 & `v'==1){
			continue
		}		
		else if (`u'==2009 & `v'==1){
			continue
		}
		else if (`u'==2010 & `v'==1){
			continue
		}
		else if (`u'!=2010 & `v'==3){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
			use "${mydir_Data_SBPro_FTP_Cita}\SBPro`u'_`v'.dta", clear
			append using "${mydir_Data_SB11_FTP_Cita}\SaberPro_FTP_Cita.dta"
			save "${mydir_Data_SB11_FTP_Cita}\SaberPro_FTP_Cita.dta", replace	
		}
	}	
}			

drop if ftp_consecutivo==""
duplicates drop ftp_consecutivo, force // Solo se borra 1 registro
save "${mydir_Data_SB11_FTP_Cita}\SaberPro_FTP_Cita.dta", replace	



