


*********************************************************************************************************
// I. HALLANDO MULTIPLES CITAS_SNEE Y CREANDO ARCHIVO  SB11_Inscritos_2002_2011.dta
*********************************************************************************************************



	// 1A. HALLANDO LOS QUE TIENEN VARIOS SABER11 - GUARDANDO LA CITA - Creando 1 Registro por estudiante
	*****************************************************************************************************
	do "${mydir_DoFiles}\III_2_1_SB11_SBPRO_CitasDup_Sab11.do"



	
	// 1B. HALLANDO LOS QUE TIENEN VARIOS SABER-PRO - GUARDANDO LA CITA - Creando 1 Registro por estudiante
	*******************************************************************************************************
	do "${mydir_DoFiles}\III_2_2_SB11_SBPRO_CitasDup_SabPro.do"


	// Estos dos do-files generan un archivo general de Saber11 de 2002 a 2011
	*use "${mydir_Data_SB11}\SB11_Inscritos_2002_2011.dta", clear
	
	
	
	// 1C. CONSTRUYENDO (APPENDING) UN UNICO ARCHIVO SABER11 SABER PRO
	***********************************************************
	// NOTA: Intente pegarle la CC a la TI usando el doble documento del SNIES pero solo pegaron 34 mil.
	// Ello ocurre porque en las bases del SNIES tampoco hay muchos registros que tengan TI y CC ya que 
	// solo unos primiparos tienen TI y en cada semestre los primiparos deben representar menos del 15% del total


	use "${mydir_Data_SBPro}\sbpro2012-2014_v1-5.dta", clear

	*renpfix SBP_
	*renpfix SBPRO_
	
	keep EVAL_PERIODO v1 v3_1 v104_1  v5 v13 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino /// 
		 INAC_ANOEXAMENESTADO ///
		 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 ///
		 SBPRO_CITA_SNEE SBPRO_CITA_SNEE_* 
	
	cou
	append using "${mydir_Data_SB11}\sb11_2006-2011_v1-5.dta", ///
		keep(EVAL_PERIODO v5 v5_2 v13 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino ///
		PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2  ///
		CITA_SNEE*) 
		
	rename CITA_SNEE1 CITA_SNEE_1
	cap rename CITA_SNEE2 CITA_SNEE_2
	cap rename CITA_SNEE3 CITA_SNEE_3
	cap rename CITA_SNEE4 CITA_SNEE_4
	cap rename CITA_SNEE5 CITA_SNEE_5
	cap rename CITA_SNEE6 CITA_SNEE_6
	
	cou
	order EVAL_PERIODO v1 INAC_ANOEXAMENESTADO v3_1 v104_1 v5 v5_2 v13 ///
	Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino  ///
	PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 ///
	CITA_SNEE_* ///
	SBPRO_CITA_SNEE SBPRO_CITA_SNEE*
	

	save "${mydir_Data_SB11P}\SB11Pro_2006_2014.dta", replace
	
	
********************************************************
* II. CREANDO LOS MATCHES ENTRE SABER11 Y SABERPRO
********************************************************
	
	use "${mydir_Data_SB11P}\SB11Pro_2006_2014.dta", clear
	
	
	// II.0. Preliminares
	*******************************	
			cap drop Data_Valid
				gen Data_Valid=.
			
			cap drop dup_cou
				gen dup_cou=1
		
		// Version Numerica del ID		
			cap drop lg_v5
				gen lg_v5 = length(v5)
			tab lg_v5	
			
			
			// PARENTESIS: CREANDO CODIGO DE INICIALES DE PRIMER NOMBRE Y APPELLIDO PAR AV5 CON MENOS DE 7 CARACTERES
			// Creando codigo de primera letra de nombre y apellido son orden para aquellos casos JUAN GOMEZ
			// igual a GOMEZ JUAN
				cap drop PN_1
					gen PN_1 = substr(Pri_Nombre,1,1)
				cap drop PA_1
					gen PA_1 = substr(Pri_Aplldo,1,1)
				
				cap drop PNN_1
					gen PNN_1=.
				cap drop PAN_1
					gen PAN_1=.	
				local x1 A B C D E F G H I J K L M N Ñ O P Q R S T U V W X Y Z 
				local i = 1
				foreach x2 of local x1{
					dis "`x2'"		
					replace PNN_1=`i' if PN_1=="`x2'" 
					replace PAN_1=`i' if PA_1=="`x2'" 
					local i = `i'+1
				}	
				tab PN_1 PNN_1 
				tab PA_1 PAN_1 
				tab PNN_1  PAN_1 
				
				cap drop PPNN_1
					gen PPNN_1 = "0"+string(PNN_1) if PNN_1<=9
					replace PPNN_1 = string(PNN_1) if PPNN_1==""
					replace PPNN_1 = "00" if PPNN_1=="."
				*tab PPNN_1
				
				cap drop PPAN_1
					gen PPAN_1 = "0"+string(PAN_1) if PAN_1<=9
					replace PPAN_1 = string(PAN_1) if PPAN_1==""
					replace PPAN_1 = "00" if PPAN_1=="."
				*tab PPAN_1
				
				cap drop PPP
					gen PPP = PPNN_1+PPAN_1 if PNN_1<=PAN_1
					replace PPP = PPAN_1+PPNN_1 if PNN_1>PAN_1
				*tab PPP
		
				// AHORA SI: Creando el v5 con el que se arman los grupos que usa PPP solo para aquellos registros con longitud < 7
				// Lo que ocurre es que si se hace PPP para todos, quedan muchos registros no asignados que son la misma persona
				// pero que escribieron el nombre de forma distinta
				
				tab lg_v5
				cap drop pv_v5
					gen pv_v5 = v5 if lg_v5>=7 & lg_v5<=13
					replace pv_v5 = v5+PPP if lg_v5<7
					replace pv_v5 = substr(v5,1,9)+PPP if lg_v5>13 & lg_v5!=.

				// Version Numerica del documento de identidad para usarla mas adelante  	
				cap drop p_v5
				gen double p_v5 = real(v5) if lg_v5>=7 & lg_v5<=13
				replace p_v5 = -1*real(v5+PPP) if lg_v5<7
				replace p_v5 = -1*real(substr(v5,1,9)+PPP) if lg_v5>13 & lg_v5!=.
				format %20.0g p_v5 
				
			
		// Garantiza que cruce sea entre resgistros de SaberPro y Saber11
			cap drop r_FO // Buscando matches errados entre registros del mismo examen: los grupos deben ser de SB11 con SBPro
				gen r_FO = 1 if regexm(EVAL_PERIODO,"SB11")==1
				replace r_FO = 2 if regexm(EVAL_PERIODO,"SBPro")==1
			tab r_FO	

		// Reemplazando los missing para poder armar grupos usando egen group()
			replace  Seg_Nombre="SN NBR" if Seg_Nombre==""
			*replace  Seg_Aplldo="SN NBR" if Seg_Aplldo=="" 	
				
			replace SN_SxLv=-98 if SN_SxLv==.
			replace SN_SxLv2=-98 if SN_SxLv2==.

			replace SA_SxLv=-99 if SA_SxLv==.	
			replace SA_SxLv2=-99 if SA_SxLv2==.	

			format %40s Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo 
			
		
		// Anho de Presentacion:
		// Una de las variables claves para el cruce es anno presentacion de Saber11 que se pregunta en SaberPro
			cap drop FP_SB11
				gen FP_SB11 = INAC_ANOEXAMENESTADO
				replace FP_SB11  = real(substr(EVAL_PERIODO,5,4)) if regexm(EVAL_PERIODO,"SB11")==1
			ed 	EVAL_PERIODO INAC_ANOEXAMENESTADO FP_SB11

			// Note, sin embargo, que una proporcion importante (40%) afirma haber presentado Saber11 antes de 2002
			// Para los cuales no tenemos info ya que este cruce usa Saber11 2002-2011			
			tab  INAC_ANOEXAMENESTADO
			tab  INAC_ANOEXAMENESTADO EVAL_PERIODO, col nofreq
			tab  INAC_ANOEXAMENESTADO if INAC_ANOEXAMENESTADO>=2002 
			
			/*
			cap tab  INAC_ANOEXAMENESTADO if FileOrigen=="SBPro20112"
			cap tab  INAC_ANOEXAMENESTADO if INAC_ANOEXAMENESTADO>=2002 & FileOrigen=="SBPro20112"
			*/
			
		// ICFES no tiene problemas de duplicados (o se solucionaron en Parte I arriba)
		******************************************
		/*cou if PA_SxLv==.
		cap drop dup_dlt1 
			egen dup_dlt1 = rank(dup_cou) if Data_Valid==. & v5!="" &  PA_SxLv!=., by(FileOrigen v5 PA_SxLv) unique
		tab dup_dlt1
		
		cap drop dup_dlt1 
			egen dup_dlt1 = rank(dup_cou) if Data_Valid==. &  PN_SxLv!=. &  SN_SxLv!=. &  PA_SxLv!=. &  SA_SxLv!=., by(FileOrigen PN_SxLv SN_SxLv PA_SxLv SA_SxLv v13) unique
		tab dup_dlt1
		*/
	
	
	* II.1. CREANDO LOS GRUPOS POR LOS DIFERENTES CRITERIOS
	*******************************************************************************
	
		// Para un Analisis de los problemas de usar Fecha de Nacimiento, Fecha Presentacion, y Nombre
		// ver "${mydir_DoFiles}\III_2_1_SB11_SBPRO_Merged_Problemas_Vars_Cruce.do"

		order  CITA_SNEE SBPRO_CITA_SNEE Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2
		
		
		*II.1.A Grupos formados por Numero Documento e Iniciales de Primer Apellido	
		*******************************************************************************
			
		cap drop PA_2 // Se hace para descubrir posible errores de igual ID para 2 personas distintas
			gen PA_2 = substr(Pri_Aplldo,1,2)
		tab PA_2	
		
		cap drop gr_A_1			
			egen  gr_A_1 = group(v5) 
		cap drop c_gr_A_1
			egen c_gr_A_1 = count(dup_cou) if gr_A_1!=., by(gr_A_1)
		tab c_gr_A_1
		
		cap drop gr_A_2			
			*egen  gr_A_2 = group(v5_Min PA_2) 
			egen  gr_A_2 = group(p_v5) 
		cap drop c_gr_A_2
			egen c_gr_A_2 = count(dup_cou) if gr_A_2!=., by(gr_A_2)
		tab c_gr_A_2
		* Note que no se pierden muchos matches usando gr_A_2 y se garantiza que no se peguen matches errados
		
		sort p_v5
		ed  EVAL_PERIODO v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
			Masculino r_FO FP_SB11 gr_A_1 gr_A_2 /// 
			if  c_gr_A_2==2 // Estos son los que cruzan
		
		
		// Garantizando que se cruzo Saber11 con SaberPro
			tab r_FO if c_gr_A_2==2
			cap drop prov_par
				egen prov_par = rank(dup_cou) if c_gr_A_2==2, by(gr_A_2 r_FO)
			tab prov_par
			tab r_FO if c_gr_A_2==2 & prov_par==1
		
			ed EVAL_PERIODO v5 p_v5 Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13  ///
				if c_gr_A_2==2 & prov_par==1.5 // Estos son problemas con p_v5 repetidos erroneamente por mi
				// vuelvo positivo una de las dos repeticiones (chequaer que nadie mas quede con ese codigo) para armar los grupos despues
			replace p_v5 = 1461404681320 if c_gr_A_2==2 & prov_par==1.5 & p_v5==-1461404681320 & v13=="21/10/92"
			replace p_v5 = 1461404680310 if c_gr_A_2==2 & prov_par==1.5 & p_v5==-1461404680310 & v13=="06/03/93"
			replace p_v5 = 8447050461213 if c_gr_A_2==2 & prov_par==1.5 & p_v5==-8447050461213 & v13=="04/05/87"
			
			tab INAC_ANOEXAMENESTADO if  c_gr_A_2==2 & prov_par==1
		
		
			// ESTA ES LA VARIABLE QUE SE VA A USAR PARA CONSTRUIR EL Cod_ICFES AL FINAL
			******************************************************************************
			cap drop ID_v5
				*gen ID_v5 = v5 if c_gr_A_2==2 & prov_par==1
				gen double ID_v5 = p_v5 if c_gr_A_2==2 & prov_par==1
			*cou if ID_v5!=""
			cou if ID_v5!=.
			*tab r_FO if ID_v5!=""
			tab r_FO if ID_v5!=.
			ed  EVAL_PERIODO v5 v13 Pri_Nombre Pri_Aplldo Masculino gr_A_2 ID_v5 p_v5 lg_v5 /// 
				if  ID_v5!=. // Estos son los que cruzan
			
			
		*II.1.B Grupos formados por Nombre Completo SxLv y Fecha de Nacimiento	
		*******************************************************************************
		
		cap drop gr_B1
			egen  gr_B1 = group(PN_SxLv SN_SxLv PA_SxLv SA_SxLv v13) if PN_SxLv!=. & SN_SxLv!=. & PA_SxLv!=. & SA_SxLv!=. & v13!="" & c_gr_A_2==1
		cap drop c_gr_B1
			egen c_gr_B1 = count(dup_cou) if gr_B1!=., by(gr_B1)
		tab c_gr_B1 
			
		sort gr_B1
		ed  EVAL_PERIODO v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
			Masculino r_FO FP_SB11 gr_A_2 gr_B1 ///
			if  c_gr_B1==2 
		
			// Garantizando que se cruzo Saber11 con SaberPro
			tab r_FO if c_gr_B1==2
			cap drop prov_par
				egen prov_par = rank(dup_cou) if c_gr_B1==2, by(gr_B1 r_FO)
			tab prov_par
			tab r_FO if c_gr_B1==2 & prov_par==1
		
				// Note que se encontraron nuevos estudiantes presentanbdo una de las pruebas mas de una vez
			ed EVAL_PERIODO v5 Data_Valid Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13 gr_B1 ///
				CITA*  SBPRO_CITA_SNEE* if c_gr_B1==2 & prov_par==1.5
			tab EVAL_PERIODO if c_gr_B1==2 & prov_par==1.5 // Estos son estudiantes que repitieron pruebas y no fueron identificados antes
				
				// Salvando la cita_snee adicional
				cap drop r_gr_B1
					egen r_gr_B1 = rank(dup_cou) if c_gr_B1==2 & prov_par==1.5,by(gr_B1) unique
				tab r_gr_B1 prov_par	
				
					// Cuantos tienen ya mas de una cita?
				cap cou if CITA_SNEE_2!="" & c_gr_B1==2 & prov_par==1.5				
				cap cou if CITA_SNEE_3!="" & c_gr_B1==2 & prov_par==1.5				
				cap cou if CITA_SNEE_4!="" & c_gr_B1==2 & prov_par==1.5				
				cap cou if SBPRO_CITA_SNEE_2!="" & c_gr_B1==2 & prov_par==1.5				
				cap cou if SBPRO_CITA_SNEE_3!="" & c_gr_B1==2 & prov_par==1.5				
								
				cap drop p_CITA_SNEE_2
					gen p_CITA_SNEE_2=""
				replace p_CITA_SNEE_2 = CITA_SNEE_1 if c_gr_B1==2 & prov_par==1.5 & (r_gr_B1==1)
				by gr_B1, sort: replace p_CITA_SNEE_2 = p_CITA_SNEE_2[_n-1] if c_gr_B1==2 & prov_par==1.5 & p_CITA_SNEE_2==""
				cap by gr_B1, sort: replace CITA_SNEE_2 = CITA_SNEE_2[_n-1] if c_gr_B1==2 & prov_par==1.5 & CITA_SNEE_2==""
				
					cap replace CITA_SNEE_2 = p_CITA_SNEE_2 if c_gr_B1==2 & prov_par==1.5 & CITA_SNEE_1!=p_CITA_SNEE_2 & CITA_SNEE_2==""
					cap replace CITA_SNEE_3 = p_CITA_SNEE_2 if c_gr_B1==2 & prov_par==1.5 & CITA_SNEE_1!=p_CITA_SNEE_2 & CITA_SNEE_2!="" & CITA_SNEE_3==""
					cap replace CITA_SNEE_3="" if  CITA_SNEE_2== p_CITA_SNEE_2 & CITA_SNEE_2== CITA_SNEE_3
				
				cap drop p_CITA_SNEE_2
					gen p_CITA_SNEE_2=""
				replace p_CITA_SNEE_2 = SBPRO_CITA_SNEE if c_gr_B1==2 & prov_par==1.5 & (r_gr_B1==1) & SBPRO_CITA_SNEE!=""	
				by gr_B1, sort: replace p_CITA_SNEE_2 = p_CITA_SNEE_2[_n-1] if c_gr_B1==2 & prov_par==1.5 & p_CITA_SNEE_2==""
				by gr_B1, sort: replace SBPRO_CITA_SNEE_2= SBPRO_CITA_SNEE_2[_n-1] if c_gr_B1==2 & prov_par==1.5 & SBPRO_CITA_SNEE_2==""
				
					cap replace SBPRO_CITA_SNEE_2 = p_CITA_SNEE_2 if c_gr_B1==2 & prov_par==1.5 & SBPRO_CITA_SNEE!=p_CITA_SNEE_2 & SBPRO_CITA_SNEE_2==""
					cap replace SBPRO_CITA_SNEE_3 = p_CITA_SNEE_2 if c_gr_B1==2 & prov_par==1.5 & SBPRO_CITA_SNEE!=p_CITA_SNEE_2 & SBPRO_CITA_SNEE_2!="" & SBPRO_CITA_SNEE_3==""
					cap replace SBPRO_CITA_SNEE_3="" if  SBPRO_CITA_SNEE_2== p_CITA_SNEE_2 & SBPRO_CITA_SNEE_2== SBPRO_CITA_SNEE_3
				
				ed EVAL_PERIODO v5 Data_Valid Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13 gr_B1 ///
					r_gr_B1 CITA*  p_CITA* SBPRO_CITA_SNEE* if c_gr_B1==2 & prov_par==1.5
				
				// Borrando registro adicional
				drop if c_gr_B1==2 & prov_par==1.5 & (r_gr_B1==1)
				
		tab INAC_ANOEXAMENESTADO if  c_gr_B1==2 & prov_par==1
		
		
			// ESTA ES LA VARIABLE QUE SE VA A USAR PARA CONSTRUIR EL Cod_ICFES AL FINAL
			******************************************************************************
			
			cap drop ID_prov // MINMODE nos deja con la cedula que es mejor para el cruce con SNIES 
				*egen ID_prov = mode(v5) if c_gr_B1==2 & prov_par==1, by(gr_B1) minmode
				*egen ID_prov = mode(p_v5) if c_gr_B1==2 & prov_par==1, by(gr_B1) minmode
				egen double ID_prov = mode(p_v5) if c_gr_B1==2, by(gr_B1) minmode // se incluye los prov=1.5 que son la misma persona tomando el examen varias veces
				
			ed v5 p_v5 lg_v5 ID_prov gr_B1 if c_gr_B1==2 & prov_par==1
			
			ed EVAL_PERIODO v5 Data_Valid Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino v13 ID_prov gr_B1 ///
				CITA*  SBPRO_CITA_SNEE* if c_gr_B1==2 & prov_par==1.5
			tab EVAL_PERIODO if c_gr_B1==2 & prov_par==1.5 // Estos son estudiantes que repitieron pruebas y no fueron identificados antes
			
			
			cou if ID_v5!=.
			replace ID_v5 = ID_prov if c_gr_B1==2 & prov_par==1 & ID_v5==. & ID_prov!=.
			ed  EVAL_PERIODO v5 v13 Pri_Nombre Pri_Aplldo Masculino gr_B1 c_gr_B1 ID_v5 p_v5 lg_v5 /// 
				if  ID_v5!=. & c_gr_B1==2 // Estos son los que cruzan
			
			cou if ID_v5!=.
			tab r_FO if ID_v5!=.
			
			
			/*
			cap tab r_FO if ID_v5!=. & FileOrigen=="SBPro20112"
			tab FileOrigen if  INAC_ANOEXAMENESTADO>=2002 
			
			cou if r_FO==2 & ID_v5!=. & FileOrigen=="SBPro20112"
			local a = r(N)
			cou if  FileOrigen=="SBPro20112" &  INAC_ANOEXAMENESTADO>=2002
			local b = r(N)
			dis `a'/`b'
			*/
		
		
		
		*II.1.C Grupos formados por Nombre Completo SxLv y Fecha de Presentacion	
		*******************************************************************************
		
		cap drop gr_C1			
			egen  gr_C1 = group(PN_SxLv SN_SxLv PA_SxLv SA_SxLv FP_SB11) if PN_SxLv!=. & SN_SxLv!=. & PA_SxLv!=. & SA_SxLv!=. & FP_SB11!=. & ID_v5==.
		cap drop c_gr_C1
			egen c_gr_C1 = count(dup_cou) if gr_C1!=., by(gr_C1)
		tab c_gr_C1 
			
		sort gr_C1
		ed  EVAL_PERIODO v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
			Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 ///
			if  c_gr_C1==2 
		
			// Garantizando que se cruzo Saber11 con SaberPro
			tab r_FO if c_gr_C1==2
			cap drop prov_par
				egen prov_par = rank(dup_cou) if c_gr_C1==2, by(gr_C1 r_FO)
			tab prov_par
			tab r_FO if c_gr_C1==2 & prov_par==1
		
			// ***NOTA***: Aqui los prov1.5 son homonimos y no hay necesidad de salvar las citas
			
		
		tab INAC_ANOEXAMENESTADO if  c_gr_C1==2 & prov_par==1
		
		
			// ESTA ES LA VARIABLE QUE SE VA A USAR PARA CONSTRUIR EL Cod_ICFES AL FINAL
			******************************************************************************
			
			cap drop ID_prov // MINMODE nos deja con la cedula que es mejor para el cruce con SNIES 
				*egen ID_prov = mode(v5) if c_gr_C1==2 & prov_par==1, by(gr_C1) minmode
				egen double ID_prov = mode(p_v5) if c_gr_C1==2 & prov_par==1, by(gr_C1) minmode
			ed v5 ID_prov gr_C1 if c_gr_C1==2 & prov_par==1
			
			*replace ID_v5="" if c_gr_B1==2 & ID_prov!=""
			cou if ID_v5!=.
			replace ID_v5 = ID_prov if c_gr_C1==2 & prov_par==1 & ID_v5==. & ID_prov!=.
			ed  EVAL_PERIODO v5 v13 Pri_Nombre Pri_Aplldo Masculino gr_C1 c_gr_C1 ID_v5 p_v5 lg_v5 /// 
				if  ID_v5!=. & c_gr_C1==2 & prov_par==1 // Estos son los que cruzan
			
			
			/*
			cap tab r_FO if ID_v5!=. & FileOrigen=="SBPro20112"
			tab FileOrigen if  INAC_ANOEXAMENESTADO>=2002 
			
			cou if r_FO==2 & ID_v5!=. & FileOrigen=="SBPro20112"
			local a = r(N)
			cou if  FileOrigen=="SBPro20112" &  INAC_ANOEXAMENESTADO>=2002
			local b = r(N)
			dis `a'/`b'
			*/

			
		*II.1.D Grupos formados por Nombre Completo 
		*******************************************************************************
		
		cap drop gr_D1
			egen  gr_D1 = group(Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo) if Pri_Nombre!="" & Seg_Nombre!="" & Pri_Aplldo!="" & Seg_Aplldo!="" & ID_v5==.					
		cap drop c_gr_D1
			egen c_gr_D1 = count(dup_cou) if gr_D1!=., by(gr_D1)
		tab c_gr_D1 
			
		sort gr_D1
		ed  EVAL_PERIODO v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
			Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 gr_D1 ///
			if  c_gr_D1==2 
		ed  EVAL_PERIODO v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
			Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 gr_D1 ///
			if  c_gr_D1==3 
		
		
			// Garantizando que se cruzo Saber11 con SaberPro
			tab r_FO if c_gr_D1==2
			cap drop prov_par
				egen prov_par = rank(dup_cou) if c_gr_D1==2, by(gr_D1 r_FO)
			tab prov_par
			tab r_FO if c_gr_D1==2 & prov_par==1
		
		tab INAC_ANOEXAMENESTADO if  c_gr_D1==2 & prov_par==1
		
		
			// ESTA ES LA VARIABLE QUE SE VA A USAR PARA CONSTRUIR EL Cod_ICFES AL FINAL
			******************************************************************************
			
			cap drop ID_prov // MINMODE nos deja con la cedula que es mejor para el cruce con SNIES 
				*egen ID_prov = mode(v5) if c_gr_D1==2 & prov_par==1, by(gr_D1) minmode
				egen double ID_prov = mode(p_v5) if c_gr_D1==2 & prov_par==1, by(gr_D1) minmode
			ed v5 ID_prov gr_D1 if c_gr_D1==2 & prov_par==1
			
			*replace ID_v5="" if c_gr_B1==2 & ID_prov!=""
			cou if ID_v5!=.
				replace ID_v5 = ID_prov if c_gr_D1==2 & prov_par==1 & ID_v5==. & ID_prov!=.
				ed  EVAL_PERIODO v5 v13 Pri_Nombre Pri_Aplldo Masculino gr_C1 c_gr_C1 ID_v5 p_v5 lg_v5 /// 
					if  ID_v5!=. & c_gr_D1==2 & prov_par==1 & lg_v5>=12 // Estos son los que cruzan				
			cou if ID_v5!=.
			tab r_FO if ID_v5!=.

			
			/*
			tab r_FO if ID_v5!=. & FileOrigen=="SBPro20112"
			tab FileOrigen if  INAC_ANOEXAMENESTADO>=2002 
			
			cou if r_FO==2 & ID_v5!=. & FileOrigen=="SBPro20112"
			local a = r(N)
			cou if  FileOrigen=="SBPro20112" &  INAC_ANOEXAMENESTADO>=2002
			local b = r(N)
			dis `a'/`b'	
			
			tab r_FO if INAC_ANOEXAMENESTADO>=2002
			cou if r_FO==2 & ID_v5!=.
		    */

		
********************************************************
* III. CALCULANDO % DE CRUCE Y CREANDO Cod_ICFES
********************************************************	
	
	// III.1 Porcentaje de SaberPro que cruza por anho de SaberPro
	******************************************************************
	cap drop I_id
		gen I_id = 1 if r_FO==2 & ID_v5!=.
		replace I_id = 0 if r_FO==2 & ID_v5==.
	tab I_id				
	tabulate EVAL_PERIODO if INAC_ANOEXAMENESTADO>=2002 & r_FO==2, sum(I_id)
		
		
		
	// III.2 Creando Cod_ICFES
	******************************************************************	

	cou if ID_v5!=.
	cap drop Cod2_Icfes
		egen Cod2_Icfes = group(ID_v5) if ID_v5!=.
	codebook Cod2_Icfes

	cap drop c2_CIcfes
		egen c2_CIcfes = count(dup_cou) if Cod2_Icfes!=. , by(Cod2_Icfes)
		
		//No deberia haber registros con c2_CIcfes <> 2. Cuando hay es pq 2 personas distintas tienen igual documento 
	tab c2_CIcfes 
	
	
	/* Eliminando los registros que tienen c2_CIcfes<>2
	sort Cod2_Icfes
	ed  FileOrigen v5 p_v5 ID_v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
		Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 gr_D1 Cod2_Icfes ///
		if  c2_CIcfes==4
	ed  FileOrigen v5 p_v5 ID_v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
		Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 gr_D1 Cod2_Icfes ///
		if  c2_CIcfes==4	
		
		
	// El problema de dejar estos resgistros es que despues no va a cruzar bien con SNIES por v5, pese a que son
	// solo 20 registros
	drop if c2_CIcfes==4
	*replace Cod2_Icfes=. if c2_CIcfes==4 
	*tab ID_v5 if c2_CIcfes==4
	*replace ID_v5="" if c2_CIcfes==4 // Se hace para poder asignarle codigo en gr_prv
	cap drop Cod2_Icfes //Se vuelve a hacer para que el codigo quede continuo sin huecos
		egen Cod2_Icfes = group(ID_v5) if ID_v5!=.
	codebook Cod2_Icfes
	
	sort Cod2_Icfes
	ed  FileOrigen v5 v13 Pri_Nombre PN_SxLv PN_SxLv2 Seg_Nombre SN_SxLv SN_SxLv2 Pri_Aplldo PA_SxLv PA_SxLv2 Seg_Aplldo SA_SxLv SA_SxLv2 ///
		Masculino r_FO FP_SB11 gr_A_2 gr_B1 gr_C1 gr_D1 Cod2_Icfes ///
		if  Cod2_Icfes!=.
	*/
	
	
	// Agregando Cod_ICFES al resto que no cruzo
	**********************************************
	tab EVAL_PERIODO if  ID_v5!=.
		
		// (i). Codigo Unico para los SIN MATCH
		cou if ID_v5==.
		cou if ID_v5==. & p_v5!=.
		
		cap drop gr_prv	// Este es el codigo de los sin match		
			*egen gr_prv= group(v5 PA_2) if ID_v5==.
			egen gr_prv= group(p_v5) if ID_v5==.
		
			/*
			//Note que aquellos sin PA_2 se quedan sin gr_prv
			qui sum gr_prv 
			local a = r(max)
			dis "`a'"	
			*replace gr_prv = `a'+_n if ID_v5==. & PA_2==""
			replace gr_prv = `a'+_n if ID_v5==. 
			*codebook gr_prv // No usar este p tiene huecos por construccion 
			*/
		
		cap drop c_gr_prv
			egen c_gr_prv = count(dup_cou) if gr_prv!=., by(gr_prv)
		tab c_gr_prv
		
		/*
		cap drop gr2_prv // Chequeando que el codigo gr2_prv no tenga huecos a pesar de que gr_prv los tiene
			egen gr2_prv= group(gr_prv) if gr_prv!=. 	
		codebook gr2_prv
		*/
		
		// (ii). Creando Cod_Icfes	
		sum Cod2_Icfes
		cap drop Cod_Icfes
			gen Cod_Icfes = Cod2_Icfes if Cod2_Icfes!=.	
		qui sum Cod_Icfes //Estos son los que cruzaron
		local a = r(max)
		dis "`a'"
		*replace Cod_Icfes = `a'+gr2_prv if Cod_Icfes==. & gr2_prv!=.
		replace Cod_Icfes = `a'+ gr_prv if Cod_Icfes==. & gr_prv!=.
		sum Cod_Icfes 
		codebook Cod_Icfes
	
		
		cap drop c_Cod_Icfes
			egen c_Cod_Icfes=count(dup_cou), by(Cod_Icfes)
		tab c_Cod_Icfes, miss
	

	
	// Guardando los documentos de ID para cruzar con SNIES
	********************************************************	
	
	/*
	cap drop p_v5
		gen double p_v5 = real(v5)
	format %20.0g p_v5 
	*/
	
		// Cuando hay mas de 1 documento se organiza primero el menor y depues el mayor
	cap drop v5_Min // 		
		egen double v5_Min = mode(p_v5), by(Cod_Icfes) minmode 
	cap drop v5_Max // 		
		egen double v5_Max = mode(p_v5), by(Cod_Icfes) maxmode 	
	ed v5  p_v5 v5_Min v5_Max Cod_Icfes c_Cod_Icfes if v5_Min!=v5_Max
	ed v5  p_v5 v5_Min v5_Max Cod_Icfes c_Cod_Icfes if lg_v5>=13
	

	
	// Guardando hasta dos fechas de nacimiento
	***********************************************************
	cap drop p_v13
		gen p_v13 = substr(v13,7,2)+substr(v13,4,2)+substr(v13,1,2)+"/"+v13
	ed p_v13 v13
	
	cap drop v13_Min // 		
		egen v13_Min = mode(p_v13), by(Cod_Icfes) minmode 
	cap drop v13_Max // 		
		egen v13_Max = mode(p_v13), by(Cod_Icfes) maxmode 	
	cou if v13_Max !=v13_Min 
	
	
	replace v13_Min = substr(v13_Min,8,.)
	replace v13_Max = substr(v13_Max,8,.)
	ed v13 v13_Min  v13_Max if v13_Max !=v13_Min 
	
	// Imputando fecha a aquellos con fecha /.0/
	ed v13 v13_Min  v13_Max if regexm(v13_Min,"\.")==1 | regexm(v13_Min,"^/")==1 | regexm(v13_Max,"\.")==1 | regexm(v13_Max,"^/")==1  
	
	ed v13 v13_Min  v13_Max if (regexm(v13_Min,"\.")==1 | regexm(v13_Min,"^/")==1) & ~(regexm(v13_Max,"\.")==1 | regexm(v13_Max,"^/")==1)  
	replace v13_Min = v13_Max if (regexm(v13_Min,"\.")==1 | regexm(v13_Min,"^/")==1) & ~(regexm(v13_Max,"\.")==1 | regexm(v13_Max,"^/")==1)
	// No se necesita el otro porque el maximo solo tiene /. si el minimo tambien lo tiene
	
	ed v13 v13_Min v13_Max if (regexm(v13_Min,"\.")==1 | regexm(v13_Min,"^/")==1) & (regexm(v13_Max,"\.")==1 | regexm(v13_Max,"^/")==1)  	
	replace v13_Min = "SF" if (regexm(v13_Min,"\.")==1 | regexm(v13_Min,"^/")==1) & (regexm(v13_Max,"\.")==1 | regexm(v13_Max,"^/")==1)  
	replace v13_Max = "SF" if v13_Min == "SF"
	
	drop p_v13
	
	ed v5  p_v5 v5_Min v5_Max Cod_Icfes c_Cod_Icfes v13 v13_* if c_Cod_Icfes==2
	
	save "${mydir_Data_SB11P}\SB11Pro_2006_2014v2.dta", replace
	
	
	/* Archivo entregado a ICFES en Jul 24 2012
	use "${mydir_Data_SB11P}\SB11Pro_2002_2011.dta", clear
	keep id_cons  FileOrigen v5 v13 Pri_Nombre  Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino  ///
	cita_snee_1- SBPRO_cita_snee_3 FP_SB11 Cod_Icfes  c_Cod_Icfes
	outsheet using "C:\Users\jbonilla\Documents\Saber11Pro\SB11Pro_2002_2011_Jul24.csv"
	*/
	
	
	
	
	
*******************************************************************
* ARMANDO ARCHIVO QUE SE VA A CRUZAR CON SNIES
*******************************************************************


*use "${mydir_Data_SNIES}\SN_20071P_20112P.dta", clear



use "${mydir_Data_SB11P}\SB11Pro_2006_2014v2.dta", clear

cou if ID_v5==.
replace ID_v5=p_v5 if ID_v5==. // id_v5 es la minmode de los que si cruzan

keep CITA_SNEE EVAL_PERIODO v1 INAC_ANOEXAMENESTADO  v3_1 v104_1 v5 v5_2 ID_v5 p_v5 v5_Min v5_Max ///
	 v13 v13_Min v13_Max Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo Masculino ///
	 PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 ///
	 CITA_SNEE_* ///
	 SBPRO_CITA_SNEE SBPRO_CITA_SNEE_* ///
	 dup_cou Cod_Icfes c_Cod_Icfes
	 
	 
	/*cou
	collapse (sum) dup_cou (first) id_cons FileOrigen v1 INAC_ANOEXAMENESTADO  /// Se Demora mucho
		v3_1 v104_1 v5 v5_2 ID_v5 v13 ///
		Pri_Nombre Seg_Nombre  Pri_Aplldo Seg_Aplldo Masculino ///
		PN_SxLv PN_SxLv2 SN_SxLv SN_SxLv2 PA_SxLv PA_SxLv2 SA_SxLv SA_SxLv2 ///
		cita_snee_1 cita_snee_2 cita_snee_3 cita_snee_4 cita_snee_5 cita_snee_6 ///
		SBPRO_cita_snee SBPRO_cita_snee_1 SBPRO_cita_snee_2 SBPRO_cita_snee_3 ///
		c_Cod_Icfes  ///
		, by(Cod_Icfes)
	*/
	
	cou
	
	cap drop r_Cod_Icfes // Se hace este en lugar del collapse pe con el collapse se queda parado
		egen r_Cod_Icfes = rank(dup_cou), by(Cod_Icfes) unique
	tab r_Cod_Icfes, miss
	codebook Cod_Icfes if r_Cod_Icfes==1
	drop if r_Cod_Icfes!=1
	
save "${mydir_Data_SB11P}\SB11Pro_2006_2014_NoRep.dta", replace


	
	
	