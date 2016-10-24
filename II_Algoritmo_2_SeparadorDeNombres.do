

* II. SEPARANDO PRIMER Y SEGUNDO NOMBRES Y APPELLIDOS
**************************************************************************************


/*
cap drop Pri_Nombre_p
gen Pri_Nombre_p = Pri_Nombre
cap drop Seg_Nombre_p
gen Seg_Nombre_p = Seg_Nombre
*/

/*
replace Pri_Nombre = Pri_Nombre_p
replace Seg_Nombre = Seg_Nombre_p
*/

* 0. Quitando "DE DEL DE LA DE LOS PARA FACILITAR EL CRUCE POR NOMBRES"

		// Juntando Primer y segundo Nombre en una variable para eliminar repeticiones: Pri_Nombre="Maria del" Seg_Nombre="del Pilar"
	cap drop Pri_Seg_Nom
	gen Pri_Seg_Nom = Pri_Nombre + " " + Seg_Nombre
	replace Pri_Seg_Nom= subinstr(Pri_Seg_Nom," DE LAS DE LAS "," DE LAS ",1) 
	replace Pri_Seg_Nom= subinstr(Pri_Seg_Nom," DE LOS DE LOS "," DE LOS ",1) 
	replace Pri_Seg_Nom= subinstr(Pri_Seg_Nom," DE LA DE LA "," DE LA ",1) 
	replace Pri_Seg_Nom= subinstr(Pri_Seg_Nom," DEL DEL "," DEL ",1) 
	replace Pri_Seg_Nom= subinstr(Pri_Seg_Nom," DE DE "," DE ",1) 
	
	replace Pri_Nombre = regexs(1) if regexm(Pri_Seg_Nom,"^([A-ZÑ]+)([ ])(.*)")==1 
	replace Seg_Nombre = regexs(3) if regexm(Pri_Seg_Nom,"^([A-ZÑ]+)([ ])(.*)")==1 
	drop Pri_Seg_Nom
	
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre 
	

		// Separando los DELROSARIO a DEL ROSARIO para hacer un mejor trabajo despues en separar nombres 
	foreach k of varlist Pri_Nombre Seg_Nombre{  
		replace `k'= regexr(`k',"DEJES[AU]S"," DE JESUS ")
		replace `k'= regexr(`k',"DEJES "," DE JESUS ")
		replace `k'= regexr(`k',"DEJES$"," DE JESUS ")
		replace `k'= regexr(`k',"DE JES "," DE JESUS ")
		replace `k'= regexr(`k',"DE JES$"," DE JESUS ")
		replace `k'= regexr(`k',"DE JE "," DE JESUS ")
		replace `k'= regexr(`k',"DE JE$"," DE JESUS ")
		replace `k'= regexr(`k',"DEDI[AO]S"," DE DIOS ")
		
		replace `k'= regexr(`k',"DELCARMEN"," DEL CARMEN ")
		replace `k'= regexr(`k',"DELCAR "," DEL CARMEN ")
		replace `k'= regexr(`k',"DELCAR$"," DEL CARMEN ")
		replace `k'= regexr(`k',"DEL CAR "," DEL CARMEN ")
		replace `k'= regexr(`k',"DEL CAR$"," DEL CARMEN ")
		replace `k'= regexr(`k',"DELCA "," DEL CARMEN ")
		replace `k'= regexr(`k',"DELCA$"," DEL CARMEN ")
		replace `k'= regexr(`k',"DEL CA "," DEL CARMEN ")
		replace `k'= regexr(`k',"DEL CA$"," DEL CARMEN ")
		
		replace `k'= regexr(`k',"DELMAR "," DEL MAR ")
		replace `k'= regexr(`k',"DEL MA "," DEL MAR ")
		replace `k'= regexr(`k',"DEL MA$"," DEL MAR ")
		
		replace `k'= regexr(`k',"DELPILAR"," DEL PILAR ")
		replace `k'= regexr(`k',"DELPIL "," DEL PILAR ")
		replace `k'= regexr(`k',"DELPIL$"," DEL PILAR ")
		replace `k'= regexr(`k',"DEL PIL "," DEL PILAR ")
		replace `k'= regexr(`k',"DEL PIL$"," DEL PILAR ")
		replace `k'= regexr(`k',"DEL PI "," DEL PILAR ")
		replace `k'= regexr(`k',"DEL PI$"," DEL PILAR ")
		replace `k'= regexr(`k',"DEL P "," DEL PILAR ")
		replace `k'= regexr(`k',"DEL P$"," DEL PILAR ")
		
		replace `k'= regexr(`k',"DELROC[AI]O"," DEL ROCIO ")
		replace `k'= regexr(`k',"DELROC "," DEL ROCIO ")
		replace `k'= regexr(`k',"DELROC$"," DEL ROCIO ")
		replace `k'= regexr(`k',"DEL ROC "," DEL ROCIO ")
		replace `k'= regexr(`k',"DEL ROC$"," DEL ROCIO ")
		
		replace `k'= regexr(`k',"DELROSARIO"," DEL ROSARIO ")
		
		replace `k'= regexr(`k',"DELROS "," DEL ROSARIO ")
		replace `k'= regexr(`k',"DELROS$"," DEL ROSARIO ")
		replace `k'= regexr(`k',"DEL ROS "," DEL ROSARIO ")
		replace `k'= regexr(`k',"DEL ROS$"," DEL ROSARIO ")
		
		replace `k'= regexr(`k',"DELSOCORRO"," DEL SOCORRO ")
		replace `k'= regexr(`k',"DELSOC "," DEL SOCORRO ")
		replace `k'= regexr(`k',"DELSOC$"," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL SOC "," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL SOC$"," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL SO "," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL SO$"," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL S "," DEL SOCORRO ")
		replace `k'= regexr(`k',"DEL S$"," DEL SOCORRO ")
		
		replace `k'= regexr(`k',"DELOSANGELES"," DE LOS ANGELES ")
		replace `k'= regexr(`k',"DELOSANG "," DE LOS ANGELES ")
		replace `k'= regexr(`k',"DELOSANG$"," DE LOS ANGELES ")
		replace `k'= regexr(`k',"DE LOS ANG "," DE LOS ANGELES ")
		replace `k'= regexr(`k',"DE LOS ANG$"," DE LOS ANGELES ")
		
		replace `k'= regexr(`k',"DELACONCEPCI[AO]N"," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DELACON "," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DELACON$"," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DE LA CON "," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DE LA CON$"," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DELAC "," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DELAC$"," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DE LA C "," DE LA CONCEPCION")
		replace `k'= regexr(`k',"DE LA C$"," DE LA CONCEPCION")
		
		replace `k'= regexr(`k',"DELASMERCEDES"," DE LAS MERCEDES")
		replace `k'= regexr(`k',"DELASMER "," DE LAS MERCEDES")
		replace `k'= regexr(`k',"DELASMER$"," DE LAS MERCEDES")
		replace `k'= regexr(`k',"DE LAS MER "," DE LAS MERCEDES")
		replace `k'= regexr(`k',"DE LAS MER$"," DE LAS MERCEDES")
		replace `k'= regexr(`k',"DELAPAZ"," DE LA PAZ")
		replace `k'= regexr(`k',"DE LA PA "," DE LA PAZ")
		replace `k'= regexr(`k',"DE LA PA$"," DE LA PAZ")
		
		replace `k'= regexr(`k'," DELOS "," DE LOS ")   
		replace `k'= regexr(`k'," DELAS "," DE LAS ")
		replace `k'= regexr(`k'," DELA "," DE LA ")
		
		replace `k'= subinstr(`k', "  ", " ",10)
		replace `k'= regexr(`k', "^[ ]", "")
		replace `k'= regexr(`k', "[ ]$", "")
		replace `k'= `k'+" "  //Este paso ayuda a identificar NOMBRES QUE TERMINAN EN INICIALES EN EL SIGUIENTE LOOP
	}	
	
		
		// Borrando "DE DEL DE LA DE LOS"
	cap drop prov1
	gen prov1 = . 
	foreach k of varlist Pri_Nombre Seg_Nombre{  
	
		replace prov1 = 1 if regexm(`k',"([ ]+)DE LAS([ ])M([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DE LAS([ ])M([ ])$"," MERCEDES ")
				replace `k'= regexr(`k',"^DE LAS([ ])M([ ])$"," MERCEDES ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DE LAS([ ])")==1 
				replace `k'= regexr(`k',"([ ]+)DE LAS([ ])"," ") 	
		replace prov1 = 1 if regexm(`k',"^DE LAS([ ])")==1 
				replace `k'= regexr(`k',"^DE LAS([ ])"," ") 				
			
		replace prov1 = 1 if regexm(`k',"([ ]+)DE LOS([ ])A([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DE LOS([ ])A([ ])$"," ANGELES ") 
				replace `k'= regexr(`k',"^DE LOS([ ])A([ ])$"," ANGELES ") 
		replace prov1 = 1 if regexm(`k',"([ ]+)DE LOS([ ])")==1 
				replace `k'= regexr(`k',"([ ]+)DE LOS([ ])"," ")
		replace prov1 = 1 if regexm(`k',"^DE LOS([ ])")==1 
				replace `k'= regexr(`k',"^DE LOS([ ])"," ")			
				
		replace prov1 = 1 if regexm(`k',"([ ]+)DE LA([ ])")==1 
				replace `k'= regexr(`k',"([ ]+)DE LA([ ])"," ")			
		replace prov1 = 1 if regexm(`k',"^DE LA([ ])")==1 
				replace `k'= regexr(`k',"^DE LA([ ])"," ")
				
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])C([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])C([ ])$"," CARMEN ")
				replace `k'= regexr(`k',"^DEL([ ])C([ ])$"," CARMEN ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])PI([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])PI([ ])$"," PILAR ")
				replace `k'= regexr(`k',"^DEL([ ])PI([ ])$"," PILAR ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])P([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])P([ ])$"," PILAR ")
				replace `k'= regexr(`k',"^DEL([ ])P([ ])$"," PILAR ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])R([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])R([ ])$"," ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])S([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])S([ ])$"," SOCORRO ")
				replace `k'= regexr(`k',"^DEL([ ])S([ ])$","  SOCORRO ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DEL([ ])")==1 
				replace `k'= regexr(`k',"([ ]+)DEL([ ])"," ")
		replace prov1 = 1 if regexm(`k',"^DEL([ ])")==1 
				replace `k'= regexr(`k',"^DEL([ ])"," ")
				
		replace prov1 = 1 if regexm(`k',"([ ]+)DE([ ])JE([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DE([ ])JE([ ])$"," JESUS ")
				replace `k'= regexr(`k',"^DE([ ])JE([ ])$"," JESUS ")				
		replace prov1 = 1 if regexm(`k',"([ ]+)DE([ ])J([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DE([ ])J([ ])$"," JESUS ")
				replace `k'= regexr(`k',"^DE([ ])J([ ])$"," JESUS ")
				
		replace prov1 = 1 if regexm(`k',"([ ]+)DE([ ])D([ ])$")==1 
				replace `k'= regexr(`k',"([ ]+)DE([ ])D([ ])$"," ")
		replace prov1 = 1 if regexm(`k',"([ ]+)DE([ ])")==1 
				replace `k'= regexr(`k',"([ ]+)DE([ ])"," ")
		replace prov1 = 1 if regexm(`k',"^DE([ ])")==1 
				replace `k'= regexr(`k',"^DE([ ])"," ")
		
		replace `k'= regexr(`k', "  ", " ")
		replace `k'= regexr(`k', "^[ ]", "")
		replace `k'= regexr(`k', "[ ]$", "")
	
	}
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre if prov1==1
	
	
	
	
	// Algunos nombres de los de "DE DEL DE LA DE LOS" estanban en el primer nombre sin espacios (MARIADELPILAR) y quedaron ambos en el primer nombre
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre if regexm(Pri_Nombre,"^([A-ZÑ]+)([ ]+)(.+)")==1
	cap drop prov2
	gen prov2 = 1 if regexm(Pri_Nombre,"^([A-ZÑ]+)([ ]+)(.+)")==1
	replace Seg_Nombre = regexs(3) if regexm(Pri_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 & prov2==1
	replace Pri_Nombre = regexs(1) if regexm(Pri_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 & prov2==1
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre if prov2==1

	// Algunos nombres de los de "DE DEL DE LA DE LOS" estanban en el segundo nombre sin espacios (MARIADELPILAR) y quedaron ambos en el segundo nombre
	*ed v7 v8 v9 v10 Pri_Nombre Seg_Nombre if regexm(Seg_Nombre,"^([A-ZÑ]+)([ ]+)(.+)")==1
	
	
		
* 1. Creando Tercer y Cuartos nombres para borrar repetidos

	cap drop Ter_Nombre
	gen Ter_Nombre = regexs(3) if regexm(Seg_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 
	
	cap drop Qto_Nombre
	gen Qto_Nombre = regexs(3) if regexm(Ter_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 
	
	replace Seg_Nombre = regexs(1) if regexm(Seg_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 
	replace Ter_Nombre = regexs(1) if regexm(Ter_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1 
	
	*ed v7 v8 v9 v10 *_Nombre if (regexm(v7,"^([A-ZÑ]+)([ ])(.*)")==1 | regexm(v8,"^([A-ZÑ]+)([ ])(.*)")==1)
	*ed v7 v8 v9 v10 *_Nombre if  Qto_Nombre!=""
	
	
		//Borrando Nombres que son repetidos
	*ed v7 v8 v9 v10 *_Nombre if Ter_Nombre==Qto_Nombre & Qto_Nombre!=""
	
	*ed v7 v8 v9 v10 *_Nombre if Seg_Nombre==Ter_Nombre & Ter_Nombre!=""
	replace Ter_Nombre="" if Seg_Nombre==Ter_Nombre & Ter_Nombre!=""
	
	*ed v7 v8 v9 v10 *_Nombre if Pri_Nombre==Seg_Nombre & Seg_Nombre!=""
	replace Seg_Nombre="" if Pri_Nombre==Seg_Nombre & Seg_Nombre!=""
	
	
* 2. Algunos tienen solo la inicial 
	*ed v7 v8 *_Nombre if regexm(Pri_Nombre,"^[A-ZÑ]$")==1
	cap drop prov3
	gen prov3 = 1 if regexm(Pri_Nombre,"^[A-ZÑ]$")==1
	replace Pri_Nombre=Seg_Nombre if prov3==1 & Seg_Nombre!=""
	replace Seg_Nombre=Ter_Nombre if prov3==1 & Ter_Nombre!=""
	replace Ter_Nombre=Qto_Nombre if prov3==1 & Qto_Nombre!=""
	*ed v7 v8 *_Nombre if prov3==1
	
		// Note que hay muchos con Inicial "O" o "X". Se borran
	*ed v7 v8 *_Nombre if regexm(Seg_Nombre,"^[A-ZÑ]$")==1
	tab Seg_Nombre if regexm(Seg_Nombre,"^[A-ZÑ]$")==1 
	replace Seg_Nombre = regexr(Seg_Nombre,"^[OX]$","") 
	tab Seg_Nombre if regexm(Seg_Nombre,"^[A-ZÑ]$")==1 
	
	*ed v7 v8 *_Nombre if regexm(Ter_Nombre,"^[A-ZÑ]$")==1
	tab Ter_Nombre if regexm(Ter_Nombre,"^[A-ZÑ]$")==1 
	
	*ed v7 v8 *_Nombre if regexm(Qto_Nombre,"^[A-ZÑ]$")==1
	tab Qto_Nombre if regexm(Qto_Nombre,"^[A-ZÑ]$")==1 
	
	format %50s *_Nombre
	
		// Revisando que en cada nombre haya maximo un nombre excepto en Qto_Nombre
		// RESOLVER problema de nombres originalmente sin espacios JUANDIEGO ...
		// o mal separados JU AN. Esto ultimo puede ocurrir tanto en la misma variable Pri_Nombre="JU AN" o en dos
		// Pri_Nombre="JU" Seg_Nombre="AN DIEGO"
		
	*ed v7 v8 v9 v10 *_Nombre if regexm(Pri_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1
	*ed v7 v8 v9 v10 *_Nombre if regexm(Seg_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1
	*ed v7 v8 v9 v10 *_Nombre if regexm(Ter_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1
	*ed v7 v8 v9 v10 *_Nombre if regexm(Qto_Nombre,"^([A-ZÑ]+)([ ])(.*)")==1
	
	
		// Revisando registros con varios nombres en los campos v7 (primer nombre) v8 (segundo nombre)
	*ed v7 v8 v9 v10 *_Nombre if regexm(v7,"^([A-Z]+)([ ])(.*)")==1 | regexm(v8,"^([A-Z]+)([ ])(.*)")==1
	*ed v7 v8 v9 v10 *_Nombre if (regexm(v7,"^([A-Z]+)([ ])(.*)")==1 | regexm(v8,"^([A-Z]+)([ ])(.*)")==1) & Ter_Nombre!=""
	
	
	
	
	
