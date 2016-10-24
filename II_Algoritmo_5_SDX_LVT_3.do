

// No es necesario si los diccionarios funcionan
	/*
	cap drop PN_sdx
	egen PN_sdx=sdxesp(Pri_Nombre), length(12) 
	
	cap drop SN_sdx
	egen SN_sdx=sdxesp(Seg_Nombre), length(12)
	
	cap drop PA_sdx
	egen PA_sdx=sdxesp(Pri_Aplldo), length(12) 
	
	cap drop SA_sdx
	egen SA_sdx=sdxesp(Seg_Aplldo), length(12)
		
	sort PN_sdx
	*ed  v7 v8 v9 v10 Pri_Nombre Seg_Nombre Ter_Nombre Qto_Nombre PN_sdx SN_sdx
	*ed  v7 v8 v9 v10 Pri_Nombre Seg_Nombre PN_sdx SN_sdx
	*/

	
		
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	format %50s Pri_Nombre Seg_Nombre Pri_Aplldo  Seg_Aplldo 	
	
		
		// Quitando espacios en blanco al principio y al final. Quitando iniciales porqu si no no pega 
	*ed Pri_Nombre if regexm(Pri_Nombre,"^ ") ==1
	*ed Seg_Nombre if regexm(Seg_Nombre,"^ ") ==1
	*ed Pri_Aplldo if regexm(Pri_Aplldo,"^ ") ==1
	*ed Seg_Aplldo if regexm(Seg_Aplldo,"^ ") ==1
	foreach x of varlist Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo{
		replace `x' = regexr(`x',"^ ","")
		replace `x' = regexr(`x',"^ ","")
		replace `x' = regexr(`x'," $","")
		replace `x' = regexr(`x'," $","")
		replace `x' = regexr(`x',"^[A-ZÑ]$","")		
	}
	
	
	* NOTA:
	*********
	* Las variables de Soundex Leveshtein (*_SxLv2) terminadas en 2 son aquellas que usan sdxesp(.)
	* donde SDXESP se caracteriza por borrar caracteres repetidos, e incluye las vocales en el codigo
	* Aquellos sin numero (*_SxLv ) son los que resultan de usar soundex(.), que borra todas las vocales
	
	
	
	// A. MERGE POR PRIMER NOMBRE
	*******************************************************************

	
		//Merging con el diccionario de nombres
	rename Pri_Nombre NombApll
	cap drop PN_SxLv PN_SxLv2 PN_sdx PN_sdx2
	cap drop dup_PN
		
	merge m:1 NombApll using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", ///
		keepusing(NmAp_SxLv NmAp_SxLv2 PNA_sdx PNA_sdx2 dup_PNA ) keep(1 3) gen(_mergePN)
	
	rename NombApll Pri_Nombre 
	rename NmAp_SxLv PN_SxLv 
	rename NmAp_SxLv2 PN_SxLv2 
	rename PNA_sdx PN_sdx
	rename PNA_sdx2 PN_sdx2
	rename dup_PNA dup_PN
	
	tab _mergePN
	*tab  Pri_Nombre if  _mergePN==1 & Pri_Nombre!="" // Para ver potenciales errores de nombres que son apellidos y hay que incluir en la lista	
	*ed v7 v8 v9 v10 Pri_Nombre if _mergePN==1	// Note que muchos de estos son appelidos porque el estudiante escribio
	
	
	// B. MERGE POR SEGUNDO NOMBRE
	*******************************************************************
		
		//Merging con el diccionario de nombres
	rename Seg_Nombre NombApll
	cap drop SN_SxLv SN_SxLv2 SN_sdx SN_sdx2
	cap drop dup_SN
	
	merge m:1 NombApll using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", ///
		keepusing(NmAp_SxLv NmAp_SxLv2 PNA_sdx PNA_sdx2 dup_PNA ) keep(1 3) gen(_mergeSN)
	
	rename NombApll Seg_Nombre 
	rename NmAp_SxLv SN_SxLv 
	rename NmAp_SxLv2 SN_SxLv2 
	rename PNA_sdx SN_sdx
	rename PNA_sdx2 SN_sdx2
	rename dup_PNA dup_SN
	
	tab _mergeSN
	tab _mergeSN if Seg_Nombre != ""
	*tab  Seg_Nombre if  _mergeSN==1 & Seg_Nombre!="" // Para ver potenciales errores de nombres que son apellidos y hay que incluir en la lista	
	*ed v7 v8 v9 v10 Seg_Nombre if _mergeSN==1	// Note que muchos de estos son appelidos porque el estudiante escribio
	
	
	
	// C. MERGE POR PRIMER APELLIDO
	*******************************************************************
		
		//Merging con el diccionario de nombres
	rename Pri_Aplldo NombApll
	cap drop PA_SxLv PA_SxLv2 PA_sdx PA_sdx2
	cap drop dup_PA
	
	merge m:1 NombApll using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", ///
		keepusing(NmAp_SxLv NmAp_SxLv2 PNA_sdx PNA_sdx2 dup_PNA ) keep(1 3) gen(_mergePA)
	
	rename NombApll Pri_Aplldo 
	rename NmAp_SxLv PA_SxLv 
	rename NmAp_SxLv2 PA_SxLv2 
	rename PNA_sdx PA_sdx
	rename PNA_sdx2 PA_sdx2
	rename dup_PNA dup_PA
	
	tab _mergePA
	*tab  Pri_Aplldo if  _mergePA==1 & Pri_Aplldo !="" // Para ver potenciales errores de nombres que son apellidos y hay que incluir en la lista	
	*ed v7 v8 v9 v10 Pri_Aplldo  if _mergePA==1	// Note que muchos de estos son appelidos porque el estudiante escribio
	
	
	
	// D. MERGE POR SEGUNDO APELLIDO
	*******************************************************************
		
		//Merging con el diccionario de nombres
	rename Seg_Aplldo NombApll
	cap drop SA_SxLv SA_SxLv2 SA_sdx SA_sdx2
	cap drop dup_SA
	
	merge m:1 NombApll using "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta", ///
		keepusing(NmAp_SxLv NmAp_SxLv2 PNA_sdx PNA_sdx2 dup_PNA ) keep(1 3) gen(_mergeSA)
	
	rename NombApll Seg_Aplldo 
	rename NmAp_SxLv SA_SxLv 
	rename NmAp_SxLv2 SA_SxLv2 
	rename PNA_sdx SA_sdx
	rename PNA_sdx2 SA_sdx2
	rename dup_PNA dup_SA
	
	tab _mergeSA
	tab _mergeSA if Seg_Aplldo !="" 
	*tab  Seg_Aplldo if  _mergeSA==1 & Seg_Aplldo !="" // Para ver potenciales errores de nombres que son apellidos y hay que incluir en la lista	
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo  if _mergeSA==1	& Seg_Aplldo !="" // Note que muchos de estos son appelidos porque el estudiante escribio
	
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo PA_SxLv if regexm(Pri_Aplldo,"DE LOS RIOS")==1 // Note que muchos de estos son appelidos porque el estudiante escribio
	
	
	