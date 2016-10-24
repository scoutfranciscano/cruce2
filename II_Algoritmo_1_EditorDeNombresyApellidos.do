


***********************
* I. AJUSTES INICIALES 
***********************

* 1. Todos los nombres en mayusculas
	*cap drop NameProv 
	*gen NameProv = upper(v7)
	*cou if v7!=NameProv // cuenta los reemplazos de minusculas a mayusculas
	**ed v7 NameProv if v7!=NameProv

* 2. Quitando las tildes
	*replace NameProv= regexr(NameProv,"¡","A") //otra manera de hacerlo
	replace NameProv= subinstr(NameProv,"¡","A",5)
	replace NameProv= subinstr(NameProv,"¿","A",5)
	replace NameProv= subinstr(NameProv,"·","A",5)
	replace NameProv= subinstr(NameProv,"‡","A",5)

	replace NameProv= subinstr(NameProv,"…","E",5)
	replace NameProv= subinstr(NameProv,"»","E",5)
	replace NameProv= subinstr(NameProv,"È","E",5)
	replace NameProv= subinstr(NameProv,"Ë","E",5)

	replace NameProv= subinstr(NameProv,"Õ","I",5)
	replace NameProv= subinstr(NameProv,"Ã","I",5)
	replace NameProv= subinstr(NameProv,"Ì","I",5)
	replace NameProv= subinstr(NameProv,"Ï","I",5)

	replace NameProv= subinstr(NameProv,"”","O",5)
	replace NameProv= subinstr(NameProv,"“","O",5)
	replace NameProv= subinstr(NameProv,"Û","O",5)
	replace NameProv= subinstr(NameProv,"Ú","O",5)

	replace NameProv= subinstr(NameProv,"⁄","U",5)
	replace NameProv= subinstr(NameProv,"Ÿ","U",5)
	replace NameProv= subinstr(NameProv,"‹","U",5)
	replace NameProv= subinstr(NameProv,"˙","U",5)
	replace NameProv= subinstr(NameProv,"˘","U",5)
	replace NameProv= subinstr(NameProv,"¸","U",5)
	
	replace NameProv= subinstr(NameProv,"-"," ",244)
	replace NameProv= subinstr(NameProv,"*","",244)
	replace NameProv= subinstr(NameProv,"ø","",244)
	replace NameProv= subinstr(NameProv,"_","",244)
	
	
	replace NameProv = "ZU—IGA" if NameProv=="Z&Uacute;&Ntilde;IGA"
	
		// Tildes escritas como acute o grave	
	*ed NameProv if regexm(NameProv,"&")==1
	*ed if regexm(NameProv,"^([A-Z]*[ ]*[A-Z]*)(&)([AEIOU])(ACUTE;)([A-Z]*[ ]*)")==1
	replace NameProv=regexs(1)+regexs(3)+regexs(5) if regexm(NameProv,"^([A-Z]*[ ]*[A-Z]*)(&)([AEIOU])(ACUTE;)([A-Z]*[ ]*)")==1
	replace NameProv=regexs(1)+regexs(3)+regexs(5) if regexm(NameProv,"^([A-Z]*[ ]*[A-Z]*)(&)([AEIOU])(GRAVE;)([A-Z]*[ ]*)")==1
	
		// — escrita como acute		
	*ed NameProv if regexm(NameProv ,"&[N]tilde;")==1
	replace NameProv=regexs(1)+"—"+regexs(5) if regexm(NameProv,"^([A-Z]*[ ]*[A-Z]*)(&)([N])(TILDE;)([A-Z]*[ ]*)")==1
	
		// Otros Acute
	*ed if regexm(NameProv,"&")==1 & regexm(NameProv,"&[AEIOU]acute;")==0 & regexm(NameProv,"&ntilde;")==0
	replace NameProv=subinstr(NameProv,"&SQUO","",3)
		
	
* 3. Cambiando ceros que parecen O
	replace NameProv= subinstr(NameProv,"0","O",10)

* 4. Reemplazando la — (Solo la minuscula)
	replace NameProv= subinstr(NameProv,"Ò","—",10)

* 5. Reemplazando en primer nombre registros claramente errados
	replace NameProv =  "" if regexm(NameProv,"^NULL")==1
	replace NameProv =  "" if regexm(NameProv,"^NOMBRE")==1
	replace NameProv =  "" if regexm(NameProv,"^NOM1")==1
	replace NameProv =  "" if regexm(NameProv,"^NOM")==1
	replace NameProv =  "" if regexm(NameProv,"^APELLIDO")==1
	replace NameProv =  "" if regexm(NameProv,"^APELL1")==1
	replace NameProv =  "" if regexm(NameProv,"^APELL2")==1
	replace NameProv =  "" if regexm(NameProv,"^APELL")==1
		

* 6. Quitando caracteres adicionales que no tienen que ver con tildes	
	local ctrs , ' ` ^ ~ ∫ ¨ / π ≤ ≥ 1 2 3 4 5 6 7 8 9
	foreach v of local ctrs{
		gettoken u ctrs : ctrs
		dis "`u'"
		replace NameProv= subinstr(NameProv,"`v'","", 5)	
	}
	*
	
* 7. Quitando ¬ inicial seguida de espacio al principio y al final (Problema no muy frecuente pero facil de solucionar)
	
	replace NameProv= regexr(NameProv,"^¬†","") // Nota: como es importante el espacio para identificar estos registros (de lo contraio borra a ¬lvaro)
												// la instruccion de quitar los espacios y hacer trimming debe ir despues
	replace NameProv= regexr(NameProv,"¬†$","")

	
* 8. Quitando espacios en blanco (A veces no sirve trim() pq el tamano de los espacios no es estandar)
	replace NameProv = trim(NameProv) // A veces no funciona - usar siguiente grupo de instrucciones
	cou if regexm(NameProv,"  ")==1 // Estos son los que se reemplazan en el loop que sigue
	**ed v7 NameProv if regexm(NameProv,"  ")==1 // Espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",100) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"†"," ",100)
	replace NameProv = trim(NameProv) // A veces no funciona - usar siguiente grupo de instrucciones
	
	/*foreach x of numlist 1/30{
		replace NameProv = regexr(NameProv,"  "," ") // Espacios dobles
		}*/
	
	replace NameProv = regexs(2) if regexm(NameProv,"^([ ]+)(.*)")==1 // Espacio al inicio
	replace NameProv = regexs(1) if regexm(NameProv,"(.*)([ ]+)$")==1 // Espacios al final


	*cou if regexm(NameProv,char(129))==1 // Los caracteres 129, 141, 160 son espacios en blanco de tamano no estandar (por eso no sirve el trim)
	replace NameProv= subinstr(NameProv,char(129),"",30)
	replace NameProv= subinstr(NameProv,char(141),"",30)
	replace NameProv= subinstr(NameProv,char(160),"",30)
	*replace NameProv= regexr(NameProv,char(160),"")
	

	
	
	
*****************************************************************	
* II. ESTA PARTE ENCUENTRA LOS REGISTROS CON CARACTERES EXTRANOS 
*     (Usualmente son tildes mal leidas por el programa)
*****************************************************************

* 1. Identificando los registros con caracteres extranos 
********************************************************** 
	
	* Los siguientes son los caracteres que NO se buscan porque: 1. Son Mayusculas; 2. son caracteres de expresiones regulares; 3. son —
	* 32=space; 36=$; 40=(; 41=); 42=*; 43=+; 46=.; 48-57=0-9; 63=?; 65-90=A-Z; 91=[; 92=\; 93=]; 94=^;
	* 124=|; 209=—; 241=Ò
	* NOTA: Coddigos despues del 127 varian con el codepage y por tanto los resultados pueden variar entre computadores
	* Ejemplo: A veces la (Ò=164, —=165) y a veces es (Ò=241, —=209). (Nota: Deje el 164-165 porque no reemplaza 
	* "•" que es char(165) pese a que siempre es —)
	
	
	local j1 ( ) * + . ? [ ] ^ | , \
	foreach j2 of local j1{
		replace NameProv= subinstr(NameProv,"`j2'","",5)
	}
	
	replace NameProv= subinstr(NameProv,char(164),"—",5)
	replace NameProv= subinstr(NameProv,char(165),"—",5)
	
		
		// ALTERNATIVA DE LOOP 1: 
		***************************
		// Este loop identifica los caracteres extranos pero es muy ineficiente: Se demora 10 minutos pq el loop es sobre carateres extranos
	*foreach y of numlist 1/31 33/35 37/39 44/45 47 58/62 64 95/123 125/163 166/208 210/240 242/255{
	*	local z = char(`y')
	*	dis "The ASCII Character `y' is"
	*	dis "`z'"
	*	cou if regexm(NameProv,char(`y'))==1
	*	replace NameProv= subinstr(NameProv,char(`y'),"XYZ`y'",5) // Igual al de abajo PERO el 5 es por si se repite hasta 5 veces el caracter extrano en el campo
	*	*replace NameProvp= regexr(NameProvp,char(`y'),"XYZ`y'")  // Truco para hallar caracter ascii extrano. 
																  // Activar solo en esos casos. Ex. Cual es el ASCII de un espacio no estandar? 
																  // Asi encontre los char(129), char(141), char(160) que corregi en la seccion I.2	
	*	}
		
	*replace NameProv= subinstr(NameProv,char(`y'),"XYZ`y'",5)
	
	
		// ALTERNATIVA DE LOOP 2
	   ***************************
	   // Correr el siguiente loop y luego hacer copy/paste aqui abajo para tener todos los posibles caracteres problematicos
	   // Se excluyen el 34 porque confunde al local, al igual que las letras mayusculas y minusculas (ya que no son caracteres problematicos)
	   // Tambien se excluye Y minuscula con dieresis (ultimo caracter extrano) pq hace terminar el programa por alguna razon 
	   // Al resultado final se le debe quitar la — a fin de que el algortimo no lo identifique como caracter extrano		  
		*foreach i of numlist 1/33 35/64 93/254{
		/*foreach i of numlist 1/33 35/254{
				local y1 = char(`i')
				local y = "`y1'"
				local codestrext "`codestrext'`y'"
			}
		dis "`codestrext'"	//Copy/paste este display. Reemplazo Caracteres No extranos por # para que la posicion del caracter sea igual al codigo ascii 
		*/
	
/*
	local codestrext "################################!##$%&'()*+,-./0123456789:;<=>?@##########################[\]^_`##########################{|}~ÄÅÇÉÑÖÜáàâäãåçé èëíìîïñóòôöõúùûü†°¢£§•¶ß®©™´¨≠ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–#“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛#"
	dis "`codestrext'"
	/*local i = 1
	while `i'<=255{ //Loop ayuda a revisar si el orden de los caracteres coincide con codigo ascii. Usar "dis char(numero)" para verificar
		local x = substr("`codestrext'",`i',1)
		dis "`x' is the `i'-th ascii"
		local i = `i'+1
	}
	dis "`codestrext'"
	*/
	
	
	tempvar g work Icrtxt code vlen
	gen str1 `g'=""
	gen str1 `work'=""
	gen str1 `code'=""
	gen byte `Icrtxt'=.
	gen byte `vlen'=length(NameProv)
	sum `vlen', meanonly
	local maxvlen=r(max)
		
		forvalues i=1/`maxvlen' {
			replace `work'=upper(substr(NameProv,`i',1)) 		//Convierte todo a mayusculas y evalua cada caracter de la variable de interes
			replace `code'=string(index("`codestrext'",`work'))	// Captura el codigo numerico del caracter extrano
			replace `Icrtxt'= (index("`codestrext'",`work')>=1) // Variable indicadora: 1 si el caracter evaluado en work aparace en el local de caracteres extranos 
			replace `g'=`g'+ `work' if `Icrtxt'==0 				// Si el caracter no es extrano, se deja el mismo.
			replace `g'=`g'+ "XYZ" + `code' if `Icrtxt'==1 & `code'!="1" // Cuando tiene caracter extrano lo reemplaza por XYZ+ascii code para identificarlo despues
																		// work2!="1" es pq char(1) correponde a no tener espacio al final de la variable y si no se 
																		// excluye crea muchos XYX1 al final de g 													    														   
		}
		replace NameProv = `g'
	
*/	
	
		// ALTERNATIVA DE LOOP 3
	   ***************************
		// Utiliza el comando charlist para identidicar los caracteres extranos en la base que se este leyendo. Ventaja: No se requiere especificar un listado de caracteres extranos
		// El loop es sobre los caracteres extranos hallados. Luego es un loop mas corto. 
		// Igualmente, solo se hace replace una ves para cada iteracion, lo que agiliza el proceso
	
	
	
	replace NameProv= subinstr(NameProv,"`"," ",10) // Este es el caracter que no deja correr el charlist completo
	replace NameProv= subinstr(NameProv,"{","",10) // Quitando [ para usarla despues como parantesis el numero ascii del caracter extrano
	*replace NameProv= subinstr(NameProv,"}","",10) // Quitando ] para usarla despues como parantesis el numero ascii del caracter extrano
	replace NameProv= subinstr(NameProv,"0","O",10) // Se quitan los numeros aqui arriba para poder incluirlo abajo en strpos ya que si no borraria los codigos ascii que se van reemplazando
	replace NameProv= subinstr(NameProv,"1","",10)
	replace NameProv= subinstr(NameProv,"2","",10)
	replace NameProv= subinstr(NameProv,"3","",10)
	replace NameProv= subinstr(NameProv,"4","",10)
	replace NameProv= subinstr(NameProv,"5","",10)
	replace NameProv= subinstr(NameProv,"6","",10)
	replace NameProv= subinstr(NameProv,"7","",10)
	replace NameProv= subinstr(NameProv,"8","",10)
	replace NameProv= subinstr(NameProv,"9","",10)
	
	
	charlist NameProv
	local ctrs "`r(sepchars)'" 	// Todos los caracteres (buenos [0-9] y malos [resto]) del documento de identidad 
	local nctrs : list sizeof local(ctrs) // Nro. total de caracteres extranos: determina el final del while
	local asc1 "`r(ascii)'" 	// Local con los codigos ascii de los caracteres extranos
	local asc2 "`r(ascii)'"		// Se crean 2 locals iguales para solucionar el tema de char(32)=" " 
	local nasc : list sizeof local(asc1) // Se cuenta el numero de codigos ascii para garantizar que es igual al numero de caracteres extranos
	
	display "`ctrs'"
	display "`nctrs' elementos"
	display "`asc1"'
	display "`nascii' elementos"
	
	local i = 1
	while `i'<=`nctrs'{		
	gettoken z asc1 : asc1
		if `z'==32{ // Si es un espacio estandar, continuar al siguiente elemento de asc2
			gettoken v asc2 : asc2
			local i = `i'+1
		}
		else{
			gettoken v asc2 : asc2
			gettoken u ctrs : ctrs
			*dis "this is `u' with ascii code = `v'"
			if strpos("ABCDEFGHIJKLMN—OPQRSTUVWXYZ{1234567890","`u'")==0{ //Para todos los caracteres con excepcion de los numeros:	
				replace NameProv= subinstr(NameProv,"`u'","{`v'",5) // Reemplaza los caracteres extranos por [CODIGO_ASCII] 
			}		
			local i = `i'+1
		}
	}	
	replace NameProv = subinstr(NameProv,"{","XYZ",30)

	
	
	
* 2. Reemplazando esos caracteres extranos por una vocal cualquiera. Soundex despues soluciona el problema	
************************************************************************************************************	
	
	
	/*
	*ed v7 NameProv work* code g  if CrtExtPN==1 	
	*ed v7 NameProv work code g if regexm(NameProv,"XYZ")==1	& CrtExtPN==1 
	*ed v7 NameProv work code g if regexm(NameProv,"XYZ")==0	& CrtExtPN==1
	cou if regexm(NameProv,"XYZ")==1	
	*ed v7 NameProv work code g if regexm(NameProv,"XYZ")==1
	*/

	
	cap drop CrtExt // Variable para identificar caracteres extranos
	gen CrtExt = .
	replace CrtExt = 1 if regexm(NameProv,"XYZ")==1
	cou if regexm(NameProv,"([.]*)XYZ")==1
	**ed  v7 NameProv CrtExt if CrtExt == 1

	
	* Contando numero de caracteres extranos en la variable
	cap drop q_xyz
	gen q_xyz = (length(NameProv) - length(subinstr(NameProv, "XYZ", "",.))) / length("XYZ") 
	**ed  v7 NameProv CrtExt q_xyz if CrtExt == 1
	
	*sum q_xyz
	*local a = `r(max)'
	*dis "`a'"
	
	* reemplazanco caracter " " por espacio (JUAN DIEGO)
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ143")==1
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ143")==1 & regexm(NameProv,"XYZ[02][0-35-9][0-24-9]")==1  
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ143")==1 & regexm(NameProv,"XYZ[02][0-35-9][0-24-9]")==0  
	replace CrtExt=. if regexm(NameProv,"XYZ143")==1 & regexm(NameProv,"XYZ[02][0-35-9][0-24-9]")==0  
			// Se reemplazan crtrxt para que no aparezca como caracter extrano cuando no lo es ya mas
	replace NameProv= subinstr(NameProv,"XYZ143"," ",10)
		
	* reemplazanco caracter "-" por espacio (JUAN-DIEGO)
	**ed  v7 NameProv CrtExt q_xyz if regexm(v7,"-")==1
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ45")==1
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ45")==1 & regexm(NameProv,"XYZ[012][0-35-9][0-46-9]")==1  
	replace NameProv= subinstr(NameProv,"XYZ45"," ",10)
	
	* reemplazanco caracter "-" por Vacio (MAR√-A)
	*ed  v7 NameProv CrtExt q_xyz if regexm(v7,"MAR√")==1
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ173")==1
	replace NameProv= subinstr(NameProv,"XYZ173","",10)
	
	* reemplazanco caracter "_" por espacio
	*ed  v7 NameProv CrtExt q_xyz if regexm(v7,"_")==1
	*ed  v7 NameProv CrtExt q_xyz if regexm(NameProv,"XYZ95")==1
	replace NameProv= subinstr(NameProv,"XYZ95"," ",10)
	
	* reemplazanco caracter "'" por espacio
	replace NameProv= subinstr(NameProv,"XYZ39"," ",10)
	
	* reemplazanco caracter "`" por espacio
	replace NameProv= subinstr(NameProv,"XYZ96"," ",10)
	
	* reemplazanco caracter "N/A" por espacio
	replace NameProv= subinstr(NameProv,"NXYZ47A"," ",10)
	
	* reemplazanco caracter "N/" por espacio
	replace NameProv= subinstr(NameProv,"NXYZ47"," ",10)
	
	* reemplazanco caracter "N/" por espacio
	replace NameProv= subinstr(NameProv,"XYZ47N"," ",10)

		
	* Reemplazando caracteres extranos por la vocal A
	**ed  v7 NameProv CrtExt NameProvp q_xyz if CrtExt == 1 & regexm(NameProvp,"^([A-Z]*)([ ]*)([A-Z]*)([ ]*)([A-Z]*)(XYZ[0-9]*)")==1 // Se identifican estos
	**ed  v7 NameProv CrtExt NameProvp q_xyz if CrtExt == 1 & regexm(NameProvp,"^([A-Z]*)([ ]*)([A-Z]*)([ ]*)([A-Z]*)(XYZ[0-9]*)")==0 // Estos son los que faltaria por identificar
	
	local crtext 1 2 3 4 5 6 7 8 9 0 //quitando los # que id los caracteres
	foreach z of local crtext{
		replace NameProv= subinstr(NameProv,"`z'","",24) 
	}
	**ed  v7 NameProv CrtExt q_xyz if CrtExt == 1
	
	
	/*
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZXYZXYZ","A",5) // Reemplazando XYZ por A 
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZXYZ","A",5)
	replace NameProv= subinstr(NameProv,"XYZ","A",5) 
	*/
	
	
	
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZXYZXYZ","XYZ",1) // Reemplazando XYZ por XYZ 
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZ","XYZ",1)
	replace NameProv= subinstr(NameProv,"XYZXYZ","XYZ",1)
	*replace NameProv= subinstr(NameProv,"XYZ","",1)
	
	cap drop vtemp //Variable temporal para identificar nombres con estructuras VOCAL-XYZ-VOCAL que usualmente es para —
	gen vtemp=.
	replace vtemp = (regexm(NameProv,"[AEIOU]XYZ[AEIOU]")==1)
	replace NameProv= subinstr(NameProv,"XYZ","—",1) if vtemp==1
	replace NameProv= subinstr(NameProv,"XYZ","A",1) if vtemp!=1
	replace vtemp = (regexm(NameProv,"[AEIOU]XYZ[AEIOU]")==1)
	replace NameProv= subinstr(NameProv,"XYZ","—",1) if vtemp==1
	replace NameProv= subinstr(NameProv,"XYZ","A",1) if vtemp!=1
	drop vtemp
	
	replace NameProv= subinstr(NameProv,"˝","—",2) if regexm(NameProv,"[AEIOU]˝[AEIOU]")==1
	replace NameProv= subinstr(NameProv,"˝","A",2) if regexm(NameProv,"[AEIOU]˝[AEIOU]")==0
	

*************************************************
* III. QUITANDO LOS ESPACIOS EN BLANCO DE NUEVO
*************************************************

	replace NameProv = trim(NameProv) // A veces no funciona - usar siguiente grupo de instrucciones
	cou if regexm(NameProv,"  ")==1 // Estos son los que se reemplazan en el loop que sigue
	**ed v7 NameProv if regexm(NameProv,"  ")==1 // Espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	replace NameProv= subinstr(NameProv,"  "," ",244) // Quitando espacios dobles
	
	
	/*foreach x of numlist 1/30{
		replace NameProv = regexr(NameProv,"  "," ") // Espacios dobles
		}
	*/
	