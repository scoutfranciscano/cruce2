


* 0. PRELIMINAR: EDITANDO REGISTROS CON NOMBRE1=APELLIDO1
**********************************************************
	** OJO: REVISAR PRIMERO SI ESTO PASA EN LOS OTROS ARCHIVOS DE SNIES Y EN SABER

	format %50s v7 v8 v9 v10
	cou if v7==v9 // Primer Nombre = Primer Apellido
	*ed v7 v8 v9 v10 if v7==v9
	
	
	cou if v7==v9 & wordcount(v7)==1
	*ed v7 v8 v9 v10 if v7==v9 & wordcount(v7)==1 //Note que todos tienen el apellido como si fuera el primer nombre
	cap drop prov0
	gen prov0 = 1 if v7==v9 & wordcount(v7)==1
	replace v7 = "" if prov0==1
 	replace v7 = v8 if prov0==1 & v8!="" //Algunos si tienen nombre de pila en v8. SE usa como primer nombre
	replace v8 = "" if prov0==1 & v7==v8	
	*ed v7 v8 v9 v10 if prov0==1
	drop prov0
	
	cou if v7==v9 & wordcount(v7)>=2 //Ojo: NO tener a estos en cuenta cuando se editen los nombres
	*ed v7 v8 v9 v10 if v7==v9 & wordcount(v7)==3 //Note que todos tienen el apellido como si fuera el primer nombre

	


* I. IDENTIFICAR Y REEMPLAZAR CARACTERES EXTRANOS DE LOS NOMBRES Y DE LOS APPELLIDOS
**************************************************************************************
	
	timer clear
	local names Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo
	local Nms PN SN PA SA
	local nombres v7 v8 v9 v10
	local i = 1
	while `i' <=4{
			
		gettoken t1 names : names	
		gettoken t2 nombres : nombres	
		gettoken t3 Nms : Nms	
		
		dis "Identificando Caracteres Extranos para la variable `t1'"
		timer on `i'
		
		cap drop NameProv 
		gen NameProv = upper(`t2')
		run "${mydir_DoFiles}\II_Algoritmo_1_EditorDeNombresyApellidos.do" // Identifica registros con caracteres extranos
		**ed `t2' NameProv if CrtExt == 1
		timer off `i'	
		
		tab q_xyz // Muestr cuantos registros con caracteres extranos hay!
		cap drop `t1'
			rename NameProv `t1'
		cap drop CrtExt`t3'
			gen  CrtExt`t3' = CrtExt 
		cap drop q_xyz`t3'
			gen  q_xyz`t3' = q_xyz 
		
		local i = `i'+1
	}

	timer list
	drop CrtExt q_xyz
	
	
			
* II. SEPARANDO NOMBRES ENTRE PRIMER, SEGUNDO, TERCER Y CUARTO NOMBRE CUANDO HAY MULTIPLES NOMBRES
***************************************************************************************************
	// Quita los DE, DEL, DE LOS, DE LA de los nombres
	
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	do "${mydir_DoFiles}\II_Algoritmo_2_SeparadorDeNombres.do" 
	*save "${mydir_Data}\matriculados_2007_01_prov.dta", replace
	
	
		