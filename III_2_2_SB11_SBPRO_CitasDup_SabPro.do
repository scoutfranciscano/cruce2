
/*
local AISBP = ${AISBP}
local SISBP = ${SISBP}
local AFSBP = ${AFSBP}
local SFSBP = ${SFSBP}
*/
 

**********************************************************************************
// 1B. HALLANDO LOS QUE TIENEN VARIOS SABER-PRO (DOBLE PROGRAMA?)
**********************************************************************************
/*
	
	use "${mydir_Data_SBP}\SBPro_Inscritos_`AISBP'_0`SISBP'_P.dta", clear	

	foreach u of numlist `AISBP'/`AFSBP'{
		foreach v of numlist `SISBP'/`SFSBP'{		
			if (`u'==2007 & `v'==1){
				continue
			}
			else if (`u'==2009 & `v'==1){
				continue
			}
			else if (`u'!=2010 & `v'==3){
				continue
			}
			else{
				dis "`u'" "-" "`v'" 
				append using  "${mydir_Data_SBP}\SBPro_Inscritos_`u'_0`v'_P.dta", force
			}
		}
	}
*/	

use "${mydir_Data_SBPro}\sbpro2012-2014_v1-4.dta", clear
	
	format %40s Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo 
	
	tab  EVAL_PERIODO
	*duplicates report  cita_snee 
	*duplicates report  v5 
	*duplicates report  v5 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13_c
	*duplicates report  v5 PN_SxLv SN_SxLv PA_SxLv SA_SxLv v13_c // Muy parecido al anterior
	
	
	sort v5 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13_c
	
	
	cap drop v0
		gen v0 = 1
	cap drop dup_SBPRO_0
		egen dup_SBPRO_0 = rank(v0), by(v5)
		tab dup_SBPRO_0 
	cap drop dup_SBPRO_1
		egen dup_SBPRO_1 = rank(v0), by(v5 PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino v13_c)
		tab dup_SBPRO_1 
	*tab dup_SBPRO_0 dup_SBPRO_1
	ed if dup_SBPRO_0!=dup_SBPRO_1
	
	
	cap drop dup_SBPRO_2
		egen dup_SBPRO_2 = rank(v0), by(v5 PN_SxLv PA_SxLv Masculino)
		tab dup_SBPRO_2
	*tab dup_SBPRO_0 dup_SBPRO_2
	ed if dup_SBPRO_0!=dup_SBPRO_2
	
	cap drop dup_SBPRO_3 // Ranking para borrar
		egen dup_SBPRO_3 = rank(v0), by(v5 PN_SxLv PA_SxLv Masculino) unique
	*tab dup_SBPRO_3 
	
	
	// Salvando la segunda y tercera cita_snee
									
	cap drop CITA_1
		egen CITA_1 = mode(CITA_SNEE) if dup_SBPRO_0>1 & dup_SBPRO_0!=., by(v5 PN_SxLv PA_SxLv) minmode
	
	cap drop CITA_2
		egen CITA_2 = mode(CITA_SNEE) if dup_SBPRO_0>1 & dup_SBPRO_0!=., by(v5 PN_SxLv PA_SxLv) maxmode

	cap drop CITA_MedP
	gen CITA_MedP = CITA_SNEE if CITA_SNEE!=CITA_1 & CITA_SNEE!=CITA_2 & CITA_1!="" & CITA_2!=""
	cap drop CITA_3
		egen CITA_3 = mode(CITA_MedP) if dup_SBPRO_0>1 & dup_SBPRO_0!=., by(v5 PN_SxLv PA_SxLv) maxmode
		
	sort v5 PN_SxLv PA_SxLv Masculino
	order  EVAL_PERIODO CITA_SNEE  CITA_1 CITA_2 CITA_3 dup_SBPRO_3 
	ed EVAL_PERIODO v5 v7 v8 v9 v10  v13 v13_c CITA_SNEE CITA_1 CITA_2 CITA_3 dup_SBPRO_3 Masculino if CITA_1!=""
	
	drop if dup_SBPRO_3 !=1	
	duplicates report v5, 
	duplicates drop v5, force // Se borran. Son muy pocos
	
	rename CITA_SNEE SBPRO_CITA_SNEE
	rename CITA_1 SBPRO_CITA_SNEE_1
	rename CITA_2 SBPRO_CITA_SNEE_2
	rename CITA_3 SBPRO_CITA_SNEE_3
	
	save "${mydir_Data_SBPro}\sbpro2012-2014_v1-5.dta", replace	
	
	 
/*	
	
**********************************************************************************
// I. CREANDO LOS GRUPOS DE REFERENCIA PARA LOS CRUCES ENTRE SABER11 Y SABER PRO
**********************************************************************************
	
		// Grupo de Referencia 2002 (2007-2010) +4anos seria 2006 pero no existe Saber Pro 2006
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2007 | v1 == 2008 | v1 == 2009 | v1 == 2010 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2002.dta", replace

 
		// Grupo de Referencia 2003 (2007-2011)
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2007 | v1 == 2008 | v1 == 2009 | v1 == 2010 | v1 == 2011 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2003.dta", replace


		// Grupo de Referencia 2004 (2008-2011)
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2008 | v1 == 2009 | v1 == 2010 | v1 == 2011 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2004.dta", replace

	
		// Grupo de Referencia 2005 (2009-2011)
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2009 | v1 == 2010 | v1 == 2011 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2005.dta", replace

	
		// Grupo de Referencia 2006 (2010-2011)
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2010 | v1 == 2011 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2006.dta", replace

	
		// Grupo de Referencia 2007 (2011-2011)
		use "${mydir_Data_SBP}\SBPro_Inscritos_2007_2011.dta", clear
		tab FileOrigen
		keep if v1 == 2011 
		tab FileOrigen
		save "${mydir_Data_SB11P}\SBPro_Inscritos_GrRef_2007.dta", replace

	
