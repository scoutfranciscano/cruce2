



*****************************************************************************************
* I. PROGRAMA MAESTRO DEL ALGORTIMO DE EDICION DE NOMBRES Y CONSTRUCCION DE SOUNDEX + LEV
*****************************************************************************************
set more off

/*
local AISB11 = ${AISB11}
local SISB11 = ${SISB11}  

local AFSB11 = ${AFSB11}
local SFSB11 = ${SFSB11}
 
local AISBP = ${AISBP}
local SISBP = ${SISBP}

local AFSBP = ${AFSBP}
local SFSBP = ${SFSBP}
*/


* SABER 11
****************	
/*
foreach u of numlist `AISB11'/`AFSB11'{
	foreach v of numlist `SISB11'/`SFSB11'{

		if (`u'==2099 & `v'==2){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
*/
			clear 
			use "${mydir_Data_SB11}\sb11_2006-2011_v1-2.dta", clear			
			
					do "${mydir_DoFiles}\II_Algoritmo_0_Subrutinas_1.do"
					*ed  FileOrigen v3 v3_1 v3_2 v3_3 v5 v5_2 v6 v13 v13_c  v14 v15 v97 v98  v104 v104_1 v104_2 v104_3 v107 v108 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 Masculino Data_Valid NroTotProg Mult_Doc
				
			save  "${mydir_Data_SB11}\sb11_2006-2011_v1-3.dta", replace
	/*
		}
	}
}
*/


* SABER PRO
****************	
/*
foreach u of numlist `AISBP'/`AFSBP'{
	foreach v of numlist `SISBP'/`SFSBP'{		

		if (`u'==2009 & `v'==1){
			continue
		}
		else if (`u'!=2010 & `v'==3){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
*/
			clear 
			use "${mydir_Data_SBPro}\sbpro2012-2014_v1-2.dta", clear			
			
					do "${mydir_DoFiles}\II_Algoritmo_0_Subrutinas_1.do"
					*ed  FileOrigen v3 v3_1 v3_2 v3_3 v5 v5_2 v6 v13 v13_c  v14 v15 v97 v98  v104 v104_1 v104_2 v104_3 v107 v108 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 Masculino Data_Valid NroTotProg Mult_Doc
				
			save  "${mydir_Data_SBPro}\sbpro2012-2014_v1-3.dta", replace
	/*
		}
	}
}
*/


************************************************************
* II. Creando el Directorio de Nombres y Apellidos
************************************************************

**** Acá voy...
do "${mydir_DoFiles}\II_Algoritmo_0_Subrutinas_2.do"




************************************************************
* III. Usando El directorio en los archivos individuales
************************************************************


* SABER 11
****************	

/*	
foreach u of numlist `AISB11'/`AFSB11'{
	foreach v of numlist `SISB11'/`SFSB11'{

		if (`u'==2099 & `v'==2){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
*/
			clear 
			use "${mydir_Data_SB11}\sb11_2006-2011_v1-3.dta", clear			
			
					do "${mydir_DoFiles}\II_Algoritmo_0_Subrutinas_3.do"
					*ed  FileOrigen v3 v3_1 v3_2 v3_3 v5 v5_2 v6 v13 v13_c  v14 v15 v97 v98  v104 v104_1 v104_2 v104_3 v107 v108 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 Masculino Data_Valid NroTotProg Mult_Doc
				
			save  "${mydir_Data_SB11}\sb11_2006-2011_v1-4.dta", replace
/*	
		}
	}
}
*/


* SABER PRO
****************	
/*	
foreach u of numlist `AISBP'/`AFSBP'{
	foreach v of numlist `SISBP'/`SFSBP'{		


		if (`u'==2009 & `v'==1){
			continue
		}
		else if (`u'!=2010 & `v'==3){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
*/
			clear 
			use "${mydir_Data_SBPro}\sbpro2012-2014_v1-3.dta", clear			
			
					do "${mydir_DoFiles}\II_Algoritmo_0_Subrutinas_3.do"
					*ed  FileOrigen v3 v3_1 v3_2 v3_3 v5 v5_2 v6 v13 v13_c  v14 v15 v97 v98  v104 v104_1 v104_2 v104_3 v107 v108 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 Masculino Data_Valid NroTotProg Mult_Doc
				
			save  "${mydir_Data_SBPro}\sbpro2012-2014_v1-4.dta", replace
/*	
		}
	}
}
*/
