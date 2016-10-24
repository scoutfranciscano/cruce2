



***************************
* I. Separando Apellidos
***************************

replace Pri_Aplldo = "NOMESQUE" if upper(v9)=="NOMESQUE" // Borre estos apellidos cuando corre todo lo que parecia Nom_estudiante
replace Seg_Aplldo = "NOMESQUE" if upper(v10)=="NOMESQUE"
replace Pri_Aplldo = "NOMELIN" if upper(v9)=="NOMELIN"
replace Seg_Aplldo = "NOMELIN" if upper(v10)=="NOMELIN"

replace Pri_Aplldo = regexr(Pri_Aplldo,"MUÑ Z","MUÑOZ")
replace Seg_Aplldo = regexr(Seg_Aplldo,"MUÑ Z","MUÑOZ")


cap drop NameProv
gen NameProv = Pri_Aplldo+ " " + Seg_Aplldo


local ln0 DE LOS, DE LAS, DE LA, DEL, DE  
local ln1 "DE LOS" "DE LAS" "DE LA" "DEL" "DE"

local nv : word count "`ln1'" //Counting the number of lastnames in the list
	di `nv'
	local i = 1
	local j = 1	
	while `i'<=(2*`nv')-1{ // Loop que reemplaza NoAplldSiNom=. si apellido hace parte del local ln0 a fin de desmarcarlo para ser borrado.
					   // Si no aparece en esta lista, adiciona este apellido a la base. Esto ultimo puede pasar si es un apellido poco comun ya que solo se consideran apellidos con dup>=2
		gettoken t ln0 : ln0, parse(",")
		if "`t'"!=","{
			dis "`t'
			*replace NameProv = subinstr(NameProv,"`t' "," ",5)
			replace NameProv = regexr(NameProv,"^`t' "," ")
			replace NameProv = regexr(NameProv,"^`t' "," ")
			replace NameProv = regexr(NameProv,"^`t' "," ")
			replace NameProv = regexr(NameProv," `t' "," ")
			replace NameProv = regexr(NameProv," `t' "," ")
			replace NameProv = regexr(NameProv," `t' "," ")
			local i = `i'+1
			local j = `j'+1
			}
		else{
			local i = `i'+1
			}
	}

	// Quitando espacios en blanco
replace NameProv = subinstr(NameProv,"  "," ",100)
ed Pri_Aplldo Seg_Aplldo NameProv  if regexm(Pri_Aplldo, "^DE ")==1 | regexm(Pri_Aplldo, " DE ")==1 | regexm(Seg_Aplldo, "^DE ")==1 | regexm(Seg_Aplldo, " DE ")==1		


		
cap drop v9A
gen v9A = ""

cap drop v10A
gen v10A = ""


local ln0 DIAZ CASTILLO, DIAZ GRANADOS, FACIO LINCE, FERNANDEZ CASTRO, FERNANDEZ SOTO, LA ROTA, LA ROTTA, LADRON GUEVARA, LOPEZ MESA, MONTES OCA, PONCE LEON, SANZ SANTAMARIA, SAN JUAN, SAN MARTIN, SAN MIGUEL, GUTIERREZ PIÑEREZ, GUTIERREZ PIÑERES, GUTIERREZ PINERES, GUTIERREZ PINEREZ  
local ln1 "DIAZ CASTILLO" " DIAZ GRANADOS" " FACIO LINCE" " FERNANDEZ CASTRO" " FERNANDEZ SOTO" "GUTIERREZ PIÑERES" "LA ROTA" "LA ROTTA" "LADRON GUEVARA" "LOPEZ MESA" "MONTES OCA" "PONCE LEON" "SANZ SANTAMARIA" "SAN JUAN" "SAN MARTIN" "SAN MIGUEL" "GUTIERREZ PIÑEREZ" "GUTIERREZ PIÑERES" "GUTIERREZ PINERES" "GUTIERREZ PINEREZ"

local nv : word count "`ln1'" //Counting the number of lastnames in the list
	di `nv'
	local i = 1
	local j = 1	
	while `i'<=(2*`nv')-1{ // Loop que reemplaza NoAplldSiNom=. si apellido hace parte del local ln0 a fin de desmarcarlo para ser borrado.
					   // Si no aparece en esta lista, adiciona este apellido a la base. Esto ultimo puede pasar si es un apellido poco comun ya que solo se consideran apellidos con dup>=2
		gettoken t ln0 : ln0, parse(",")
		if "`t'"!=","{
			dis "`t' is the `j'-th lastname"
			ed v9A v10A NameProv if regexm(NameProv ,"^(`t' )")==1
			replace v9A = regexs(1) if regexm(NameProv ,"^(`t' )")==1
			
			ed v9A v10A NameProv if regexm(NameProv ,"^(`t' )(`t')")==1
			replace v10A = regexs(2) if regexm(NameProv ,"^(`t' )(`t')")==1
			
			ed v9A v10A NameProv if regexm(NameProv ,"^(`t' )([A-ZÑ]* )")==1 & v10A==""
			replace v10A = regexs(2) if regexm(NameProv ,"^(`t' )([A-ZÑ]*)")==1 & v10A==""
	
			ed v9A v10A NameProv if regexm(NameProv ,"^([A-ZÑ]* )(`t')")==1 & v9A==""
			replace v9A = regexs(1) if regexm(NameProv ,"^([A-ZÑ]* )(`t')")==1 & v9A==""
			replace v10A = regexs(2) if regexm(NameProv ,"^([A-ZÑ]* )(`t')")==1 & v10A==""
			
			local i = `i'+1
			local j = `j'+1
			}
		else{
			local i = `i'+1
			}
	}

replace NameProv = subinstr(NameProv,"  "," ",100)
replace NameProv = regexr(NameProv,"^ ","")
replace NameProv = regexr(NameProv,"^ ","")
replace NameProv = regexr(NameProv," $","")
replace NameProv = regexr(NameProv,"^ ","")

replace v9A = regexs(1) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]*)")==1 & v9A==""
replace v10A = regexs(2) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]*)")==1 & v10A==""	
	
ed Pri_Aplldo Seg_Aplldo NameProv v9A v10A if regexm(Pri_Aplldo, "^DE ")==1 | regexm(Pri_Aplldo, " DE ")==1 | regexm(Seg_Aplldo, "^DE ")==1 | regexm(Seg_Aplldo, " DE ")==1				


replace v9A = subinstr(v9A,"  "," ",100)
replace v9A = regexr(v9A,"^ ","")
replace v9A = regexr(v9A,"^ ","")
replace v9A = regexr(v9A," $","")
replace v9A = regexr(v9A,"^ ","")
replace v10A = subinstr(v10A,"  "," ",100)
replace v10A = regexr(v10A,"^ ","")
replace v10A = regexr(v10A,"^ ","")
replace v10A = regexr(v10A," $","")
replace v10A = regexr(v10A,"^ ","")

ed v9 v10 Pri_Aplldo Seg_Aplldo NameProv v9A v10A if (v9A!=Pri_Aplldo | v10A!=Seg_Aplldo) & Seg_Aplldo!=""
ed Pri_Aplldo Seg_Aplldo NameProv v9A v10A if (v9A!=Pri_Aplldo | v10A!=Seg_Aplldo) & Seg_Aplldo!="" ///
	& (regexm(Pri_Aplldo,"[A-ZÑ]DE$")==1 | regexm(Pri_Aplldo,"[A-ZÑ]DEL$")==1)

replace Pri_Aplldo = v9A if v9A!=""
replace Seg_Aplldo = v10A if v10A!=""

ed v9 v10 Pri_Aplldo Seg_Aplldo NameProv v9A v10A if (v9A!=Pri_Aplldo | v10A!=Seg_Aplldo) & Seg_Aplldo!=""
ed Pri_Aplldo Seg_Aplldo NameProv v9A v10A if (v9A!=Pri_Aplldo | v10A!=Seg_Aplldo) & Seg_Aplldo!="" ///
	& (regexm(Pri_Aplldo,"[A-ZÑ]DE$")==1 | regexm(Pri_Aplldo,"[A-ZÑ]DEL$")==1)

		

