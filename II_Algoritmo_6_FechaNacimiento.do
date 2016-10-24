

	************************************************************************************************************
	// I. Antes de editar fecha de Nacimiento, usar tarjeta de identidad para imputar fecha de registros faltantes
	************************************************************************************************************
	
		// Quitando caracteres extranos de v5
	
	replace v5 = subinstr(v5,"`","",100)
	replace v5 = subinstr(v5,".","",100)
	replace v5 = subinstr(v5,",","",100)
	
	
	charlist v5
	local ctrs = r(sepchars) // Todos los caracteres (buenos [0-9] y malos [resto]) del documento de identidad 
	local nctrs=wordcount("`ctrs'") // Para Determinar el fin del while
	local ascctrs = r(ascii)	
	display "`ctrs'"
	display "`nctrs' elementos"
	display "`ascctrs"'
	
	replace v5 = subinstr(v5,"X","",10)
	local i = 1
	while `i'<=`nctrs'{
		gettoken u ctrs : ctrs
		gettoken v ascctrs : ascctrs
		if strpos("0123456789X","`u'")==0{ //Para todos los caracteres con excepcion de los numeros:	
				dis "`u'" 
				replace v5= subinstr(v5,"`u'","",5) // Reemplaza los caracteres extranos por vacio 
				*replace v5= subinstr(v5,"`u'","X`v'X",5) // Reemplaza los caracteres extranos por vacio 
			}		
	local i = `i'+1
	}
	charlist v5
	*ed v5 if regexm(v5,"X")==1
	
	replace v5 = subinstr(v5,"X","",30)
	replace v5 = subinstr(v5," ","",30)
	
	
	
	
		// Imputando la fecha de nacimiento con los datos de la tarjeta de identidad
	
	cap drop v5_lgt
	gen v5_lgt = length(v5)
	tab v5_lgt v6
	tab v5_lgt v6 if v6=="CC" | v6=="TI" | v6=="CE" | v6=="NP" | v6=="NU" 
	
	cou if v13==""
	*ed v5 v6 v13 if (v6=="TI" | length(v5)==11) &  v13==""
	
	cap drop prov_Iv13 // Indicador de posible tarjeta de identidad: 11 caracteres
	gen prov_Iv13 = 1 if length(v5)==11 &  v13=="" & substr(v5,1,1)!="1" & (v6=="TI" | v6=="CC")
	tab prov_Iv13
	
		// Reemplazando fecha con la info de tarjeta de identidad para aquellos sin fecha
	replace v13 = substr(v5,5,2) + "/" + substr(v5,3,2) + "/" + substr(v5,1,2)  if prov_Iv13 == 1
	*ed v5 v6 v13 if prov_Iv13==1
	replace v6 = "TI" if v6=="CC" & prov_Iv13==1
	
	

	************************************************************************************************************
	// II. Identificando fechas inusualmente frecuentes
	************************************************************************************************************
	
	
	
	// A. Edad del Estudiante en 2007 para mas adelante identificar edades inusuales 
	*******************************************************************************
		cap drop FN_ano
		gen FN_ano = real(substr(v13,7,2))
		replace FN_ano = 1900+FN_ano if (FN_ano>=12 & FN_ano<=99) 	
		replace FN_ano = 2000+FN_ano if (FN_ano>=0 & FN_ano<=11) 	
		tab FN_ano										 

		cap drop FN_mes
		gen FN_mes = real(substr(v13,4,2))
		replace FN_mes = . if ~(FN_mes>=1 & FN_mes<=12)
		tab FN_mes

		cap drop FN_dia
		gen FN_dia = real(substr(v13,1,2))
		replace FN_dia = . if ~(FN_dia>=1 & FN_dia<=31)
		tab FN_dia

		local YR = v1[1] // v1 = Año del Archivo. Se generaliza para usar esto con otros archivos del MEN 
		dis "`YR'"
		cap drop age_`YR' //Assumiendo mitad de ano
		gen age_`YR' = (`YR'-FN_ano) + (6-FN_mes)/12
		sum age_`YR', detail
			
		replace FN_ano = . if ~(age_`YR'>=15 & age_`YR'<=60) 				
		replace FN_mes = . if FN_ano==.
		replace FN_dia = . if FN_ano==.
		replace age_`YR' = . if FN_ano==.
		sum age_`YR', detail
			
		cap drop FN_valid //Variable indicadora para tener en cuanta cuando se use v13 para los cruces
		gen FN_valid=1 if FN_ano!=.
		tab FN_valid
		tab FN_ano										  

	
	//  B. Identificando duplicados antes de calcular la distribucion de fechas de nacimiento
		************************************************************************************
		
		destring(v1), replace
		cap drop dup_FN //La idea es usar dup_FN==1 como condicion para no tener en cuenta los duplicados ()
		egen dup_FN = rank(v1) if Pri_Nombre!="" & FN_valid==1, by(Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo v13) unique
		tab dup_FN 
		
				
	// C. Criterios para Identificar fechas de nacimiento poco frequentes	
	   *******************************************************************************
		cap drop stbyIES 
		*egen stbyIES = count(v1) if FN_valid==1 & dup_FN==1, by(v3) // Nro de estudiantes en IES
		egen stbyIES = count(v1) if FN_valid==1 & dup_FN==1, by(v3 FN_ano) // Nro de estudiantes por AñoNacimiento/IES
				
		cap drop stbyFNIES 
		*egen stbyFNIES = count(v1) if FN_valid==1 & dup_FN==1, by(v3 v13) // Nro de estudiantes por FechaNacimiento/IES
		egen stbyFNIES = count(v1) if FN_valid==1 & dup_FN==1, by(v3 v13 FN_ano) // Nro de estudiantes por AñoNacimiento/FechaNacimiento/IES

			
		
		// INDICADOR 1: Distribucion de fecha de Nacimiento al interior de grupos formados por IES/AñoNacimiento
		// En principo, % altos indicarian fechas sospechosamente frecuentes. 
		// Sin embargo, este criterio solo es valido para grupos grandes (stbyIES>>0) ya que si stbyIES=23,
		// la probabilidad de que 2 pesonas nazcan el mismo dia es de 0.5 (Birthday Paradox)  
			cap drop pFNwIES  
			gen pFNwIES=  stbyFNIES/stbyIES
		
	
		// INDICADOR 2: Poisson Approximation
		// P(AT LEAST one n-tuple birthday in a group os size N) =~ 1-exp(-comb(N,n)/365^(n-1))
		// Success = "A given n-tuple has the same birthday"
		// The total number of successes is approximately Poisson with mean value comb(N,n)/[365^(n-1)].
		// where comn(N,n) is the total number of n-tuples
		// and 1/[365^(n-1)] is the prob. that any particular n-tuple is a success.
		
					// gen  psn = 1-exp(-comb(stbyIES,stbyFNIES)/365^(stbyFNIES-1)) 
					// Lo que se hace de aqui en adelante es lo mismo que esto pero descompuesto en partes para evitar 
					// missing values por valores muy grandes. Por eso se hace en logaritmos
					
		cap drop Log1 // Log1 = log(comb(stbyIES,stbyFNIES)): Se hace para poder calcular numeros grandes. De lo contrario stata pone "."
		gen double Log1 =  lnfactorial(stbyIES) - (lnfactorial(stbyFNIES) + lnfactorial(stbyIES - stbyFNIES))
		cou if stbyIES!=. & stbyFNIES!=.
		cou if Log1!=.
		sum Log1, detail
		
		cap drop e1
		gen double e1 = exp(Log1) // Devolviendolo a su magnitud original 
		cou if e1!=.
		sum e1, detail
		sum Log1 if e1==., detail // Note que lo reemplaza por "." para numeros grandes
		replace e1=7.2e+304 if Log1>=r(min) & stbyIES!=. & stbyFNIES!=. // Reemplazandolo por numero GRANDE 
		cou if e1!=.
		
		***
	
		cap drop Log2 // Log2 = log(365^(stbyFNIES-1))
		gen double Log2 =  (stbyFNIES-1)*ln(365)
		cou if Log2!=.
		sum Log2, detail
		
		cap drop e2
		gen double e2 = exp(Log2) // Devolviendolo a su magnitud original 
		cou if e2!=.
		sum e2, detail
		sum Log2 if e2==., detail // Note que lo reemplaza por "." para numeros grandes
		replace e2=7.3e+304 if Log2>=r(min) & stbyIES!=. & stbyFNIES!=. // Reemplazandolo por numero AUN MAS GRANDE 
		cou if e2!=.
		
		***
		
		cap drop psn // Esta es la probabilidad de al menos una n-tupla en un grupo de tamaño N
		gen double psn = 1-exp(-e1/e2)
		
		***

		
		// INDICADOR 3: Poisson Distribution: Especialmente bueno para identificar los problemas con numeros grandes
		cap drop ppssn // poisson(m,k)=Prob. of observing at most k ocurrences of a RV with mean m  
					   // poisson(m,k) - poisson(m,k-1) =  Prob. of observing exactly k ocurrences of a RV with mean m  
					   // Here is the prob of observing at most k people born WITHIN a day (That's why I assume poisson) in a given year/IES
					   // The mean number of daily births for each year/IES varies with the number of students in that year/IES
					   // In general, the average number of students being born on a given day is given by the number of students over 365 (=stbyIES/365)
		gen ppssn = poisson(stbyIES/365,stbyFNIES)-poisson(stbyIES/365,stbyFNIES-1) 
		sum ppssn, detail // The idea is to look at those with a probability equal to zero to identify potential date mistakes
		
		
		
		// D. Escogiendo los umbrales de los indicadores para determinar fechas inusualmente frecuentes
	   **************************************************************************************************
		sum psn, detail    // Los potenciales probemas son aquellos con numeros cercanos a cero
		cou if psn<=0.001  // No hay mayor variacion en el numero de registros entre estos diferentes umbrales
		cou if psn<=0.003
		cou if psn<=0.005
		cou if psn<=0.01
		cou if psn<=0.05
		cou if psn<=0.1
		cou if psn<=0.2
		cou if psn<=0.3
		cou if psn<=0.4
		cou if psn<=0.5
		
		
		sum stbyIES stbyFNIES if psn==1, detail // Funciona para psn==1
		cap tab stbyIES stbyFNIES if psn==1 //Note that psn==1 for large values of stbyFNIES (>=10) as long as there are very large values of stbyIES
		gsort -psn
		*ed v3 v4 v7 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if psn!=1
		
		sum psn if stbyFNIES==1, detail // Note que este indicador no elimina registros de fecha unica ya que estos exhiben probabilidades altas
		sum psn if stbyFNIES==2, detail // Solo en pocos casos la prob. de hallar al menos un apareja es muy baja
		*ed v3 v4 v7 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if stbyFNIES==2 & psn<0.1		
		
		cap tab stbyIES stbyFNIES if psn<=0.1  // Cuales son las combinaciones de stbyIES stbyFNIES que se eliminarian con criterio psn<=0.1?
		cap tab stbyIES stbyFNIES if psn<=0.1 & stbyFNIES<=20 					
		cap tab stbyIES stbyFNIES if psn<=0.1 & stbyFNIES>20 & stbyFNIES<=40    
		cap tab stbyIES stbyFNIES if psn<=0.1 & stbyFNIES>40 & stbyFNIES<=100   
		cap tab stbyIES stbyFNIES if psn<=0.1 & stbyFNIES>100                   
		
		
		// IMPORTANTE: Note que usar psn puede estar dejando por fuera repeticiones muy altas
		// (quiza por los problemas de calcular combinatorias y exp de numeros grandes)
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if psn>0.1 & pFNwIES>=0.1 & FN_valid==1 & psn!=. 
			// Quitando los stbyFNIES<=2 que son precisamente los que funcionan bien con psn
			// Note que son pocos casos pero evidentemente errados
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if psn>0.1 & pFNwIES>=0.1 & FN_valid==1 & psn!=. & stbyFNIES>2
			
			
			// Fechas sospechosas bajo el criterio 1: Aquellos con una fecha mayor al 10% de la distribucion
		cap tab v13 if pFNwIES>=0.10 & pFNwIES!=. & FN_valid==1 
		cap tab v13 if pFNwIES>=0.10 & pFNwIES!=. & FN_valid==1 & stbyFNIES>2 // Fechas sospechosas
		
		cap drop FN_SOS1
		gen FN_SOS1 = 1 if pFNwIES>=0.1 & pFNwIES!=. & stbyFNIES>2
		replace FN_SOS1 = 0 if pFNwIES<0.1 & pFNwIES!=. & stbyFNIES>2
		cap tab FN_SOS1

			// Fechas sospechosas bajo el criterio 2: Baja probabilidad de que una n-tupla cumpla el mismo dia
		cou if psn<=0.1 & psn!=. 
		cou if psn>0.1 & psn!=. 
		
			// Fechas sospechosas bajo el criterio 3: Aquellas muy cerca de cero ppssn<=0.002=(1/365)
		cou if ppssn<=0.0028 & ppssn!=. // Es menos claro definir el umbral para este criterio
		sum ppssn, detail
		sum ppssn if psn<=0.1 & psn!=., detail
		sum ppssn if psn>0.1 & psn!=., detail
		
		
		// Coincidencia entre criterios 1 y 3
		cou if FN_SOS1==1 // Aquellos sospechosos por pFNwIES>=0.1 pero con stbyFNIES>2
		cou if (psn<=0.1 & psn!=.) & FN_SOS==1 // Gran coincidencia
		cou if (psn>0.1 & psn!=.) & FN_SOS==1 	// Cuales estan en criterio 1 pero no en 2
			// Note que la coincidencia es casi exacta; solo varia por el problema con los numeros grandes
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if (psn>0.1 & psn!=.) & FN_SOS==1 
		
		
		// Coincidencia entre criterios 2 y 3
		cou if ppssn<=0.0028 & ppssn!=. // Criterio 3
		cou if (psn<=0.1 & psn!=.) & (ppssn<=0.0028 & ppssn!=.) // coincidencia Regular
			// Cuales estan bajo criterio 3 pero no bajo criterio 2?
		cou if (psn>0.1 & psn!=.) & (ppssn<=0.0028 & ppssn!=.) 
			// Muchos son problemas del criterio 3 que no funciona muy bien 
			// Sin embargo, note que ppssn==0 son precisamente los casos inusualmente frequentes de numeros grandes!
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if (psn>0.1 & psn!=.) & (ppssn<=0.0028 & ppssn!=.)
		
		
		// Coincidencia entre criterios 1, 2 y 3
		cou if FN_SOS1==1 // Aquellos sospechosos por pFNwIES>=0.1 pero con stbyFNIES>2
		cou if (psn<=0.1 & psn!=.) & FN_SOS1==1 
		cou if ((psn<=0.1 & psn!=.) & FN_SOS1==1) | (ppssn==0 & FN_SOS1==1) 
		sum pFNwIES if ((psn<=0.1 & psn!=.) & FN_SOS1==1) | (ppssn==0 & FN_SOS1==1), detail 
		sum psn if ((psn<=0.1 & psn!=.) & FN_SOS1==1) | (ppssn==0 & FN_SOS1==1), detail 
		cap tab v13 if ((psn<=0.1 & psn!=.) & FN_SOS1==1) | (ppssn==0 & FN_SOS1==1)
		
		
		// Note que al final el principal riterio es FN_SOS1==1. 
		// Sin embrago, sera que existen otros que deberian ser borrados a pesar de tener FN_SOS1==0? (pFNwIES<0.1 y stbyFNIES>2)
		cou if FN_SOS1==1 // Aquellos sospechosos por pFNwIES>=0.1 pero con stbyFNIES>2
		cou if (psn<=0.1 & psn!=.) & FN_SOS1==0 // Sospechoso criterio 2 pero no sospechoso criterio 1		
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if (psn<=0.1 & psn!=.) & FN_SOS1==0  // FN_SOS1==0 es pFNwIES<0.1
				
		cou if (ppssn<=0.002 & ppssn!=.) & FN_SOS1==0 // Sospechoso criterio 2 pero no sospechoso criterio 1				
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if (ppssn<=0.002 & ppssn!=.) & FN_SOS1==0  
				
				
		// Conclusion: Reemplazar fechas de aquellos con FN_SOS1==1. (pFNwIES>=0.1 pero con stbyFNIES>2)
		***************
		cap tab v13 if FN_SOS1==1  		
		ed v3 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if FN_SOS1==1  	
		
		cap tab v13 if FN_SOS1==1 & stbyFNIES<=10  		
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if FN_SOS1==1 & v13=="01/01/70" 	
			
		*ed v3 v4 v9 v13 stbyIES stbyFNIES pFNwIES ppssn psn if FN_SOS1==1 & dup_FN>=2
	  	
		
		
		// E. Creando variable de fecha de nacimiento corregida
		******************************************************************************
		cap drop v13_c //Note que no incluye a aquellos con dup_FN>=2
		gen v13_c = v13 if FN_SOS1!=1 & FN_valid==1 	
		codebook v13_c 
		cap tab FN_ano if v13_c!=""
		
		cou if v13!=""
		cou if v13!="" & FN_valid==1 
		cou if v13!="" & FN_valid==1 & dup_FN==1
		
			// Verificando las diferencias entre v13 y v13_c 
		cou if v13!=""
		cou if v13==v13_c // Incluye obs. sin fecha de nacimiento
		cou if v13==v13_c & v13!="" 
		
		cou if v13!=v13_c & v13!="" // Incluye aquellos con FN_valid!=1 
		cap tab FN_valid, miss
		*ed v3 v4 v9 v13 dup_FN FN_valid stbyIES stbyFNIES pFNwIES ppssn psn if v13!=v13_c & v13!="" 
		cou if v13!=v13_c & v13!="" & FN_valid!=.  // 
		*ed v3 v4 v9 v13 dup_FN stbyIES stbyFNIES pFNwIES ppssn psn if v13!=v13_c & v13!="" & FN_valid!=. 
		
			// Note que aquellos con dup_FN>=2 cuyo dup_FN==1 es valido tambien quedan con fecha		
		*ed v3 v4 v9 v13 v13_c dup_FN stbyIES stbyFNIES pFNwIES ppssn psn FN_SOS1 FN_valid if dup_FN>=2 & dup_FN!=.

		
		
	************************************************************************************************************
	// III. Usando Info de Tarjeta de identidad de nuevo (ver Seccion I) para imputar fecha de nacimiento 
	************************************************************************************************************
		
		// Note que se hace de nuevo porque a pesar de que algunos registros tenian fechas de nacimiento
		// sospechosamente frecuentes y se reemplazaron por vacio, aun se pueden recuperar algunas fechas 
		// para aquellos con tarjeta de identidad valida. 
		
	cou if v13_c==""
	*ed v5 v6 v13_c if (v6=="TI" | length(v5)==11) &  v13_c==""
	
	replace prov_Iv13 = 2 if length(v5)==11 &  v13_c=="" & substr(v5,1,1)!="1" & (v6=="TI" | v6=="CC")
	cap tab prov_Iv13
	
		// Reemplazando fecha con la info de tarjeta de identidad para aquellos con v13_c=="" que tenian v13!=""
		// Se hace con v13_c porque en la seccion II se borraron muchas fechas erroneas de v13 que no se quiere incluir de nuevo
	replace v13_c = substr(v5,5,2) + "/" + substr(v5,3,2) + "/" + substr(v5,1,2)  if prov_Iv13 == 2
	*ed v5 v6 v13 v13_c if prov_Iv13==2
	replace v6 = "TI" if v6=="CC" & prov_Iv13==2	

	
		// Ahora, hay unos registros (que tienen tarjeta de identidad) que tienen una fecha de nacimiento que 
		// NO fue catalogada como sospechosamente frecuente, pero cuyo año de nacimiento NO coincide 
		// con el año de nacimiento de la tarjeta de identidad. Asumiento que la información de la variable doucmento
		// de identidad es mas confiable que la de fecha de nacimiento, se hace la siguiente correccion:
	
		
			// Corrigiendo tipo de documento de CC a TI 
				//A. Cuando los 2 primeros digitos del documento (año si es TI) son IGUALES a los digitos de año de la fecha de nacimiento corregida
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)==substr(v13_c,7,2)
		tab v6 if length(v5)==11 & substr(v5,1,2)==substr(v13_c,7,2)
		*ed v13 v13_c v5 v6 if length(v5)!=11 & substr(v5,1,2)==substr(v13_c,7,2) & v6=="CC" //Cuando no son 11 digitos no funciona el argumento
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)==substr(v13_c,7,2) & v6=="CC"
		replace v6="TI" if length(v5)==11 & substr(v5,1,2)==substr(v13_c,7,2) & v6=="CC"
		
		
				//B. Cuando los 2 primeros digitos del documento (año si es TI) son DIFERENTES a los digitos de año de la fecha de nacimiento corregida
				// pero la variable doucmento empieza con 7,8,9 (las posibles decadas de nacimiento)
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v6=="CC"
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v6=="CC" & (substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9")
		replace v6="TI" if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v6=="CC" & (substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9")
		

			// Corrigiendo Fecha de nacimiento a aquellos que tienen fecha de nacimiento (NO sospechosa)
			// pero cuyo valor difiere de su tarjeta de identidad 
			// Las tarjetas de identidad son identificadas por tener 11 digitos y una estructura inicial de fecha AAMMDD
			
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v13!="" & ///
			(substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9") 
			
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v13!="" & ///
			(substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9") ///
			& ~(real(substr(v5,3,1))<=1 & real(substr(v5,5,1))<=3)
			
		local YR = v1[1] // v1 = Año del Archivo (EX. = 2007 para todos los registros). 						 
		*ed v13 v13_c v5 v6 if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v13!="" & ///
			(substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9") /// Nacido en decadas 70s, 80s, 90s
			& (real(substr(v5,3,1))<=1 & real(substr(v5,5,1))<=3) ///	Primer digito del mes es {0,1} y del dia {0,1,2,3}		
			& ~(`YR'- real(substr(v5,1,2))<=60 &  `YR'- real(substr(v5,1,2))>=15) // el año del archivo menos el año de nacimiento = edad = dede ser [15,60]
		
		replace v13_c = substr(v5,5,2) + "/" + substr(v5,3,2) + "/" + substr(v5,1,2) ///
			if length(v5)==11 & substr(v5,1,2)!=substr(v13_c,7,2) & v13!="" & ///
			(substr(v5,1,1)=="7" | substr(v5,1,1)=="8" | substr(v5,1,1)=="9") /// 
			& (real(substr(v5,3,1))<=1 & real(substr(v5,5,1))<=3) ///	
			& ~(`YR'- real(substr(v5,1,2))<=60 &  `YR'- real(substr(v5,1,2))>=15) 
		
		
		
	************************************************************************************************************
	// IV. Actualizando la info de edad y la variable indicadora de fech avalida
	************************************************************************************************************
	
	tab FN_valid
	replace FN_valid=1 if prov_Iv13 == 2 
	tab FN_valid
		
	
	cap drop FN_ano
	gen FN_ano = real(substr(v13_c,7,2))
	replace FN_ano = 1900+FN_ano if (FN_ano>=12 & FN_ano<=99) 	
	replace FN_ano = 2000+FN_ano if (FN_ano>=0 & FN_ano<=11) 	
	cap tab FN_ano										 

	cap drop FN_mes
	gen FN_mes = real(substr(v13_c,4,2))
	replace FN_mes = . if ~(FN_mes>=1 & FN_mes<=12)
	cap tab FN_mes

	cap drop FN_dia
	gen FN_dia = real(substr(v13_c,1,2))
	replace FN_dia = . if ~(FN_dia>=1 & FN_dia<=31)
	cap tab FN_dia

	
	local YR = v1[1] // v1 = Año del Archivo (EX. = 2007 para todos los registros). 
					 // Se generaliza aqui con T=YR para usar este do file con otros archivos del MEN 
	dis "`YR'"
	cap drop age_`YR'
	gen age_`YR' = (`YR'-FN_ano) + (6-FN_mes)/12 
	sum age_`YR', detail
			
	replace FN_ano = . if ~(age_`YR'>=15 & age_`YR'<=60) 				
	replace FN_mes = . if FN_ano==.
	replace FN_dia = . if FN_ano==.
	replace age_`YR' = . if FN_ano==.
	sum age_`YR', detail
	
	
	cap drop FN_valid //Variable indicadora para tener en cuanta cuando se use v13 para los cruces
	gen FN_valid=1 if FN_ano!=.
	cap tab FN_valid
	cap tab FN_ano	
	

	
	**************************************************
	// BORRANDO VARIABLES QUE NO SE VAN A USAR MAS
	**************************************************
	 drop  v5_lgt prov_Iv13 dup_FN stbyIES stbyFNIES pFNwIES Log1 e1 Log2 e2 psn ppssn FN_SOS1
 	*order  id_cons FileOrigen  v1- v13  v13_c

	
	
	
	
	
		