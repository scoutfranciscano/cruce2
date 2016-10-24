
local AISB11 = ${AISB11}
local SISB11 = ${SISB11}

local AFSB11 = ${AFSB11}
local SFSB11 = ${SFSB11}
 

 
insheet using "${mydir_Data_SB11_FTP_Cita}\saber 11 `AISB11'-`SISB11'_re.dsv", clear
save "${mydir_Data_SB11_FTP_Cita}\saber11_FTP_Cita.dta", replace

set more off
foreach u of numlist `AISB11'/`AFSB11'{
	foreach v of numlist `SISB11'/`SFSB11'{

		if (`u'==`AISB11' & `v'==`SISB11'){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
		
			clear 
			insheet using "${mydir_Data_SB11_FTP_Cita}\saber 11 `u'-`v'_re.dsv", clear
			cap rename cita_snee v1
			cap rename ftp_consecutivo v2
			keep v1 v2
			drop if _n==1 & v1=="CITA_SNEE"
			append using "${mydir_Data_SB11_FTP_Cita}\saber11_FTP_Cita.dta"
			save "${mydir_Data_SB11_FTP_Cita}\saber11_FTP_Cita.dta", replace
			
		}	
	}		
}			
			
cap drop Origen
	gen Origen = substr(v1,3,5)
tab Origen	
drop Origen	

rename v1 cita_snee
rename v2 ftp_consecutivo

save "${mydir_Data_SB11_FTP_Cita}\saber11_FTP_Cita.dta", replace


	