

	
	* 4. Reshaping Saber11 - SaberPro Completo	
	use "${mydir_Data_SB11P}\SB11Pro_2006_2014v2.dta", clear
	
		drop SBPRO_CITA_SNEE_1
		rename SBPRO_CITA_SNEE SBPRO_CITA_SNEE_1		
		keep  CITA_SNEE v5  v13 v13_Min v13_Max  ///
			CITA_SNEE_* ///
			SBPRO_CITA_SNEE_1 SBPRO_CITA_SNEE_2 SBPRO_CITA_SNEE_3  Cod_Icfes c_Cod_Icfes
	
	
		* Llenando missing vars de igual persona
		*************************************
		
			// A. id_cons
			*************************
			cap drop idc_Min
				egen idc_Min = mode(CITA_SNEE), by(Cod_Icfes) minmode
			cap drop idc_Max
				egen idc_Max = mode(CITA_SNEE), by(Cod_Icfes) maxmode	
			ed
			
			drop CITA_SNEE 
			rename idc_Min id_cons_SB11
			rename idc_Max id_cons_SBPro
					
			replace id_cons_SB11 = "" if id_cons_SB11==id_cons_SBPro & regexm(id_cons_SB11,"SBPro")==1
			replace id_cons_SBPro = "" if id_cons_SB11==id_cons_SBPro & regexm(id_cons_SBPro,"SB11")==1
			ed
			
			
			
			// B. Segundo Documento
			*************************
			cap drop v5_Min
				egen v5_Min = mode(v5), by(Cod_Icfes) minmode
			cap drop v5_Max
				egen v5_Max = mode(v5), by(Cod_Icfes) maxmode
			
			ed if length(v5)>=15
			
			drop v5
			rename v5_Min v5_1
			rename v5_Max v5_2
			replace v5_2 = "" if v5_1==v5_2
			
					
			
			// C. Fecha Nacimiento
			*************************
			cou if  v13!= v13_Min &  v13!= v13_Max
			ed v13* if  v13!= v13_Min &  v13!= v13_Max
			drop v13
			
			rename v13_Min v13_1
			rename v13_Max v13_2
			replace v13_2 = "" if v13_1==v13_2
			
						
			
			// C. citas Saber11 y SaberPro
			********************************
			foreach k of varlist CITA_SNEE_* SBPRO_CITA_SNEE_*  {	
					by Cod_Icfes, sort: replace `k'= `k'[_n-1] if `k'==""
					by Cod_Icfes, sort: replace `k'= `k'[_n+1] if `k'==""
				}	
		
		
		order  Cod_Icfes id_cons* v5_* v13*
		gsort -c_Cod_Icfes Cod_Icfes  
		ed 	
		
		
		// Drop duplicates para hacer el reshape
		duplicates drop
		
		
		// Reshape de las citas para pegar la info del FTP luego
		reshape long  CITA_SNEE_  SBPRO_CITA_SNEE_ , i(Cod_Icfes) j(j)	
		
		
		// Para eliminar duplicados, rellenar con las citas los vacios
		rename CITA_SNEE_ SB11_CITA_SNEE
		by Cod_Icfes, sort: replace SB11_CITA_SNEE= SB11_CITA_SNEE[_n-1] if SB11_CITA_SNEE==""
		by Cod_Icfes, sort: replace SB11_CITA_SNEE= SB11_CITA_SNEE[_n-1] if SB11_CITA_SNEE==""
		by Cod_Icfes, sort: replace SB11_CITA_SNEE= SB11_CITA_SNEE[_n-1] if SB11_CITA_SNEE==""
		by Cod_Icfes, sort: replace SB11_CITA_SNEE= SB11_CITA_SNEE[_n-1] if SB11_CITA_SNEE==""
		by Cod_Icfes, sort: replace SB11_CITA_SNEE= SB11_CITA_SNEE[_n-1] if SB11_CITA_SNEE==""
		
		rename SBPRO_CITA_SNEE_ SBPRO_CITA_SNEE
		by Cod_Icfes, sort: replace SBPRO_CITA_SNEE= SBPRO_CITA_SNEE[_n-1] if SBPRO_CITA_SNEE==""
		by Cod_Icfes, sort: replace SBPRO_CITA_SNEE= SBPRO_CITA_SNEE[_n-1] if SBPRO_CITA_SNEE==""
		by Cod_Icfes, sort: replace SBPRO_CITA_SNEE= SBPRO_CITA_SNEE[_n-1] if SBPRO_CITA_SNEE==""
		by Cod_Icfes, sort: replace SBPRO_CITA_SNEE= SBPRO_CITA_SNEE[_n-1] if SBPRO_CITA_SNEE==""
		by Cod_Icfes, sort: replace SBPRO_CITA_SNEE= SBPRO_CITA_SNEE[_n-1] if SBPRO_CITA_SNEE==""
		
		drop j
		duplicates drop
		cou
		
		
		save "${mydir_Data_SB11P}\SB11Pro_2006_2014_Reshape.dta", replace
				
*		save "${mydir_Entrega}\SB11Pro_2002_2011_Reshape.dta", replace
		outsheet using "${mydir_Data_SB11P}\SB11Pro_2006_2014_Reshape.csv", comma replace
		*outsheet using "C:\Users\jbonilla\Documents\Saber11Pro\SB11Pro_2002_2011_Reshape.csv", comma replace
		
		
		
		
		
		
		
		