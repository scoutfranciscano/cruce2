


	* 1. EXTRAYENDO APELLIDOS DE NOMBRES+APELLIDOS QUE ESTAN JUNTOS EN LA MISMA VARIABLE SEPARADA POR ESPACIOS
	****************************************************************************************************************
	cou if v7==v9 & v7!="" & wordcount(v7)>=2 //Primer nombre = primer apellido (Multi-palabra)
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if v7==v9 & v7!="" & wordcount(v7)>=2

		//extrayendo apellidos de campo que tiene todos los nombres y los apellidos 
	replace Pri_Aplldo = regexr(Pri_Aplldo,Pri_Nombre,"") if v7==v9 & v7!="" & wordcount(v7)>=2
	replace Pri_Aplldo = regexr(Pri_Aplldo,Seg_Nombre,"") if v7==v9 & v7!="" & wordcount(v7)>=2
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if v7==v9 & v7!="" & wordcount(v7)>=2

		//quitando espacios
	replace Pri_Aplldo = regexr(Pri_Aplldo ,"^ ","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ,"^ ","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ," $","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ," $","")

		//extrayendo primer y segundo apellido de apellidos juntos
	cap drop prov4
	gen prov4 = 1 if v7==v9 & v7!="" & wordcount(v7)>=2
	replace Seg_Aplldo = regexs(3) if regexm(Pri_Aplldo,"^([A-ZÑ]+)( )([A-ZÑ]+)")==1 & prov4==1
	replace Pri_Aplldo = regexr(Pri_Aplldo,Seg_Aplldo,"") if regexm(Pri_Aplldo,"^([A-ZÑ]+)( )([A-ZÑ]+)")==1 & prov4==1
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==1
	
		//quitando espacios
	replace Pri_Aplldo = regexr(Pri_Aplldo ,"^ ","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ,"^ ","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ," $","")
	replace Pri_Aplldo = regexr(Pri_Aplldo ," $","")
	replace Seg_Aplldo = regexr(Seg_Aplldo ,"^ ","")
	replace Seg_Aplldo = regexr(Seg_Aplldo ,"^ ","")
	replace Seg_Aplldo = regexr(Seg_Aplldo ," $","")
	replace Seg_Aplldo = regexr(Seg_Aplldo ," $","")
	
		// Solucionando orden para nombre con 3 palabras o menos
	replace prov4 = 2 if prov4==1 & Seg_Aplldo=="" & wordcount(v7)==3
	replace Seg_Aplldo = Pri_Aplldo if prov4==2
	replace Pri_Aplldo = Seg_Nombre if prov4==2
	replace Seg_Nombre = "" if prov4==2
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4!=.
	
	replace prov4 = 3 if prov4==1 & Pri_Aplldo=="" & Seg_Aplldo=="" & wordcount(v7)==2
	replace Pri_Aplldo = Seg_Nombre if prov4==3
	replace Seg_Nombre = "" if prov4==3
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4!=.
	
	drop prov4
	
	* 2. EXTRAYENDO APELLIDOS DE APELLIDOS QUE ESTAN JUNTOS 
	************************************************************
	
	cou if wordcount(Pri_Aplldo)>=2 
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 
	
	cou if wordcount(Pri_Aplldo)>=2  & Seg_Aplldo!="" //La mayoria de estos son DE DEL DE LA 
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 & Seg_Aplldo!=""
	
		// Aquellos que en primer apellido ponen la INICIAL del segundo apellido Y Seg_Aplldo!=""
	cap drop prov4
	gen prov4 = 1 if wordcount(Pri_Aplldo)>=2 & Seg_Aplldo!="" ///
		& substr(Pri_Aplldo,-1,1)==substr(Seg_Aplldo,1,1) & substr(Pri_Aplldo,-2,1)==" "
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==1
	replace Pri_Aplldo = word(Pri_Aplldo,1) if prov4==1

		// Aquellos con algo REPETIDO entre los dos apellidos y Seg_Aplldo!="" 
	replace prov4=2 if wordcount(Pri_Aplldo)>=2  & Seg_Aplldo!="" & strpos(Pri_Aplldo,Seg_Aplldo)>=1
	cou if prov4==2
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==2
	replace Pri_Aplldo=substr(Pri_Aplldo,1,strpos(Pri_Aplldo,Seg_Aplldo)-2) if prov4==2 & length(Pri_Aplldo)!=length(Seg_Aplldo)
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==2
	
	
		// Aquellos con algo Seg_Aplldo=="" 	
	cou if wordcount(Pri_Aplldo)>=2 
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 
	cou if wordcount(Pri_Aplldo)>=2 & prov4!=.
	cou if wordcount(Pri_Aplldo)>=2 & prov4==.
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 & prov4==. 
	
	cou if wordcount(Pri_Aplldo)>=2 & prov4==. & Seg_Aplldo!=""
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 & prov4==. & Seg_Aplldo!=""
	
	cou if wordcount(Pri_Aplldo)>=2 & prov4==. & Seg_Aplldo==""
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if wordcount(Pri_Aplldo)>=2 & prov4==. & Seg_Aplldo==""
	replace prov4=3 if wordcount(Pri_Aplldo)>=2 & prov4==. & Seg_Aplldo==""
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==3
	
		// Aquellos SIN apellido multipalabra
	replace prov4=4 if prov4==3 & wordcount(Pri_Aplldo)==2
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==4
	replace Seg_Aplldo = regexs(3) if regexm(Pri_Aplldo,"^([A-ZÑ]+)( )([A-ZÑ]+)")==1 & prov4==4
	replace Pri_Aplldo = regexs(1) if regexm(Pri_Aplldo,"^([A-ZÑ]+)( )([A-ZÑ]+)")==1 & prov4==4
	
	
		// Aquellos CON apellido multipalabra
	replace prov4=5 if prov4==3 & wordcount(Pri_Aplldo)>=2
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo if prov4==5
	
	cap drop Pri_AplldoP1 // Temporal para hacer los reemplazos en el loop
	gen Pri_AplldoP1 = Pri_Aplldo
		
	local ln0 DE ALBA, DE ALCAZAR, DE ANDREIS, DE ANGULO, DE ARCOS, DE ARCO, DE ARMAS, DE AVILA, DE BEDOUT, DE CARO, DE CASTRO, DE DIEGO, DE FRANCISCO, DE FREITAS, DE HOYOS, DE LEON, DE LIMA, DE LUQUE, DE MARTINO, DE NARVAEZ, DE ORO, DE PABLOS, DE ROUX, DE SALES, DE SOTO, DE VALDENEBRO, DE VARONA, DE VEGA, DE ZUBIRIA, DE LA BARRERA, DE LA CALLE, DE LA CERDA, DE LA CRUZ, DE LA CUESTA, DE LA ESPRIELLA, DE LA GALA, DE LA HORTUA, DE LA HOZ, DE LA OSSA, DE LA PAVA, DE LA PAZ, DE LA PEÑA, DE LA PUENTE, DE LA ROCHE, DE LA ROSA, DE LA TORRE, DE LA VEGA, DE LA VICTORIA, DE LAS SALAS, DE LOS REYES, DE LOS RIOS, DEL BUSTO, DIAZ DEL CASTILLO, DEL CASTILLO, DEL CORRAL , DEL GALLEGO, DEL PINO, DEL PORTILLO, DEL POZO, DEL REAL, DEL RIO, DEL TORO, DEL VALLE, DEL VASTO, DEL VECHIO, DEL VILLAR, DIAZ GRANADOS, FACIO LINCE, FERNANDEZ DE CASTRO, FERNANDEZ DE SOTO, GUTIERREZ DE PIÑERES, LA ROTA, LA ROTTA, LADRON DE GUEVARA, LOPEZ DE MESA, MONTES DE OCA, PONCE DE LEON, SANZ DE SANTAMARIA, SAN JUAN, SAN MARTIN, SAN MIGUEL, D ACHIARDI, D AMATO, D ANDREIS, D ANTONIO, D COSSIO, D COSTA, D CROZ, D HARO, D LUIS, D LUIZ, D ONOFRIO, D PAOLA, D RUGGIERO, DE MOYA, DE ANGEL, DE AGUAS, DEL RISCO, DE VIVERO, DE LA RANS, DEL GUERCIO, DEL CORRAL, DE LA PENA, DE VOZ, DE MARES, D CROZ, DE OSSA, DE ARCE, DE SANTIS, DEL BASTO, DEL HIERRO, DEL PRADO, DE LA SALAS, DE BRIGARD, GUTIERREZ DE PIÑEREZ, GUTIERREZ DE PIÑERES  
	local ln1 "DE ALBA" "DE ALCAZAR" "DE ANDREIS" "DE ANGULO" "DE ARCOS" "DE ARCO" "DE ARMAS" "DE AVILA" "DE BEDOUT" "DE CARO" "DE CASTRO" "DE DIEGO" "DE FRANCISCO" "DE FREITAS" "DE HOYOS" "DE LEON" "DE LIMA" "DE LUQUE" "DE MARTINO" "DE NARVAEZ" "DE ORO" "DE PABLOS" "DE ROUX" "DE SALES" "DE SOTO" "DE VALDENEBRO" "DE VARONA" "DE VEGA" "DE ZUBIRIA" "DE LA BARRERA" "DE LA CALLE" "DE LA CERDA" "DE LA CRUZ" "DE LA CUESTA" "DE LA ESPRIELLA" "DE LA GALA" "DE LA HORTUA" "DE LA HOZ" "DE LA OSSA" "DE LA PAVA" "DE LA PAZ" "DE LA PEÑA" "DE LA PUENTE" "DE LA ROCHE" "DE LA ROSA" "DE LA TORRE" "DE LA VEGA" "DE LA VICTORIA" "DE LAS SALAS" "DE LOS REYES" "DE LOS RIOS" "DEL BUSTO" "DIAZ DEL CASTILLO" "DEL CASTILLO" "DEL CORRAL " "DEL GALLEGO" "DEL PINO" "DEL PORTILLO" "DEL POZO" "DEL REAL" "DEL RIO" "DEL TORO" "DEL VALLE" "DEL VASTO" "DEL VECHIO" "DEL VILLAR" "DIAZ GRANADOS" "FACIO LINCE" "FERNANDEZ DE CASTRO" "FERNANDEZ DE SOTO" "GUTIERREZ DE PIÑERES" "LA ROTA" "LA ROTTA" "LADRON DE GUEVARA" "LOPEZ DE MESA" "MONTES DE OCA" "PONCE DE LEON" "SANZ DE SANTAMARIA" "SAN JUAN" "SAN MARTIN" "SAN MIGUEL" "D ACHIARDI" "D AMATO" "D ANDREIS" "D ANTONIO" "D COSSIO" "D COSTA" "D CROZ" "D HARO" "D LUIS" "D LUIZ" "D ONOFRIO" "D PAOLA" "D RUGGIERO" "DE MOYA" "DE ANGEL" "DE AGUAS" "DEL RISCO" "DE VIVERO" "DE LA RANS" "DEL GUERCIO" "DEL CORRAL" "DE LA PENA" "DE VOZ" "DE MARES" "D CROZ" "DE OSSA" "DE ARCE" "DE SANTIS" "DEL BASTO" "DEL HIERRO" "DEL PRADO" "DE LA SALAS" "DE BRIGARD" "GUTIERREZ DE PIÑEREZ" "GUTIERREZ DE PIÑERES"
	local nv : word count "`ln1'" //Counting the number of lastnames in the list
	di `nv'
	local i = 1
	local j = 1	
	while `i'<=(2*`nv')-1{ // Loop que reemplaza NoAplldSiNom=. si apellido hace parte del local ln0 a fin de desmarcarlo para ser borrado.
					   // Si no aparece en esta lista, adiciona este apellido a la base. Esto ultimo puede pasar si es un apellido poco comun ya que solo se consideran apellidos con dup>=2
		gettoken t ln0 : ln0, parse(",")
		if "`t'"!=","{
			dis "`t' is the `j'-th lastname"
			*replace prov_mp=2 if regexm(Pri_Aplldo,"`t'")==1 //Reemplazandolo para no borrarlo despues
				//Separando estos apellidos cuando tienen otro apellido mas en el mismo campo
			replace Pri_Aplldo = regexs(1) if regexm(Pri_AplldoP1,"^(`t')(.*)")==1 & prov4==5 // Si apellido compuesto aparece primero, se deja y se quita el otro
			replace Seg_Aplldo = regexs(2) if regexm(Pri_AplldoP1,"^(`t')(.*)")==1  & prov4==5  
			replace Pri_Aplldo = regexs(1) if regexm(Pri_AplldoP1,"^([A-ZÑ]+[ ]*)(`t')")==1 & prov4==5  // Si apellido compuesto aparece de segundo, se quita y se deja el primero
			replace Seg_Aplldo = regexs(2) if regexm(Pri_AplldoP1,"^([A-ZÑ]+[ ]*)(`t')")==1 & prov4==5
			local i = `i'+1
			local j = `j'+1
			}
		else{
			local i = `i'+1
			}
		}
	
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo* Seg_Aplldo if prov4==5
	cap drop Pri_AplldoP1
	cap drop prov4
	
	
	// Apellidos multi-palabra que quedan mal separados
	
	cou if regexm(Pri_Aplldo," DE$")==1 | regexm(Pri_Aplldo," DEL$")==1 | regexm(Pri_Aplldo," DE LA$")==1 | regexm(Pri_Aplldo," DE LOS$")==1 
	*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo* Seg_Aplldo if regexm(Pri_Aplldo," DE$")==1 | regexm(Pri_Aplldo," DEL$")==1 | regexm(Pri_Aplldo," DE LA$")==1 | regexm(Pri_Aplldo," DE LOS$")==1 
	//Muy pocos. No se hace nada
	
	
		*ed  v7 v8 v9 v10  Pri_Nombre Seg_Nombre Pri_Aplldo Seg_Aplldo 
	
	