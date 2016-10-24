
	// Esta seccion mira registros duplicados. Esto es importante porque hay diversas razones por las cuales un 
	// estudiante puede aparecer varias veces. Hay dos en particular que son relevantes:
	// 1. Porque el estudiante esta haciendo doble programa
	// 2. Porque aparece en un registro con Tarjeta de identidad y en otro con Cedula.
	
	// Para hallar los registros duplicados deberia trabajarse con las variables de nombres, apellidos, IES, 
	// programa, documento de identidad, y fecha de nacimiento.
	
	// Note, sin embargo, los problemas de buscar duplicados por estas variables.
	// 1. Un estudiante puede estar repetido pero tener pequenas diferencias por nombre que hace que no se vea como repetido
	// 2. Muchos registros no tienen fecha de nacimiento o tenian una fecha sospechosa (Ver do-file SNIES_5_FechaNacimiento)
	// 3. Algunos numeros y tipos de documento de identidad estan errados. Por ejemplo, los numeros pueden tener menos 
	// o mas digitos de los que deben, o no ser compatibles con la estructura dada para cada tipo (cedula o tarjeta de identidad)
	// En particular, las cedulas expedidas
	// antes del 1 de octubre de 2003 tenian 8 digitos o menos. La mayoria tenia 8 digitos ya que las de menos son
	// de personas con una probabilidad muy baja de estar en un ainstitucion de educacion superior.
	// Las cedulas posteriores al 01/10/2003 tienen 10 digitos y comienzan con 1. 
	// Las tarjetas de identidad usualmente tienen 11 digitos, donde los 6 primeros digitos corresponden a la fecha 
	// de nacimeinto del estudiante.  
	
	// En este do file, por tanto, se hacen las siguientes modificaciones:
	// 1. Se corrige el tipo de docuemnto (CC, TI) cuanda esta claramente errado
	// 2. Se reemplaza la fecha de nacimiento para aquellos sin fecha pero con tarjeta de identidad
	// 3. Se borran los duplicados por 
	
	
	
	***********************
	// I. PRELIMINARES
	***********************
	
	
	// I.A. Corrigiendo tipo de documento cuando es CC 
	**********************************************************************************************
	
		// Aquellos con 18 anos el 1 de octube de 2003 tienen cedula de 10 digitos (i.e. Nacidos despues del 01/10/85)
	cap tab v6 if v6!="CC" & length(v5)==10 
	cou if v6!="CC" & length(v5)==10  
	*ed v5 v6 v17 FN_ano v13 v13_c if v6!="CC" & length(v5)==10  
	
	cou if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10))
	sort FN_ano FN_mes
	*ed v5 v6 v17 FN_ano FN_mes v13 v13_c if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10))
	
	cou if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10)) & substr(v5,1,1)=="1"
	*ed v5 v6 v17 FN_ano FN_mes v13 v13_c if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10)) & substr(v5,1,1)=="1"
	*ed v5 v6 v17 FN_ano FN_mes v13 v13_c if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10)) & substr(v5,1,1)!="1"	
	
	replace v6="CC" if v6!="CC" & length(v5)==10 & (FN_ano>=1986 | (FN_ano==1985 & FN_mes>=10)) & substr(v5,1,1)=="1"
	
		// Se crea para ver los posibles errores del numero de documento
	cap drop lv5 
	gen lv5 = length(v5)
	cap tab lv5 v6
	
		// Algunos dicen que el tipo de documento es TI, pero este no concuerda con el patron de las TI 
	*ed v5 v6 v17 FN_ano FN_mes v13 v13_c if v6=="CC" & lv5==11
	*ed v5 v6 v17 FN_ano FN_mes v13 v13_c if v6=="TI" & ((lv5==10 & substr(v5,1,1)=="1")  | lv5==8)
	*replace v6 = "CC" if v6=="TI" & lv5==8
		
		
	
	// I.B. Estas son las variables con las que se definen los duplicados.  Cuantos hay sin info?
	*****************************************************************************************
		cou if Pri_Nombre=="" 
		cou if Seg_Nombre=="" 
		cou if Pri_Aplldo=="" 
		cou if Seg_Aplldo=="" 
		cou if v3==.
		cou if v104==""
		cou if Pri_Nombre=="" & Pri_Aplldo==""
		cou if Pri_Nombre!="" & Pri_Aplldo==""
	
		// Muchos registros no tienen segundo nombre o segundo apellido. 
		// A veces se requiere crear grupos por nombre y el comando no funciona sobre campos vacios
		// Por tanto, se reemplaza por "VACIO" estos campos a fin de crear los grupos
	
		replace SN_SxLv = -99 if Seg_Nombre==""
		cap drop Seg_NombreP 
		gen Seg_NombreP = Seg_Nombre 
		replace Seg_NombreP = "VACIO" if Seg_NombreP=="" 
		 
		replace SA_SxLv = -99 if Seg_Aplldo==""
		cap drop Seg_AplldoP 
		gen Seg_AplldoP = Seg_Aplldo 
		replace Seg_AplldoP = "VACIO" if Seg_AplldoP==""  	
	
	
	
		
	// I.C. Imputando Variable de GENERO para buscar duplicados
	************************************************************
		
	// Al usar el primer nombre para imputar el genero, se pueden haber colado apellidos que estaban en primer nombre
	// Por tanto se usa el diccionario de Apellidos de 2007, y se consideram los primeros 1500 apellidos (95% del total de estudiantes) 
		
		
	// Los dos siguientes procedimientos estan desactivados en caso de que el master file se corra para otro 
	// Ano distinto y ahorrar tiempo
	
	// I.C.1. Diccionario de Apellidos Mas comunes
	*************************************************************
	/*
	preserve 
		use "${mydir_Data}\Dir_Aplldo_SNIES_07.dta", clear
			
				gsort -dup_PA
				cap drop dup_01 // Creando la variable acumulada de dup
				gen dup_01 = sum(dup_PA) // Sensible al sorting usado
				
				sum dup_PA // Captura la suma total
				local a = r(mean)*r(N)
				
				cap drop p_dup_PA // Creando la variable del %acumulado hasta ese APELLIDO
				gen  p_dup_PA = dup_01/`a'
				drop dup_01
				
				sort p_dup_PA
				order  Pri_Aplldo dup_PA p_dup_PA
				
				keep if p_dup_PA<=0.950000
				sum dup_PA 
				dis r(mean)*r(N)
		save "${mydir_Data}\Dir_Aplldo_SNIES_07_95pc.dta", replace
	restore
			
			
	// I.C.2. Construyendo archivo que relaciona primer nombre con genero: 
	***********************************************************************		
	* Si un nombre tiene mas del 90% de un mismo genero, se le asigna ese genero a ese nombre
	* Note que que al final de esta subrutina se cruza ek archivo colapsado de nombres con el archivo de los apellidos
	* mas comunes (Seccion IIA2) con el fin de excluir los apellidos del archivo que relaciona nombres con genero. 
	
	preserve
		use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
				cap drop dup_NG // SE crea para el collapse
				gen dup_NG = 1
				
			collapse (sum) dup_NG (mean) Masculino if v12!="", by(Pri_Nombre)
			cou if Masculino>0 & Masculino<1
						
				cou if Masculino>0.25 & Masculino<0.75
				sum dup_NG if Masculino>0.25 & Masculino<0.75, d
				
				cou if Masculino>0.1 & Masculino<0.9
				sum dup_NG if Masculino>0.1 & Masculino<0.9, d
				*ed if ~(Masculino>0.1 & Masculino<0.9) & dup_NG!=1
				
				drop if (Masculino>0.1 & Masculino<0.9) | dup_NG==1			
				replace Masculino = 1 if Masculino>=0.9 & Masculino!=. // Masculino si mas del 90% con ese nombre es masculino
				replace Masculino = 0 if Masculino<=0.1 & Masculino!=. // Femenino si mas del 90% con ese nombre es femenino
				
				tab Masculino
				tab Masculino, miss
	
				tab Masculino, sum(dup_NG)
				
				// Merging este collapse con el directorio de apellidos para identificar apellidos identificados como primeros nombres
				*ed // Note que algunos apellidos pudieron ser reemplazados
				rename Pri_Nombre  Pri_Aplldo
				merge m:1 Pri_Aplldo using "${mydir_Data}\Dir_Aplldo_SNIES_07_95pc.dta", keep(1 3) keepusing(dup_PA) gen(_mergeGenAp)
				tab _mergeGenAp
				
				*ed if _mergeGenAp==3
				*ed if _mergeGenAp==3 & dup_NG>=8 // Estos son Nombres que tembien son apellidos y por tanto se usan en la identificacion de genero
				drop if _mergeGenAp==3 & dup_NG<8
				
				rename Pri_Aplldo Pri_Nombre  
				
		save "${mydir_Data}\Genero_Nombre.dta"
	restore
	*/				
					
	// I.C.3 Imputando genero a partir del genero comunmente asociado al primer nombre: 
	*************************************************************************************
		cap tab v12, miss // Esta es la variable de genero 

		cap drop Masculino
		gen Masculino = 1 if v12=="MASCULINO"
		replace Masculino = 0 if v12=="FEMENINO"
		cap tab Masculino, miss

		rename Masculino Masculino_P
		cap drop _mergeGenero
		*merge m:1 Pri_Nombre using "${mydir_Data_SNS}\Genero_Nombre.dta", keep(1 3) keepusing(Masculino) gen(_mergeGenero)
		merge m:1 Pri_Nombre using "${mydir_DoFiles}\Genero_Nombre.dta", keep(1 3) keepusing(Masculino) gen(_mergeGenero)
		
		cap tab _mergeGenero
		cap tab Masculino_P Masculino // Los registros por fuera de la diagonal son inconsistentes
		
	
	// I.C.3.1 Inconsistencias e imputaciones de la variable v12 Genero
	******8***********************************************************
		// Cuales estudiantes fueron reportados como mujeres (hombres) a pesar de tener un nombre tipicamente masculino (femenino)
	*ed v7 v8 v9 v10 v12  Pri_Nombre  Masculino_P  Masculino  _mergeGenero if Masculino_P==0 &  Masculino ==1
	replace Masculino_P = Masculino if Masculino_P==0 &  Masculino ==1
	
	
	// Cuales estudiantes fueron reportados como hombres (mujeres ) a pesar de tener un nombre tipicamente femenino (masculino)
	*ed v7 v8 v9 v10 v12  Pri_Nombre  Masculino_P  Masculino  _mergeGenero if Masculino_P==1 &  Masculino ==0
	replace Masculino_P = Masculino if Masculino_P==1 &  Masculino ==0
	
	
	// Registros a los que se les imputa el genero cuando no fue reporatdo
	*ed v7 v9 Masculino_P  Masculino  _mergeGenero if Masculino_P==. &  Masculino !=.
	replace Masculino_P = Masculino if Masculino_P==. &  Masculino !=.
	
	cap tab Masculino_P, miss
	*ed v7 v9 PN_SxLv PN_SxLv2 Masculino_P  Masculino  _mergeGenero if Masculino_P==. 
	*ed v7 v9 PN_SxLv PN_SxLv2 Masculino_P  Masculino  _mergeGenero if  PN_SxLv2 ==575
	
	drop Masculino
	rename Masculino_P Masculino
	
	
	
	
	// I.D. Generando id_SLIP por Soundex+Leveshtein+Masculino+IES+Programa para imputar fechas de duplicados 		
	*********************************************************************************************
		* Se usa la info de IES Programa para reducir la posibilidad de tener homonimos 
		cap drop id_SLIP
		egen id_SLIP = group(PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino v3 v104) if Seg_AplldoP!="VACIO"
		cou if id_SLIP==.
		cou if id_SLIP!=. & Pri_Nombre==""		

		cap drop dup_id1 // Calculando los duplicados de id 
		cap duplicates tag id_SLIP if id_SLIP!=., gen(dup_id1)
		capture confirm variable dup_id1 // Se hace en caso de que no haya duplicados
		if !_rc {
                 dis "MABG"
               }
               else {
				 gen dup_id1=0 if id_SLIP!=.				 
				}		
		cap tab dup_id1 
		
					
		// Imputando fecha de nacimiento a duplicados usando id_SLIP
		****************************************************************************
		// Algunos duplicados tienen fecha de nacimiento pero otros no. Adicionar la fecha antes de borrar los duplicados
		// para no eliminar info potencialmente util
			
			// Salvando las fechas de nacimiento: 
			cap drop v13_c2
			egen v13_c2 = mode(v13_c) if dup_id1>=1 & id_SLIP!=., by(id_SLIP) 
			
				// El problema es que a veces hay duplicados que tienen fecha de nacimiento distinta 
				// y cuando eso ocurre v13_c2 == "" Se podria usar la opcion minmode para tener al menos una de las fechas
				cap drop v13_c3
				egen v13_c3 = mode(v13_c) if dup_id1>=1 & id_SLIP!=., by(id_SLIP) maxmode
				
					// Duplicados con fecha de nacimiento distinta
				sort id_SLIP	
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLIP dup_id1 if dup_id1>=1 & id_SLIP!=. & v13_c2!=v13_c3
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLIP dup_id1 if dup_id1>=1 & id_SLIP!=. & v13_c2!=v13_c3 & SA_SxLv!=-99
				
					// Reemplzando estas fechas
				replace v13_c2 = v13_c3 if dup_id1>=1 & id_SLIP!=. & v13_c2!=v13_c3 & SA_SxLv!=-99
				
			replace v13_c = v13_c2 if dup_id1>=1 & id_SLIP!=. & v13_c=="" & v13_c2!="" & SA_SxLv!=-99
			
			
				 // Y estos son los registros duplicados con fechas faltantes 
			*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLIP dup_id1 if dup_id1>=1 & id_SLIP!=. & v13_c==""
			drop id_SLIP v13_c2 v13_c3
	
			
	// I.E. Generando id_SLV5 por Soundex+Leveshtein+DocIdentidad para imputar fechas de duplicados 		
	*********************************************************************************************
		
		cou if regexm(v5,"^0")==1 // quitar ceros a la izquierda antes de usar el numero de documento
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		replace v5 = regexr(v5,"^0","")
		
		
		cap drop id_SLV5
		egen id_SLV5 = group(PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino v5) if Seg_AplldoP!="VACIO"
		
		cou if id_SLV5==.
		cou if id_SLV5!=. & Pri_Nombre==""		

		cap drop dup_id1 // Calculando los duplicados de id 
		cap duplicates tag id_SLV5 if id_SLV5!=., gen(dup_id1)
		confirm variable dup_id1 // Se hace en caso de que no haya duplicados
		if !_rc {
                 dis "MABG"
               }
               else {
				 gen dup_id1=0 if id_SLV5!=.				 
				}		
		cap tab dup_id1 
		
							
		// Imputando fecha de nacimiento a duplicados usando id_SLV5
		****************************************************************************
		// Algunos duplicados tienen fecha de nacimiento pero otros no. Adicionar la fecha antes de borrar los duplicados
		// para no eliminar info potencialmente util
			
				
			// Salvando las fechas de nacimiento: 
			cap drop v13_c2
			egen v13_c2 = mode(v13_c) if dup_id1>=1 & id_SLV5!=., by(id_SLV5) 
			
				// El problema es que a veces hay duplicados que tienen fecha de nacimiento distinta 
				// y cuando eso ocurre v13_c2 == "" Se podria usar la opcion minmode para tener al menos una de las fechas
				cap drop v13_c3
				egen v13_c3 = mode(v13_c) if dup_id1>=1 & id_SLV5!=., by(id_SLV5) maxmode
				
					// Duplicados con fecha de nacimiento distinta
				sort id_SLV5
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLV5 dup_id1 if dup_id1>=1 & id_SLV5!=. & v13_c2!=v13_c3
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLV5 dup_id1 if dup_id1>=1 & id_SLV5!=. & v13_c2!=v13_c3 & SA_SxLv!=-99
				
					// Reemplzando estas fechas
				replace v13_c2 = v13_c3 if dup_id1>=1 & id_SLV5!=. & v13_c2!=v13_c3 & SA_SxLv!=-99
				
			
				 // Y estos son los registros duplicados con fechas faltantes 
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLV5 dup_id1 if dup_id1>=1 & id_SLV5!=. & v13_c==""
						
			replace v13_c = v13_c2 if dup_id1>=1 & id_SLV5!=. & v13_c=="" & v13_c2!="" & SA_SxLv!=-99
			
			*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_SLV5 dup_id1 if dup_id1>=1 & id_SLV5!=.
		
			drop id_SLV5 v13_c2 v13_c3
	
	
	
	
	
		
	*********************************************************************		
	// II. DUPLICADOS	
	*********************************************************************	
	
	// A. Hallando los duplicados obvios
	
		// Duplicados por Soundex + Leveshtein + Masculino + DocumentoId + IES + Programa
	cap drop Dup_SxLvV5IP // Hallando los duplicados obvios ()
	egen Dup_SxLvV5IP = rank(v1), by(PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino v5 v3 v104) unique
	cap tab Dup_SxLvV5IP
	
	sort PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino v5 v3 v104
	*ed v3 v5 v7 v8 v9 v10 v13 v13_c v104 Dup_SxLvV5IP if Dup_SxLvV5IP!=1 // Estos son los duplicados en todo
	
	cap drop Data_Valid
	gen Data_Valid = (Dup_SxLvV5IP==1)
	cap tab Data_Valid 
	
	*replace Data_Valid =0 if PN_SxLv==. | SN_SxLv==. | PA_SxLv==. | SA_SxLv==. | Masculino==. | v5=="" | v3==. | v104==""
	cap tab Data_Valid, miss
	
	
	
	
	// Para caracterizar los duplicados se usan tres grupos de variables principales: 
	// 1. Nombre completo; 2. Numero documento identidad; y 3. IES y programa
	// Cada una de estas pueden tener problemas y por tanto se usan variables secundarias para validar los resultados,
	// en particular, la fecha de nacimiento;  
	// La fecha de nacimiento no se usa como variable principal ya que hay muchos registros sin fecha
		
	
	// La estrategia de identificar registros duplicados  se divide en 2:
	// I. La primera parte analiza los estudiantes que aparecen repetidos con el mismo nombre (i.e. PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino)
	// A. Los repetidos por nombre se dividen entre aquellos que tienen el mismo numero de documento de identidad
	// A1. Si tienen el mismo documento se entiende que es el mismo estudiante y se establece si el registro esta repetido
	// o si el estudiante esta haciendo doble programa. En caso de hacer doble programa, se registra esta informacion y se crean
	// las variables con los codigos de la universidad y el programa. Note que estos estudiantes aparecen dos veces en la base. Para identificarlos
	// use las variable NroTotProg
	// A2. Si no tienen el mismo numero de documento, se emplean las variables de nombre, institucion, programay fecha de nacimiento
	// para establecer cuales estudiantes aparecen en la base varias veces pero con un numero de documento diferente (i.e., tarjeta de identidad versus CC)
	// Para aquellos identificados como la misma persona, se crea una variable adicional para salvar el segundo numero de documento.
	// Note que estos estudiantes aparecen repetidos en la base y pueden ser identidicados a partir de la variable Mult_Doc 
	// B. Por otra parte estan los registros que pese a tener nombre repetido tienen numero de documento diferente
	
	
	
	
	
			
		// A. Repetidos por "Nombre" (i.e PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino)
		*****************************************************************************
		
		cap drop id_SLM
		egen id_SLM = group(PN_SxLv SN_SxLv PA_SxLv SA_SxLv Masculino) if Data_Valid==1
		codebook id_SLM
		
			
		// A.1. Repetidos por Nombre + NroDocumento
		***************************************************************
		
		cap drop id_SLM_v5 
		egen id_SLM_v5 = rank(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v5!="" & Data_Valid==1, ///
			 by(id_SLM v5)		
		cap tab id_SLM_v5 
		
		cap drop Tid_SLM // Total de registros al interior de id_SLM
		egen Tid_SLM = count(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v5!="" & Data_Valid==1, by(id_SLM)
		
		cap tab id_SLM_v5 Tid_SLM, miss
			* [Tid_SLM=1]: Registros sin duplicados. Tienen 1 nombre y un documento
			* [Tid_SLM=2, id_SLM_v5=1]:   2 registros con mismo Nombre, pero cada uno con id diferente
			* [Tid_SLM=2, id_SLM_v5=1.5]: 2 registros con mismo Nombre e igual id
			* [Tid_SLM=3, id_SLM_v5=1]:   3 registros con mismo Nombre. 1 tiene id diferente al resto
			* [Tid_SLM=3, id_SLM_v5=1.5]: 3 registros con mismo Nombre. 2 tienen id iguales
			* [Tid_SLM=3, id_SLM_v5=2]:   3 registros con mismo Nombre. 3 tienen id iguales
			* [Tid_SLM=4, id_SLM_v5=1]:   4 registros con mismo Nombre. 1 tienen id diferente al resto
			* [Tid_SLM=4, id_SLM_v5=1.5]: 4 registros con mismo Nombre. 2 tienen id iguales
			* [Tid_SLM=4, id_SLM_v5=2.5]: 4 registros con mismo Nombre. 4 tienen id iguales
		
		* Note que id_SLM_v5==1 define uno de los nodos del arbol de decision y id_SLM_v5!=1 el otro nodo
		* Es decir, aquellos sin id repetido y aquellos con id repetido, respecyivamente. 
		
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM ///
			id_SLM_v5 Tid_SLM  if Tid_SLM==2 & id_SLM_v5==1.5
		
		
		// A.1.1. Repetidos por Nombre + NroDocumento + (IES + Programa) [id_SLM_v5!=1: Numero de documento repetido]
		***************************************************************************************************************
		cap drop id_SLM_v5_IP 
		egen id_SLM_v5_IP = rank(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v5!="" & v3!=. & v104!="" & Data_Valid==1, ///
			  by(id_SLM v5 v3 v104)		
		cap tab id_SLM_v5_IP 
	
		
		cap drop Tid_SLM_v5 // Total de registros al interior de id_SLM*v5
		egen Tid_SLM_v5 = count(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v5!="" & v3!=. & v104!="" & Data_Valid==1, ///
			   by(id_SLM v5)
		
		cap tab id_SLM_v5 Tid_SLM, miss
		cap tab id_SLM_v5_IP Tid_SLM_v5, miss
		cap tab id_SLM_v5_IP Tid_SLM_v5 if id_SLM_v5!=1, miss // Resto de Filas de tab id_SLM_v5_IP Tid_SLM_v5, miss
		
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			id_SLM_v5 Tid_SLM  id_SLM_v5_IP if id_SLM_v5!=1 & id_SLM_v5_IP==1 // id_SLM_v5_IP==1 es para no incluir missing
			
			// Multiples programas			
			cap drop NroTotProg // Numero Total de Programas
			gen NroTotProg = 2 if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==2
			replace NroTotProg = 3 if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5>=3 & Tid_SLM_v5!=.
			replace NroTotProg = 1 if id_SLM_v5==1 
			cap tab NroTotProg

			
			// Estos tienen Doble Programa				
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			id_SLM_v5 Tid_SLM  id_SLM_v5_IP if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==2 
		
			
			// Estos tinene Triple programa
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM ///
			id_SLM_v5 Tid_SLM  id_SLM_v5_IP if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3 		
		cap tab v104 v3 if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3 		
		
		
			// Creando las variables v3_1 v3_2 v3_3 v104_1 v104_2 v104_3 que identifican los diferentes programas en los que esta un estudiante
					run "${mydir_DoFiles}\II_Algoritmo_7_1_DoblePrograma.do"
			
	
		// B. No Repetidos por Nombre + NroDocumento [id_SLM_v5==1: Numero de documento aparece 1 vez]
		************************************************************************************************
		cap tab id_SLM_v5_IP Tid_SLM_v5 if id_SLM_v5==1, miss // Primera Fila de tab id_SLM_v5_IP Tid_SLM_v5, miss
		
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			id_SLM_v5 Tid_SLM  id_SLM_v5_IP if id_SLM_v5==1 
	
		cap drop id_SLM_IP 
		egen id_SLM_IP = rank(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v3!=. & v104!="" & Data_Valid==1, ///
			 by(id_SLM v3 v104)	
		cap tab id_SLM_IP 
		cap tab id_SLM_IP NroTotProg // Note que incluye algunos con doble programa	y doble documento 
		
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			id_SLM_v5 Tid_SLM  id_SLM_v5_IP if id_SLM==19586
	
		
		* Note que el grupo a analizar esta dado por id_SLM_IP==1.5
		* Para diferenciar homonimos de doble documento se usa la fecha de nacimiento
		sort id_SLM v3 v104
		*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			if id_SLM_IP==1.5
		
			
			// Cuantos de estos tienen ademas la misma fecha de nacimiento
			cap drop id_SLM_IP_FN 
				egen id_SLM_IP_FN = rank(v1) if Seg_AplldoP!="VACIO" & id_SLM !=. & v3!=. & v104!="" & v13_c!="" & Data_Valid==1, ///
					 by(id_SLM v3 v104 v13_c)	
			cap tab id_SLM_IP_FN 
			cap tab id_SLM_IP_FN NroTotProg
			
			cap tab id_SLM_IP id_SLM_IP_FN	// Note que la mayoria tiene la misma fecha de Nacimiento
										// Los otros son tambien la misma persona pero con fechas de nacimiento erradas
			
			*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			if id_SLM_IP==1.5 & id_SLM_IP_FN==1.5
			
			*ed v5 v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			if id_SLM_IP==1.5 & id_SLM_IP_FN==1
		
			
			// Guardando el segundo Numero de Identificacion
			
				cap drop v5_Min
					egen v5_Min = mode(v5) if v5!="" & id_SLM_IP==1.5, by(id_SLM v3 v104) minmode 
				cap drop v5_Max
					egen v5_Max = mode(v5) if v5!="" & id_SLM_IP==1.5, by(id_SLM v3 v104) maxmode
				cap drop v5_2
					gen  v5_2 = v5_Max if v5_Max!="" & v5==v5_Min &  v5_Min!="" 
					replace  v5_2 = v5_Min if v5_Min!="" & v5==v5_Max &  v5_Max!="" 
				drop v5_Min v5_Max
				
			order  EVAL_PERIODO v5 v5_* 	
			*ed v5* v6 v3 v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM  ///
			if id_SLM_IP==1.5 	
		
		cap drop Mult_Doc
		gen Mult_Doc = 1 if v5_2!=""
		cap tab Mult_Doc 
		
		
			
		// C. Cuales tienen el mismo numero de documento pero nombre distinto
		************************************************************************************************
		
		cap drop id_v5 
			egen id_v5 = rank(v1) if v5!="" & Data_Valid==1, by(v5)
		cap tab id_v5
		cap tab id_v5 NroTotProg 
			// Note que aquellos con documento repetido (id_v5>1) pero 1 solo programa (NroTotProg) son aquellos que:
			// 1. Son la misma persona pero no cruzaron antes por tener algo diferente en el nombre. En esta parte lo unico que
			// se impone es que, además de tener el mismo documento, tengan el mismo primer nombre y apellido
			// 2. Estudiantes repetidos con alguno de los registros repetidos sin PN_SxLV o PA_SxLV por problemas en la escritura del nombre
			// 3. Dos estudiantes diferentes con igual numero de ID (Error de digitción?). 		
		sort v5
		*ed v3 v104 v5 v7 v8 v9 v10 v13_c id_SLM NroTotProg Mult_Doc id_v5 ///
			if NroTotProg==1 & id_v5>1 & id_v5!=.
		*ed v3 v104 v5 v7 v8 v9 v10 v13_c id_SLM NroTotProg Mult_Doc id_v5 ///
			if v5=="1003863890" | v5=="1030534657"


		
			// C.1 Coincide documento v5 con PN_SxLv y PA_SxLv
			********************************************************
			cap drop rid_v5_PNPA 
			egen rid_v5_PNPA = rank(v1) if v5!="" & PA_SxLv!=. & PA_SxLv!=. & Data_Valid==1 & NroTotProg==1 & id_v5>1 & id_v5!=., ///
				by(v5 PN_SxLv PA_SxLv)
			cap tab rid_v5_PNPA
			*ed v3* v104* v5 v7 v8 v9 v10 v13_c id_SLM NroTotProg rid_v5_PNPA if NroTotProg==1 & id_v5>1 & id_v5!=. & rid_v5_PNPA==1.5
			*ed v3* v104* v5 v7 v8 v9 v10 v13_c id_SLM  NroTotProg rid_v5_PNPA if NroTotProg==1 & id_v5>1 & id_v5!=. & rid_v5_PNPA==1
			
			
			// C.1.1. Generando id_v5_PNPA por v5 PN_SxLv PA_SxLv Maculino para imputar fechas de duplicados 		
			
				cap drop id_v5_PNPA 
				egen id_v5_PNPA = group(v5 PN_SxLv PA_SxLv Masculino) if v5!="" & PA_SxLv!=. & PA_SxLv!=. & Data_Valid==1 & NroTotProg==1 & id_v5>1 & id_v5!=.
				cap tab id_v5_PNPA
				
				cap drop dup_id1 // Calculando los duplicados de id 
				cap duplicates tag id_v5_PNPA if id_v5_PNPA!=., gen(dup_id1)
				capture confirm variable dup_id1 // Se hace en caso de que no haya duplicados
					if !_rc {
							dis "MABG"
							}
							else {
								gen dup_id1=0 if id_v5_PNPA!=.				 
							}				
				cap tab dup_id1 
		
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c id_v5_PNPA dup_id1 if dup_id1==1
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c id_v5_PNPA dup_id1 if dup_id1==0
				*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c id_v5_PNPA dup_id1 if dup_id1!=.
				
					
				// Imputando fecha de nacimiento a duplicados usando id_v5_PNPA
					// Salvando las fechas de nacimiento: 
					cap drop v13_c2
					egen v13_c2 = mode(v13_c) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA) 
					
						// El problema es que a veces hay duplicados que tienen fecha de nacimiento distinta 
						// y cuando eso ocurre v13_c2 == "" Se podria usar la opcion minmode para tener al menos una de las fechas
						cap drop v13_c3
						egen v13_c3 = mode(v13_c) if dup_id1>=1 & id_v5_PNPA !=., by(id_v5_PNPA) maxmode
						
							// Duplicados con fecha de nacimiento distinta
						sort id_v5_PNPA 	
						*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. 
						*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. & v13_c2!=v13_c3
						
						
							// Reemplzando estas fechas
						replace v13_c2 = v13_c3 if dup_id1>=1 & id_v5_PNPA !=. & v13_c2!=v13_c3 
						replace v13_c = v13_c2 if dup_id1>=1 & id_v5_PNPA!=. & v13_c=="" & v13_c2!="" 
						
						*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. 
						
					// Y estos son los registros duplicados con fechas faltantes 
					*ed v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c v13_c2 v13_c3 id_v5_PNPA  dup_id1 if dup_id1>=1 & id_v5_PNPA !=. & v13_c==""
					
					drop v13_c2 v13_c3
					
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_Aplldo v13_c id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. 
	
			
				//  C.1.2. Doble Programa 
				
					// IES
					cap drop v3_c2					
					egen v3_c2 = min(v3) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA) 
					cap drop v3_c3
					egen v3_c3 = max(v3) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA)
					
					order  EVAL_PERIODO v3_3 v3_c2 v3_c3
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. 
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. ///
					& v3_c2== v3_c3 &  v3_c2!=.
					
					replace v3_2 = string(v3_c3) if v3==v3_c2
					replace v3_2 = string(v3_c2) if v3==v3_c3
					
					// Programa
					cap drop v104_c2
					egen v104_c2 = mode(v104) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA) minmode
					cap drop v104_c3
					egen v104_c3 = mode(v104) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA) maxmode
					
					order  EVAL_PERIODO v104_3 v104_c2 v104_c3
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. 
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. ///
					& v3_c2== v3_c3 &  v3_c2!=.
					
					replace v104_2 = v104_c3 if v3==v3_c2
					replace v104_2 = v104_c2 if v3==v3_c3
			
					drop v3_c2 v3_c3 v104_c2 v104_c3
			
					
					// Actualizando Data_Valid = 0 para nuevos duplicados DUPLICADOS
					cap drop Dup_id_v5_PNPA_IP // Hallando los duplicados obvios ()
						egen Dup_id_v5_PNPA_IP = rank(v1) if dup_id1>=1 & dup_id1!=., by(id_v5_PNPA v3 v104) unique
					cap tab Dup_id_v5_PNPA_IP
					*ed v3 v5 v7 v8 v9 v10 v13 v13_c v104 Dup_SxLvV5IP if Dup_id_v5_PNPA_IP!=1 & Dup_id_v5_PNPA_IP!=. // Estos son los duplicados en todo

					replace Data_Valid = 0 if Dup_id_v5_PNPA_IP!=1 & Dup_id_v5_PNPA_IP!=. 
					
					
					// Actualizando Numero Total de programas (NroTotPrograma)
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. ///
						& Data_Valid==1
					
					cap drop Tid_v5_PNPA
					egen Tid_v5_PNPA = count(v1) if dup_id1>=1 & id_v5_PNPA !=. & Data_Valid==1, ///
						 by(id_v5_PNPA)
					cap tab Tid_v5_PNPA
				
					*ed v3 v3_* v104* v5 v6 v7 v8 v9 v10 Pri_* Seg_* v13_c *_SxLv id_v5_PNPA dup_id1 if dup_id1>=1 & id_v5_PNPA !=. ///
						& Data_Valid==1 & Tid_v5_PNPA==1
	
					replace NroTotProg = 2 if dup_id1>=1 & id_v5_PNPA !=. & Data_Valid==1 & Tid_v5_PNPA==2
					cap tab NroTotProg
	
	
	
/*		
********************************************************************************************************************************
* En esat aparte Queria ver si es posible descubrir a aquellos que pese a tener documento distinto tienen un nombre que es parcialmente igual
* La idea era usar la fecha de nacimiento o la universidad a la que van para encontrarlos
* Resultan ser muy pocos no se hace nada
********************************************************************************************************************************


		cap drop Tv5 // Total de registros al interior de id_SLM
		egen Tv5 = count(v1) if v5!="" & Data_Valid==1, by(v5)
		tab Tv5 
		



// A. Repetidos por "Nombre" Parcial (i.e PN_SxLv PA_SxLv Masculino) y fecha Nacimiento
		*****************************************************************************
		
		cap drop id_SLM2
		egen id_SLM2 = group(PN_SxLv PA_SxLv Masculino v3 v104) if Data_Valid==1
		*egen id_SLM2 = group(PN_SxLv PA_SxLv Masculino v13_c v3 v104) if Data_Valid==1 & v13_c!=""
				
		cap drop Tid_SLM2 // Total de registros al interior de id_SLM
		egen Tid_SLM2 = count(v1) if id_SLM2 !=. & Data_Valid==1, by(id_SLM2)
		
		
		cap drop rid_SLM2
		egen rid_SLM2 = rank(v1) if Data_Valid==1 & v13_c!="", by(PN_SxLv PA_SxLv Masculino v13_c) 
		tab rid_SLM2
		tab rid_SLM2 if Tv5==1 & v5_2=="" & Tid_SLM2>1 & Tid_SLM2!=.
		tab rid_SLM2 if Tv5==1 & rid_SLM2>1 & rid_SLM2!=. & v5_2=="" & Tid_SLM2>1 & Tid_SLM2!=.
	
		
		*ed v5 v5_* v6 v3 v3_* v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM2 ///
			Tid_SLM2  if Tv5==1 & rid_SLM2>1 & rid_SLM2!=.
			
		*ed v5 v5_* v6 v3 v3_* v104 v14 Pri_Nombre Seg_NombreP Pri_Aplldo Seg_AplldoP v13_c id_SLM2 ///
			Tid_SLM2  if Tv5==1 & rid_SLM2>1 & rid_SLM2!=. & v5_2=="" & Tid_SLM2>1 & Tid_SLM2!=.
				
		
		
		
		
		
		