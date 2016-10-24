
	
* ESTE DO-FILE SE CORRE DESPUES DE CORRER MAESTRO PARA SABER11 Y SABER PRO
* AL FINAL HAY QUE VOLVER A CORRER MAESTRO PERO USANDO EL DIRECTORIO ACTUALIZADO

	
	
// ADICIONANDO LOS NOMBRES DE SABER11 Y SABER-PRO AL DIRECTORIO Y VOLVIENO A GENERAR EL DIRECTORIO UNICO
*********************************************************************************************************	
	
// Se debe hacer para cada una de las variables v7 v8 v9 v10 por separado
// Se hacen collpase parciales para que el archivo no se vuelva muy grande


* NOTE QUE AQUI YA SE HA CORRIDO EL MAESTRO.DO QUE GENERA LOS ARCHIVOS *_P.dta
* Sin embargo, note que algunos nombres no se encontraron en el directorio
* Se utilizan estos archivos *_P.dta de Saber11 y Pro para generar un diccionario unico aun mas grande
* La idea es volver a generar esos archivos  *_P.dta una vez el diciionario sea mejor

* LO QUE NOS INTERESA DE LOS ARCHIVOS _P ES LA EDICION DE CARACTERES Y SEPARACION DE MONBRES Y APELLIDOS
* Y NO LOS CODIGOS SOUNDEX O LEVESHTEIN

* Note que las variables de nombre se llaman v7, v8, v9, v10 aun cuando lo que se utiliza son las
* variables editadas Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
* Se utilizan estas ultimas para no tener que volver a correr maestro sobre esas variables editadas
* Se utilizan los nombres v7,..,v10 para que el codigo sea igual al que ya se habia hecho antes



********************
* SABER 11
********************

foreach x of numlist 7 8 9 10{

	use "${mydir_Data_SB11}\sb11_2006-2011_v1-3.dta", clear
		
		keep  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
		rename Pri_Nombre v7
		rename Seg_Nombre v8
		rename Pri_Aplldo v9
		rename Seg_Aplldo v10
		
		cap drop dup_v`x'
		gen dup_v`x'=1
		collapse (sum) dup_v`x', by(v`x')
	save "${mydir_Data_SB11}\v`x'.dta", replace	

/*
	local AISB11 = ${AISB11}
	local SISB11 = ${SISB11}
	local AFSB11 = ${AFSB11}
	local SFSB11 = ${SFSB11}
	
	foreach u of numlist `AISB11'/`AFSB11'{
		foreach v of numlist `SISB11'/`SFSB11'{
			if (`u'==2099 & `v'==1){
				continue
			}
			else{
				dis "`u'" "-" "`v'" 

				use "${mydir_Data_SB11}\SB11_Inscritos_`u'_0`v'_P.dta", clear
				
					keep  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
					rename Pri_Nombre v7
					rename Seg_Nombre v8
					rename Pri_Aplldo v9
					rename Seg_Aplldo v10
								
					cap drop dup_v`x'
					gen dup_v`x'=1
					collapse (sum) dup_v`x', by(v`x')
				append using "${mydir_Data_SB11}\v`x'.dta"	
				save "${mydir_Data_SB11}\v`x'.dta", replace	
			}
		}
	}
*/
}


********************
* SABER PRO
********************


foreach x of numlist 7 8 9 10{

	use "${mydir_Data_SBPro}\sbpro2012-2014_v1-3.dta", clear
		
		keep  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
		rename Pri_Nombre v7
		rename Seg_Nombre v8
		rename Pri_Aplldo v9
		rename Seg_Aplldo v10

		cap drop dup_v`x'
		gen dup_v`x'=1
		collapse (sum) dup_v`x', by(v`x')
	save "${mydir_Data_SBPro}\v`x'.dta", replace
	
	
	/*	
	local AISBP = ${AISBP}
	local SISBP = ${SISBP}
	local AFSBP = ${AFSBP}
	local SFSBP = ${SFSBP}

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
				use "${mydir_Data_SBP}\SBPro_Inscritos_`u'_0`v'_P.dta", clear
				
					keep  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
					rename Pri_Nombre v7
					rename Seg_Nombre v8
					rename Pri_Aplldo v9
					rename Seg_Aplldo v10
								
					cap drop dup_v`x'
					gen dup_v`x'=1
					collapse (sum) dup_v`x', by(v`x')
				append using "${mydir_Data_SBP}\v`x'.dta"	
				save "${mydir_Data_SBP}\v`x'.dta", replace	
			}
		}
	}
*/	
}



******************************************************************
// Juntando los nombres de Saber11 y  SaberPro 
******************************************************************

foreach x of numlist 7 8 9 10{
	use "${mydir_Data_SBPro}\v`x'.dta", clear
	append using "${mydir_Data_SB11}\v`x'.dta" // Appending el Vx de Saber11
	collapse (sum) dup_v`x', by(v`x')
	save "${mydir_Data_SB11}\v`x'.dta", replace
	
	erase "${mydir_Data_SBPro}\v`x'.dta"	
	}

	
// Juntando las variables v7 y v8	
use "${mydir_Data_SB11}\v8.dta", clear
	rename dup_v8 dup_v7
	rename v8 v7
	append using "${mydir_Data_SB11}\v7.dta"
	collapse (sum) dup_v7, by(v7)
	count
save "${mydir_Data_SB11}\v78.dta", replace

// Juntando las variables v9 y v10
use "${mydir_Data_SB11}\v10.dta", clear
	rename dup_v10 dup_v9
	rename v10 v9
	append using "${mydir_Data_SB11}\v9.dta"
	collapse (sum) dup_v9, by(v9)
save "${mydir_Data_SB11}\v910.dta", replace


// Juntando v7 v8 v9 v10
use "${mydir_Data_SB11}\v910.dta", clear
rename dup_v9 dup_v7
	rename v9 v7
	append using "${mydir_Data_SB11}\v78.dta"
	collapse (sum) dup_v7, by(v7)
save "${mydir_Data_SB11}\v78910.dta", replace	

	
erase "${mydir_Data_SB11}\v7.dta"
erase "${mydir_Data_SB11}\v8.dta"
erase "${mydir_Data_SB11}\v9.dta"
erase "${mydir_Data_SB11}\v10.dta"
erase "${mydir_Data_SB11}\v78.dta"
*erase "${mydir_Data_SB11}\v79.dta"
erase "${mydir_Data_SB11}\v910.dta"


********************************************************************************************
// Appending los nombres y apellidos de Saber11 y SaberPro al Diccionario Unico
**********************************************************************************************


use "${mydir_Data_SB11}\v78910.dta", clear	
		
		rename v7 NombApll
		rename dup_v7 dup_PNA
		
		// Aqui es donde se juntan los nuevos nombres y apellidos al directorio existente
		*append using "${mydir_DctrData}\Dir_NombApll_SNIES_07_11.dta"
		
		cou
		collapse (sum) dup_PNA, by(NombApll)
		cou
		
		sort NombApll
		duplicates report NombApll
		duplicates tag NombApll, gen(dup_2)
		ed if dup_2>=1
		
		
		// Eliminando algunas entradas erradas del directorio
		**********************************************
		ed if regexm(NombApll,"XX")==1 & regexm(NombApll,"[A-WY-ZÑ]")==0
		replace NombApll = "" if regexm(NombApll,"XX")==1 & regexm(NombApll,"[A-WY-ZÑ]")==0
		
		ed if regexm(NombApll,"^[A-Z]$")==1
		replace NombApll = "" if regexm(NombApll,"^[A-Z]$")==1
		
		ed if regexm(NombApll,"^[A-Z][A-Z]$")==1
		replace NombApll = "" if regexm(NombApll,"^[A-Z][A-Z]$")==1
		
		ed if regexm(NombApll,"^[A-Z][A-Z][A-Z]$")==1
		tab dup_PNA if regexm(NombApll,"^[A-Z][A-Z][A-Z]$")==1
		ed if regexm(NombApll,"^[A-Z][A-Z][A-Z]$")==1 & dup_PNA==730
		ed if regexm(NombApll,"^[A-Z][A-Z][A-Z]$")==1 & dup_PNA==8
		
		collapse (sum) dup_PNA , by(NombApll)
		
	
	
	// I. EDITANDO LOS NOMBRES USANDO ERRORES ORTOGRAFICOS COMUNES
	**********************************************************************************
		cap drop NombApll2 // Se vuelve a reemplazar just despues de los SOUNDEX
		gen NombApll2 = NombApll

			// 1. Ñ al final 
		ed if regexm(NombApll,"Ñ$")==1
		replace NombApll = subinstr(NombApll,"Ñ","N",1) if regexm(NombApll,"Ñ$")==1
		ed if regexm(NombApll2,"Ñ$")==1		
				
		// 2. quitando H intermedias (no CH) por temas de ortografia
		ed if regexm(NombApll,"[ABD-Z]H")==1 // No tiene en cuenta CH
		ed if regexm(NombApll,"[ABD-Z]H")==1 & regexm(NombApll,"CH")==0 		
		replace NombApll = subinstr(NombApll,"H","",1) if  regexm(NombApll,"[ABD-Z]H")==1 & regexm(NombApll,"CH")==0
		ed NombApll NombApll2 if regexm(NombApll2,"[ABD-Z]H")==1 & regexm(NombApll,"CH")==0
		
			// 2A. Apellidos con CH y otra H (Primero aparece la CH y luego la H)
		ed if regexm(NombApll,"[ABD-Z]H")==1 & regexm(NombApll,"CH")==1 
 		ed if regexm(NombApll,"[ ]*[A-GI-Z]*CH")==1 // Todos los registros con CH 
		ed if regexm(NombApll,"[ ]*[A-GI-Z]*CH[ABD-Z]*H")==1 // Todos los registros con CH  y con otra H (pero no otra CH)
		ed if regexm(NombApll,"([ ]*[A-GI-Z]*CH[ABD-Z]*)(H)([A-Z]*)")==1 // Primero aparece la CH y luego la H
		replace NombApll = regexs(1)+regexs(3) if regexm(NombApll,"([ ]*[A-GI-Z]*CH[ABD-Z]*)(H)([A-Z]*)")==1
		ed NombApll NombApll2 if regexm(NombApll2,"([ ]*[A-GI-Z]*CH[ABD-Z]*)(H)([A-Z]*)")==1 
		
			// 2B. Apellidos con H y otra CH (Primero aparece la H y luego la CH)
		ed if regexm(NombApll,"([A-Z]*[ABD-Z])(H)([A-Z]*CH[A-Z]*)")==1 // Primero aparece la H y luego la CH
		replace NombApll = regexs(1)+regexs(3) if regexm(NombApll,"([A-Z]*[ABD-Z])(H)([A-Z]*CH[A-Z]*)")==1
		ed NombApll NombApll2 if regexm(NombApll2,"([A-Z]*[ABD-Z])(H)([A-Z]*CH[A-Z]*)")==1
		
		
		// 3. quitando temporalmente H inicial para calcular el soundex
		ed if regexm(NombApll,"^H")==1 // 
		replace NombApll = subinstr(NombApll,"H","",1) if  regexm(NombApll,"^H")==1
		ed NombApll NombApll2  if regexm(NombApll2,"^H")==1 // No tiene en cuenta CH
		
		
		// 4. Modificaciones para mejorar el desempeño del Soundex

			// YA POR JA
		ed if regexm(NombApll,"^YA")==1 
		replace NombApll = regexr(NombApll,"^YA","JA")
		
			// YO POR JO
		ed if regexm(NombApll,"^YO")==1 
		replace NombApll = regexr(NombApll,"^YO","JO")
		
			// YU POR JU
		ed if regexm(NombApll,"^YU")==1 
		replace NombApll = regexr(NombApll,"^YU","JU")
			
			// YE, GE POR E (EL SONIDO HE YA SE CAMBIO POR E ARRIBA)
		ed if regexm(NombApll2,"^YE")==1 
		replace NombApll = regexr(NombApll,"^YE","E")
		ed if regexm(NombApll2,"^GE")==1 
		replace NombApll = regexr(NombApll,"^GE","E")
			
			// YI, GI POR I (EL SONIDO HI YA SE CAMBIO POR I ARRIBA)
		ed if regexm(NombApll,"^YI")==1 
		replace NombApll = regexr(NombApll,"^YI","I")
		ed if regexm(NombApll,"^GI")==1 
		replace NombApll = regexr(NombApll,"^GI","I")
		
			// LL
		ed if regexm(NombApll,"^LL")==1   
		
			// B POR V
		ed if regexm(NombApll,"^B")==1 | regexm(NombApll,"^V")==1 
		replace NombApll = regexr(NombApll,"^V","B")
		
			// U POR W
		ed if regexm(NombApll,"^U[AEIO]")==1 		
		replace NombApll = regexr(NombApll,"^UA","WA")
		replace NombApll = regexr(NombApll,"^UE","WE")
		replace NombApll = regexr(NombApll,"^UI","WI")
		replace NombApll = regexr(NombApll,"^UO","WO")
		
			// KA KO KU POR CA CO CU
		ed if regexm(NombApll,"^K[AOU]")==1 
		replace NombApll = regexr(NombApll,"^KA","CA")
		replace NombApll = regexr(NombApll,"^KO","CO")
		replace NombApll = regexr(NombApll,"^KU","CU")
		ed NombApll NombApll2 if regexm(NombApll2,"^K[AOU]")==1
		
			// KE KI POR QUE QUI
		ed if regexm(NombApll,"^Q[UEI]")==1 
		replace NombApll = regexr(NombApll,"^QUE","KE")
		replace NombApll = regexr(NombApll,"^QUI","KI")
		
			// CH
		ed if regexm(NombApll,"^CH")==1 
		
			// X algunas veces suena como S otras como J
		ed if regexm(NombApll,"^X")==1 
		replace NombApll = regexr(NombApll,"^XA","JA") // ex. Javier
		replace NombApll = regexr(NombApll,"^XE","SE") // ex. Xenia
		replace NombApll = regexr(NombApll,"^XI","SI") if NombApll!="XIMENA" // ex. Xilene
		replace NombApll = "JIMENA" if NombApll=="XIMENA" // 
		ed NombApll NombApll2 if regexm(NombApll2,"^X")==1
		
			// S por Z
		ed if regexm(NombApll,"^Z")==1 
		replace NombApll = regexr(NombApll,"^Z","S") // 
		
			// CE CI por SE SI
		ed if regexm(NombApll,"^CE")==1 | regexm(NombApll,"^CI")==1
		ed if regexm(NombApll,"^SE")==1 | regexm(NombApll,"^SI")==1
		replace NombApll = regexr(NombApll,"^CE","SE") // 
		replace NombApll = regexr(NombApll,"^CI","SI") // 
	
		
		
	// II. SOUNDEX
	*****************************************************************************************	
	
		// A. SOUNDEX: Borra caracteres repetidos, NO incluye las codigo de vocales (Mas falsos positivos)
	cap drop PNA_sdx 
		egen PNA_sdx=soundex(NombApll), length(12) 
	cap drop gr_PNA_sdx
		egen gr_PNA_sdx = group(PNA_sdx)
	cap drop dup_PNA_sdx 
		egen dup_PNA_sdx = count(NombApll!=""), by(PNA_sdx)
	sort PNA_sdx
	ed
	
		// B. SDXESP: Borra caracteres repetidos, SI incluye las codigo de vocales 
	cap drop PNA_sdx2 
		egen PNA_sdx2=sdxesp(NombApll), length(12) // Borra caracteres repetidos, SI incluye las codigo de vocales
	cap drop gr_PNA_sdx2
		egen gr_PNA_sdx2 = group(PNA_sdx2)
	cap drop dup_PNA_sdx2 
		egen dup_PNA_sdx2 = count(NombApll!=""), by(PNA_sdx2)
	sort PNA_sdx2
	ed
	
	
	// Retornando a la variable original que es como se usa en los archivos a cruzar (i.e. sin los reemplazos de 
	// edicion por ortografia). Note que se hace despues del soundex para que este asigne en el mismo grupo a Yessica y 
	// a Jessica
	replace NombApll = NombApll2
	drop NombApll2
	
	// Quitando espacios de nombre multi-palabra porque si no el levenshtein cuenta cada espacio como un error
	cap drop NombApll2 //Variable temporal sin espacios 
	gen NombApll2 = subinstr(NombApll," ","",10)
	
	drop if NombApll==""
	save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", replace
	
		
	
	// III. LEVENSHTEIN
	**********************************************************************************************
			
	// A. gr_PN_sdx: A partir de SOUNDEX 
	***************************************
	
	
	use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", clear
		sum  gr_PNA_sdx
		local maxgr = r(max) // Obtienen el final del loop
		keep if gr_PNA_sdx==1
		cap drop PNA_lvt // Leveshentein al interior de los codigos SOUNDEX con edit distance igual a 1
		bysort gr_PNA_sdx: strgroup NombApll, gen(PNA_lvt) threshold(1) normalize(none)
		
		cap drop dup_PNA_lvt // Dup del levenshtein
		egen dup_PNA_lvt = count(NombApll!=""), by(PNA_lvt)
		save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta", replace
			
		
		*local fin 10000  `maxgr'
		*foreach start of numlist 1 10001 {
		
		local f1 = int(`maxgr'/2) // Esto hay que separarlo porque a veces el codigo explota si se hace todo de una
		local f2 = int(`maxgr'/2)+1
		local fin `f1'  `maxgr'
		foreach start of numlist 1 `f2'{
		
			local x = "`start'"
			gettoken tk fin:fin			
			while `x' <=`tk'{
				dis "`x'"
				dis "`tk'"				
					use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", clear
					keep if gr_PNA_sdx==`x'
					cap drop PNA_lvt // Leveshentein al interior de los codigos soundex version 3 con edit distance igual a 1
					bysort gr_PNA_sdx: strgroup NombApll2, gen(PNA_lvt) threshold(1) normalize(none)
					cap drop dup_PNA_lvt // Dup del levenshtein
					egen dup_PNA_lvt = count(NombApll!=""), by(PNA_lvt)
					append using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta"
					save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta", replace				
				local x = `x'+1
			}
			save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`start'.dta", replace				
		}	
		
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_1.dta"
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`f2'.dta"
		
		
		
		
		// Creando un Codigo unico de identificacion
	cap drop NmAp_SxLv
	egen NmAp_SxLv = group(gr_PNA_sdx PNA_lvt)
	codebook NmAp_SxLv
	ed
	
	order NmAp_SxLv NombApll dup_PNA_sdx gr_PNA_sdx PNA_sdx PNA_lvt dup_PNA_lvt 	
	gsort  -dup_PNA_lvt NmAp_SxLv NombApll
	ed

	
			// Se retorna el nombre original (con posibles errores)
	drop NombApll2
	
	tab dup_PNA_lvt // Aquellos con muchas repeticiones
	ed if  dup_PNA_lvt==1
	ed if dup_PNA_lvt>=4
	ed if dup_PNA_lvt>=100
	
		// Los que no se agrupan con ningun otro nombre pero muchos tienen ese mombre
	ed if dup_PNA_lvt==1 & dup_PNA>10
	sum dup_PNA if dup_PNA_lvt==1, detail
	
	save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", replace	
	*erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta"
	
	
	// B. gr_PN_sdx: A partir de SDXESP 
	******************************************
		
	use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", clear	
	cap drop NombApll2 //Variable temporal sin espacios 
	gen NombApll2 = subinstr(NombApll," ","",10)
	save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", replace	
	
	
	use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", clear
		sum  gr_PNA_sdx2
		local maxgr = r(max) // Obtienen el final del loop
		keep if gr_PNA_sdx2==1
		cap drop PNA_lvt2 // Leveshentein al interior de los codigos SDXESP con edit distance igual a 1
		bysort gr_PNA_sdx2: strgroup NombApll, gen(PNA_lvt2) threshold(1) normalize(none)
		
		cap drop dup_PNA_lvt2 // Dup del levenshtein
		egen dup_PNA_lvt2 = count(NombApll!=""), by(PNA_lvt2)
		save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta", replace
		
		
		*local fin 10000 20000 30000 40000 `maxgr'
		*	foreach start of numlist 1 10001 20001 30001 40001 {	
		*local fin 100 `maxgr'
		*foreach start of numlist 1 101 {		
		
		// Esto hay que separarlo porque a veces el codigo explota si se hace todo de una
		local f1 = int(1*`maxgr'/5) 
		local f2 = int(1*`maxgr'/5)+1
		local f3 = int(2*`maxgr'/5)
		local f4 = int(2*`maxgr'/5)+1
		local f5 = int(3*`maxgr'/5)
		local f6 = int(3*`maxgr'/5)+1
		local f7 = int(4*`maxgr'/5)
		local f8 = int(4*`maxgr'/5)+1
		local fin `f1' `f3' `f5' `f7' `maxgr'
		foreach start of numlist 1 `f2' `f4' `f6' `f8' {	
		
			local x = "`start'"
			gettoken tk fin:fin			
			while `x' <=`tk'{
				dis "`x'"
				dis "`tk'"				
				use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", clear
				keep if gr_PNA_sdx2==`x'
				cap drop PNA_lvt2 // Leveshentein al interior de los codigos soundex version 3 con edit distance igual a 1
				bysort gr_PNA_sdx2: strgroup NombApll2, gen(PNA_lvt2) threshold(1) normalize(none)
				cap drop dup_PNA_lvt2 // Dup del levenshtein
				egen dup_PNA_lvt2 = count(NombApll!=""), by(PNA_lvt2)
				append using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta"
				save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta", replace	
				local x = `x'+1
			}
			save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`start'.dta", replace				
		}	
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_1.dta"
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`f2'.dta"
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`f4'.dta"
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`f6'.dta"
		erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1_`f8'.dta"
	
	
	
	
	
	use "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta", clear
		
		// Creando un Codigo unico de identificacion
	cap drop NmAp_SxLv2
	egen NmAp_SxLv2 = group(gr_PNA_sdx2 PNA_lvt2)
	codebook NmAp_SxLv2
	ed
	
	order NombApll NmAp_SxLv  dup_PNA_sdx  gr_PNA_sdx  PNA_sdx  PNA_lvt  dup_PNA_lvt ///
				   NmAp_SxLv2 dup_PNA_sdx2 gr_PNA_sdx2 PNA_sdx2 PNA_lvt2 dup_PNA_lvt
	gsort  -dup_PNA_lvt2 NmAp_SxLv2 NombApll
	ed

	
			// Se retorna el nombre original (con posibles errores)
	drop NombApll2
	
	tab dup_PNA_lvt2 // Aquellos con muchas repeticiones
	ed if  dup_PNA_lvt2==1
	ed if dup_PNA_lvt2>=4
	ed if dup_PNA_lvt2>=100
	
		// Los que no se agrupan con ningun otro nombre pero muchos tienen ese mombre
	ed if dup_PNA_lvt2==1 & dup_PNA>10
	sum dup_PNA if dup_PNA_lvt2==1, detail
	
	
	duplicates report NombApll
	duplicates drop NombApll, force
	
	save "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", replace	
	erase "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11_1.dta"

	
	
	
	