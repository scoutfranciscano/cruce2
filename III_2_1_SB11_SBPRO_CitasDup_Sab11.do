


**********************************************************************************
// 1A. HALLANDO LOS QUE TIENEN VARIOS SABER11 y GUARDANDO LA CITA  
**********************************************************************************
/*
local AISB11 = ${AISB11}
local SISB11 = ${SISB11}
local AFSB11 = ${AFSB11}
local SFSB11 = ${SFSB11}
*/

/*
use "${mydir_Data_SB11}\SB11_Inscritos_`AISB11'_0`SISB11'_P.dta", clear	

foreach u of numlist `AISB11'/`AFSB11'{
	foreach v of numlist `SISB11'/`SFSB11'{
		if (`u'==`AISB11' & `v'==`SISB11'){
			continue
		}
		else{
			dis "`u'" "-" "`v'" 
				append using  "${mydir_Data_SB11}\SB11_Inscritos_`u'_0`v'_P.dta"
			}
	}
}
	save "${mydir_Data_SB11}\SB11_Inscritos_2002_2011.dta", replace
	*save "${mydir_Data_SB11}\SB11_Inscritos_2002_2011_BOR.dta", replace
*/
	
	use "${mydir_Data_SB11}\sb11_2006-2011_v1-4.dta", clear
	*use "${mydir_Data_SB11}\SB11_Inscritos_2002_2011_BOR.dta", clear
	
			// PEGANDO cole_codigo_colegio QUE SE ME OLVIDO
				/*
				insheet using "C:\Users\jbonilla\Documents\Saber11\Incripcion\saber11_2002_1.dsv", clear
				keep cole_codigo_colegio cita_snee
					cap confirm numeric variable cole_codigo_colegio
					if !_rc {
					   tostring cole_codigo_colegio, force replace
					}
				save "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta", replace


					set more off
					foreach u of numlist 2002/2011{
						foreach v of numlist 1/2{

							if (`u'==2002 & `v'==1){
								continue
							}
							else{
								dis "`u'" "-" "`v'" 

								clear 
								insheet using "C:\Users\jbonilla\Documents\Saber11\Incripcion\saber11_`u'_`v'.dsv", clear
								keep cole_codigo_colegio cita_snee
								
								cap confirm numeric variable cole_codigo_colegio
										if !_rc {
											   tostring cole_codigo_colegio, force replace
										}
								
								append using "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta"
								save "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta", replace
							}	
						}		
					}			
				use "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta", clear
				duplicates report cita_snee
				duplicates drop cita_snee, force
				save "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta", replace
				
				
				
				use "${mydir_Data_SB11}\SB11_Inscritos_2002_2011.dta", clear
				duplicates drop cita_snee, force
				merge 1:1 cita_snee using "C:\Users\jbonilla\Documents\Prov\ProvCodColegio.dta", keep(1 3)
				drop _merge 
				save "${mydir_Data_SB11}\SB11_Inscritos_2002_2011.dta",replace
				
				*/
	
	
	format %40s Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo 
	keep EVAL_PERIODO CITA_SNEE v1 v5 v5_2 v13 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo PN_SxLv PN_SxLv2 dup_PN SN_SxLv SN_SxLv2 dup_SN PA_SxLv PA_SxLv2 dup_PA SA_SxLv SA_SxLv2 dup_SA   Masculino Data_Valid 
	tab  EVAL_PERIODO
	
	
	// Si esta info no esta, no se puede hacer nada para esta gente
		******************************************************************
		drop if v5=="" | PN_SxLv==. | PA_SxLv ==. 
	
	
	// Grupos de ID + Nombre Parcial para el reshape
		**************************************************
	cap drop gr_v5_SxLv
		egen gr_v5_SxLv = group(v5 PN_SxLv PA_SxLv)  
	
	cap drop v0 
		gen v0 = 1
	cap drop r_gr_v5_SxLv // Ranking para reshape (total de citas_snee)
		egen r_gr_v5_SxLv = rank(v0), by(gr_v5_SxLv) unique
		tab r_gr_v5_SxLv 
	
	
	// Reshaping para conservar los diferentes cita_snee de aquelos con igual ID + Nombre Parcial
	***********************************************************************************************
	preserve
		keep CITA_SNEE r_gr_v5_SxLv gr_v5_SxLv
		reshape wide CITA_SNEE, i(gr_v5_SxLv) j(r_gr_v5_SxLv)
		save "${mydir_Data_SB11}\prov.dta",replace	
	restore
	
	
		// Pegando las diferentes citas
	merge m:1 gr_v5_SxLv using "${mydir_Data_SB11}\prov.dta", 
	
	order  EVAL_PERIODO CITA_SNEE CITA_SNEE*
	sort gr_v5_SxLv
	cap ed if CITA_SNEE2!=""

		// Borrando las repeticiones de aquellos con igual v5 y nombre parcial despues de haber salvado las citas adicionales
	tab r_gr_v5_SxLv
	cap ed if CITA_SNEE2!=""
	drop if r_gr_v5_SxLv!=1
	
	
	// Duplicados de v5 que quedan: Personas distintas con igual documento!
	************************************************************************	
	duplicates report v5	
	cap drop r_gr_v5__ // Ranking 
		egen r_gr_v5__ = rank(v0), by(v5) 
		tab r_gr_v5__ 
		cap drop r_gr_v5
		rename r_gr_v5__ r_gr_v5
	tab r_gr_v5
	sort v5
	ed if r_gr_v5!=1
	
	drop if r_gr_v5!=1 // Aqui se borran casi 50mil registros. Pero si se dejan de pueden cometer muchos errores
	
	
	save "${mydir_Data_SB11}\sb11_2006-2011_v1-5.dta", replace
	erase "${mydir_Data_SB11}\prov.dta"
	*erase "${mydir_Data_SB11}\SB11_Inscritos_2002_2011_BOR.dta"
	
	
