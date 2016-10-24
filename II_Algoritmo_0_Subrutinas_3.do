


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
	
	
* III. CREANDO LOS DIRECTORIOS DE NOMBRES Y APELLIDOS
**************************************************************************************	
	
	
	// Desactivado porque solo se corre 1 vez para todos los archivos
	*run "${mydir_DoFiles}\II_Algoritmo_3_DirectorioUnico_SNIES_ICFES_OML_02_11.do" 

	// Habia dos formas de usar los direcorios:
	// 1. Creando un directorio a partir de los nombres de la cohorte usada.
	// El problema de esta estrategia es que supone que este directorio incluye los nombres de todos los estudiantes en
	// otras cohortes. Si bien es posible que una cohorte contenga la gran mayoria de los nombres existentes en el pais,
	// un directorio como ese limita las posibilidades de encontrar nombres escritos de forma incorrecta.
	// Es decir, lo conveniente es crear un directorio comprehensivo que contenga no solo los nombres escritos 
	// correctamente, sino tambien aquellos con errores de escritura y agruparlos bajo el mismo codigo soundex + leveshtein.
	// Sin embargo, usar una sola cohorte para construir en diccionario limita el conjunto de los posibles errores de escritura
	// de un nombre dado. 
	// 2. Por tanto, la estrategia empleda fue crear un super diccionario de nombres corrrectos e incorrectos a partir de 
	// los datos de todas las cohortes usadas en el estudio para el SNIES, es decir, de 2007-1 a 2011-2. 
	// Adicionalmente, dado que hay apellidos que son nombres y apellidos se opto por tener una sola variable NombApll
	// y asignarle un codigo Soundex+Leveshtein sin tener en cuenta si es nombre o apellido
	
	
	// Despues de crear el archivo "${mydir_DctrData}\Dir_NombApll_SN_ICFES_02_11.dta" se debe volver a correr II_Algortimo_0_Maestro.do 
	// y mas especificamente las secciones IV a VII de II_Algortimo_0_Subrutinas.do
	// Sin embargo, lo mas facil es correr 	"${mydir_DoFiles}\II_Algoritmo_0_Maestro.do" de la seccion II
	// de Archivo_Super_Maestro. 
	
	
	
	
	
* IV. SEPARANDO APELLIDOS ENTRE PRIMER Y SEGUNDO APELLIDO CUANDO HAY MULTIPLES APELLIDOS
**************************************************************************************
	// Deja los DE, DEL, DE LOS, DE LA de los apellidos
	
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	do "${mydir_DoFiles}\II_Algoritmo_4_SeparadorDeApellidos.do" 
	do "${mydir_DoFiles}\II_Algoritmo_4B_SeparadorDeApellidos.do" 
	
	*format %50s v7 v8 v9 v10 *_Nombre *_Aplldo
	*save "${mydir_Data}\matriculados_2007_01_prov.dta", replace
	
	
* V. USANDO DIRECTORIO PARA ASIGNAR CODIGO SOUNDEX + LEVESHTEIN
**************************************************************************************
	
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	*run "${mydir_DoFiles}\II_Algoritmo_5_SDX_LVT.do" // Usa diccionario de nombres y diccionario de apellidos por separado
											   // y SI tiene en cuenta el orden del nombre completo
	* do "${mydir_DoFiles}\II_Algoritmo_5_SDX_LVT_2.do" // Usa super-diccionario y NO tiene en cuenta el orden del nombre completo
	do "${mydir_DoFiles}\II_Algoritmo_5_SDX_LVT_3.do" // Diccionario Unico SNIES+ICFES periodo 2002-2011
	*save "${mydir_Data}\matriculados_2007_01_prov.dta", replace

	
	
* VI. EDITANDO FECHAS DE NACIMIENTO INUSUALMENTE FREQUENTES (LAS UNIVERSIDADES RELLENARON EL VALOR POR SU CUENTA)
******************************************************************************************************************
	// En esta seccion tambien se hace lo siguiente:
	// 1. Usar tarjeta de identidad para imputar fecha de registros faltantes o con fechas erradas
	// 2. Se crean las variables age_`YR', FN_ano, FN_mes, FN_dia, FN_valid
	// donde age_`YR' es la edad en el respectivo archivo
	// Tambien se crea v13_c que es la fecha de nacimiento cirregida
	
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	do "${mydir_DoFiles}\II_Algoritmo_6_FechaNacimiento.do" //  		
	*save "${mydir_Data}\matriculados_2007_01_prov.dta", replace			
	 
	
			
* VII. HALLANDO DULICADOS, HOMONIMOS Y DOBLE PROGRAMA
******************************************************************************************************************			
			
	*use "${mydir_Data}\matriculados_2007_01_prov.dta", clear
	do "${mydir_DoFiles}\II_Algoritmo_7_0_Duplicados.do"
	
	* ESTA PARTE USA II_Algoritmo_7_1_DoblePrograma.do
	* Y utiliza ${mydir_Data}\Genero_Nombre.dta para corregir genero a partir de primer nombre 
	
	order CITA_SNEE		
			
			
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
