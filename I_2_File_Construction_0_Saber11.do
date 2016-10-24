
/* Este do-file toma el archivo de SABER11 2006 - 2011, los carga en STATA, les asigna labels
 a las variables, se queda solo con las variables relevantes y guarda un archivo menos pesado
 y por tanto mas manejable. Además realiza los cambios necesarias para limpiar las variables 
 de interés de carácteres raros. */

/*
local AISB11 = ${AISB11}
local SISB11 = ${SISB11}

local AFSB11 = ${AFSB11}
local SFSB11 = ${SFSB11}
*/
 
set more off
// foreach u of numlist `AISB11'/`AFSB11'{
//	foreach v of numlist `SISB11'/`SFSB11'{

//		if (`u'==2099 & `v'==2){
//			continue
//		}
//		else{
//			dis "`u'" "-" "`v'" 
//
			clear 
			use "${mydir_Data_SB11}\sb11_2006-2011_v1-1.dta", clear
			
		
			*=========================================================================================
			// Este If utiliza solo 100 registros de cada archivo para hacer pruebas
			local short = ${short} 
			if `short'==1{
				keep if  EVAL_TIPODOCUMENTO=="C"
				sort   EVAL_DOCUMENTO
				keep in 1/100
			} 
	//		else{
	//			continue
	//		}	
			*=========================================================================================
			
					
			// I. VARIABLES COMUNES CON SNIES PARA CORRE LOS MISMOS PROGRAMAS
				
				* Place Holder
				**************
				cap drop v1
				*local u = 2004
				gen v1 = substr(string(EVAL_PERIODO),1,4)
				
				// A partir de la fecha de nacimiento se generan las variables de
				// día, mes y año.
				
				gen estu_nacimiento_dia=substr(INPE_FECHANACIMIENTO,1,2)
				
				gen estu_nacimiento_mes=substr(INPE_FECHANACIMIENTO,4,2)
				
				gen estu_nacimiento_anno=substr(INPE_FECHANACIMIENTO,7,2)
							
				* Fecha Nacimiento
				********************
					foreach v1 of varlist estu_nacimiento_dia estu_nacimiento_mes estu_nacimiento_anno{
						cap confirm string variable `v1' // Confirmando que estas variables son tipo Numerico
							if !_rc {
							   destring `v1', replace force
							}	
					}
					
					cap  drop v13
					cap	 gen v13 = string(estu_nacimiento_dia)+"/"+string(estu_nacimiento_mes)+"/"+substr(string(estu_nacimiento_anno),3,2) ///
									if length(string(estu_nacimiento_dia))==2 & length(string(estu_nacimiento_mes))==2
						replace v13 = "0"+string(estu_nacimiento_dia)+"/"+string(estu_nacimiento_mes)+"/"+substr(string(estu_nacimiento_anno),3,2) ///
									if length(string(estu_nacimiento_dia))==1 & length(string(estu_nacimiento_mes))==2
						replace v13 = string(estu_nacimiento_dia)+"/"+"0"+string(estu_nacimiento_mes)+"/"+substr(string(estu_nacimiento_anno),3,2) ///
									if length(string(estu_nacimiento_dia))==2 & length(string(estu_nacimiento_mes))==1
						replace v13 = "0"+string(estu_nacimiento_dia)+"/"+"0"+string(estu_nacimiento_mes)+"/"+substr(string(estu_nacimiento_anno),3,2) ///
									if length(string(estu_nacimiento_dia))==1 & length(string(estu_nacimiento_mes))==1
					ed 	estu_nacimiento_dia estu_nacimiento_mes estu_nacimiento_anno v13 if v13!=""
						
					
				* Documento y Tipo de Documento
				********************************
					cap drop v6
						gen v6 = ""
						replace v6 = "CC" if INPE_TIPODOCUMENTO=="C" | INPE_TIPODOCUMENTO=="c"
						replace v6 = "TI" if INPE_TIPODOCUMENTO=="T" | INPE_TIPODOCUMENTO=="t"
					tab v6
					
					
					cap confirm numeric variable estu_documento
						if !_rc {
							   tostring INPE_DOCUMENTO, force replace
						}
					cap drop v5
						gen v5 = ""
						replace v5 = INPE_DOCUMENTO 
					
				* Genero
				***********
					cap drop v12
					cap gen v12 = ""
					cap replace v12 = "MASCULINO" if estu_genero=="M"
					cap replace v12 = "FEMENINO" if estu_genero=="F"
					cap tab v12
					
					
				* Colegio
				****************
					cap drop v3
						gen v3 =  INST_ID 
						cap confirm string variable v3 // Confirmando que estas variables son tipo Numerico
							if !_rc {
							   destring v3, replace force
							}	
							
					cap drop v104 // Se repite el mismo codigo de colegio para poder correr el algortimo en SNIES y en ICFES sin distincion
						gen v104 =  INST_ID
						cap confirm numeric variable v104
							if !_rc {
								   tostring v104, force replace
							}
					
				/* Ano y semestre entrada: 
				*************************
				//Solo para SNIES. Se crea aqui por consistencia en el algortimo pero para ICFES no significa mayor caso
					cap drop v107
						gen v107 = `u'
					cap confirm numeric variable v107
							if !_rc {
								   tostring v107, force replace
							}
					*ed v107	
					
					cap drop v108
						gen v108 = `v'
					cap confirm numeric variable v108
							if !_rc {
								   tostring v108, force replace
							}
					*ed v108	
					
					cap drop v1078
						gen v1078 = v107 + "0" + v108
					*ed v1078
				*/	
				
				
				* Nombre
				*******************
				capture confirm variable  EVAL_NOMBRE
				if !_rc {
							   di in red "estu_nombre exists"
							   cap drop NameProv 
							   gen NameProv =  EVAL_NOMBRE
							   run "${mydir_DoFiles}\II_Algoritmo_1_EditorDeNombresyApellidos.do" // Identifica registros con caracteres extranos
							   run "${mydir_DoFiles}\I_A_File_Construction_1_SeparadorNomAp.do"
					   }
					   else {
							   di in red "estu_nombre does not exist"
							   cap drop v7
								 gen v7 =   INPE_PRIMERNOMBRE
							   cap drop v8
								 gen v8 =   INPE_SEGUNDONOMBRE
							   cap drop v9
								 gen v9 =   INPE_PRIMERAPELLIDO
							   cap drop v10_
								gen v10_ =  INPE_SEGUNDOAPELLIDO
								rename v10_ v10
							}

				
				
				* Fileorigen	
				****************
				cap drop FileOrigen
				gen SB11 = "SB11"
				egen FileOrigen = concat(SB11 EVAL_PERIODO)
				drop SB11
				drop EVAL_PERIODO
				gen EVAL_PERIODO = FileOrigen
				drop FileOrigen
				order EVAL_PERIODO
	
/*
				
				* Creando codigo unico 
				*****************************************************************
				//Despues se le cambia el nonmbre a id_S11
				cap drop id_cons // Este serir el Numero ICFES FTP pero no lo tengo
				gen id_cons = FileOrigen + "-" + string(1000000+_n)
				replace id_cons = regexr(id_cons,"-1","-")
				ed id_cons 
				*/	
					
					* Keeping only relevant variables 
					order  EVAL_PERIODO CITA_SNEE v1 v3 v5 v6 v7 v8 v9 v10 v12 v13 v104
					keep  EVAL_PERIODO CITA_SNEE v1 v3 v5 v6 v7 v8 v9 v10 v12 v13 v104 

					save "${mydir_Data_SB11}\sb11_2006-2011_v1-2.dta", replace




