


***************************
* I. Separando Apellidos
***************************

cap drop v9
gen v9 = ""

cap drop v10_
gen v10_ = ""
rename v10_ v10

local ln0 DIAZ DEL CASTILLO, DIAZ GRANADOS, FACIO LINCE, FERNANDEZ DE CASTRO, FERNANDEZ DE SOTO, GUTIERREZ DE PIÑERES, LA ROTA, LA ROTTA, LADRON DE GUEVARA, LOPEZ DE MESA, MONTES DE OCA, PONCE DE LEON, SANZ DE SANTAMARIA, SAN JUAN, SAN MARTIN, SAN MIGUEL, GUTIERREZ DE PIÑEREZ, GUTIERREZ DE PIÑERES  
local ln1 "DIAZ DEL CASTILLO" " DIAZ GRANADOS" " FACIO LINCE" " FERNANDEZ DE CASTRO" " FERNANDEZ DE SOTO" "GUTIERREZ DE PIÑERES" "LA ROTA" "LA ROTTA" "LADRON DE GUEVARA" "LOPEZ DE MESA" "MONTES DE OCA" "PONCE DE LEON" "SANZ DE SANTAMARIA" "SAN JUAN" "SAN MARTIN" "SAN MIGUEL" "GUTIERREZ DE PIÑEREZ" "GUTIERREZ DE PIÑERES"

local nv : word count "`ln1'" //Counting the number of lastnames in the list
	di `nv'
	local i = 1
	local j = 1	
	while `i'<=(2*`nv')-1{ // Loop que reemplaza NoAplldSiNom=. si apellido hace parte del local ln0 a fin de desmarcarlo para ser borrado.
					   // Si no aparece en esta lista, adiciona este apellido a la base. Esto ultimo puede pasar si es un apellido poco comun ya que solo se consideran apellidos con dup>=2
		gettoken t ln0 : ln0, parse(",")
		if "`t'"!=","{
			dis "`t' is the `j'-th lastname"
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )")==1
			replace v9 = regexs(1) if regexm(NameProv ,"^(`t' )")==1
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )(`t')")==1
			replace v10 = regexs(2) if regexm(NameProv ,"^(`t' )(`t')")==1
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )(DE L[AO][S]? [A-ZÑ]* )")==1
			replace v10 = regexs(2) if regexm(NameProv ,"^(`t' )(DE L[AO][S]? [A-ZÑ]* )")==1
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )(DEL [A-ZÑ]* )")==1
			replace v10 = regexs(2) if regexm(NameProv ,"^(`t' )(DEL [A-ZÑ]* )")==1 
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )(DE [A-ZÑ]* )")==1 & v10==""
			replace v10 = regexs(2) if regexm(NameProv ,"^(`t' )(DE [A-ZÑ]* )")==1 & v10==""
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(`t' )([A-ZÑ]* )")==1 & v10==""
			replace v10 = regexs(2) if regexm(NameProv ,"^(`t' )([A-ZÑ]* )")==1 & v10==""
	
			ed v9 v10 NameProv if regexm(NameProv ,"^(DE L[AO][S]? [A-ZÑ]* )(`t' )")==1
			replace v9 = regexs(1) if regexm(NameProv ,"^(DE L[AO][S]? [A-ZÑ]* )(`t' )")==1
			replace v10 = regexs(2) if regexm(NameProv ,"^(DE L[AO][S]? [A-ZÑ]* )(`t' )")==1
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(DEL [A-ZÑ]* )(`t' )")==1
			replace v9 = regexs(1) if regexm(NameProv ,"^(DEL [A-ZÑ]* )(`t' )")==1
			replace v10 = regexs(2) if regexm(NameProv ,"^(DEL [A-ZÑ]* )(`t' )")==1
			
			ed v9 v10 NameProv if regexm(NameProv ,"^(DE [A-ZÑ]* )(`t' )")==1 & v10==""
			replace v9 = regexs(1) if regexm(NameProv ,"^(DE [A-ZÑ]* )(`t' )")==1 & v10==""
			replace v10 = regexs(2) if regexm(NameProv ,"^(DE [A-ZÑ]* )(`t' )")==1 & v10==""
			
			ed v9 v10 NameProv if regexm(NameProv ,"^([A-ZÑ]* )(`t' )")==1 & v9==""
			replace v9 = regexs(1) if regexm(NameProv ,"^([A-ZÑ]* )(`t' )")==1 & v9==""
			replace v10 = regexs(2) if regexm(NameProv ,"^([A-ZÑ]* )(`t' )")==1 & v10==""
			
			local i = `i'+1
			local j = `j'+1
			}
		else{
			local i = `i'+1
			}
		}

 ed v9 v10 NameProv if v9!="" | v10!=""
		

* DE LA ROSA
ed NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )")==1 & v9==""
replace v9 = regexs(1) if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )")==1 & v9==""
ed v9 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )")==1 

	* DE LA ROSA DE LA HOZ
	ed v9 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1

	* DE LA ROSA DEL REAL
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DEL [A-ZÑ]* )")==1

	* DE LA ROSA DE LEON
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )(DE [A-ZÑ]* )")==1 
	
	* DE LA ROSA ANDRADE
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""
	ed v9 v10 NameProv if regexm(NameProv,"^(DE L[AO][S]? [A-ZÑ]* )([A-ZÑ]* )")==1 
	
	* ANDRADE DE LA ROSA 
	ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1 & v9==""
	replace v9 = regexs(1) if regexm(NameProv,"^([A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1 & v9==""
	replace v10 = regexs(2) if regexm(NameProv,"^([A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1 & v10==""
	ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1 
	
	
* DEL REAL
ed v9 v10 NameProv  if regexm(NameProv,"^(DEL [A-ZÑ]* )")==1 & v9==""
replace v9 = regexs(1) if regexm(NameProv,"^(DEL [A-ZÑ]* )")==1 & v9==""
ed v9 v10 NameProv  if regexm(NameProv,"^(DEL [A-ZÑ]* )")==1 

	* DEL REAL DE LA HOZ
	ed v9 v10 NameProv if regexm(NameProv,"^(DEL [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DEL [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	ed v9 v10 NameProv if regexm(NameProv,"^(DEL [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1

	* DEL REAL DEL REAL
	ed v9 v10 NameProv if regexm(NameProv,"^(DEL [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DEL [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	
	* DEL REAL DE ALBA
	ed v9 v10 NameProv if regexm(NameProv,"^(DEL [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DEL [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""

	* DEL REAL ANDRADE
	ed v9 v10 NameProv if regexm(NameProv,"^(DEL [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DEL [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""

	* ANDRADE DEL REAL
	ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )(DEL [A-ZÑ]* )")==1 & v9==""
	replace v9 = regexs(1) if regexm(NameProv,"^([A-ZÑ]* )(DEL [A-ZÑ]* )")==1 & v9==""
	replace v10 = regexs(2) if regexm(NameProv,"^([A-ZÑ]* )(DEL [A-ZÑ]* )")==1 & v10==""
	ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )(DEL [A-ZÑ]* )")==1 

* DE ALBA
ed v9 v10 NameProv  if regexm(NameProv,"^(DE [A-ZÑ]* )")==1 & v9==""
replace v9 = regexs(1) if regexm(NameProv,"^(DE [A-ZÑ]* )")==1 & v9==""
ed v9 v10 NameProv  if regexm(NameProv,"^(DE [A-ZÑ]* )")==1 
	
	* DE ALBA DE LA HOZ
	ed v9 v10 NameProv if regexm(NameProv,"^(DE [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DE [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	ed v9 v10 NameProv if regexm(NameProv,"^(DE [A-ZÑ]* )(DE L[AO][S]? [A-ZÑ]* )")==1
	
	* DE ALBA DEL REAL
	ed v9 v10 NameProv if regexm(NameProv,"^(DE [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	replace v10 = regexs(2) if regexm(NameProv,"^(DE [A-ZÑ]* )(DEL [A-ZÑ]* )")==1
	
	* DE ALBA DE ALBA
	ed v9 v10 NameProv if regexm(NameProv,"^(DE [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DE [A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""
	
	* DE ALBA ANDRADE
	ed v9 v10 NameProv if regexm(NameProv,"^(DE [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""
	replace v10 = regexs(2) if regexm(NameProv,"^(DE [A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""

	* ANDRADE DE ALBA
	ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v9==""
	replace v9 = regexs(1) if regexm(NameProv,"^([A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v9==""
	replace v10 = regexs(2) if regexm(NameProv,"^([A-ZÑ]* )(DE [A-ZÑ]* )")==1 & v10==""

	ed v9 v10 NameProv if v9!=""


* CORREA JARAMILLO
ed v9 v10 NameProv if v9=="" & wordcount(NameProv)>4
ed v9 v10 NameProv if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]* )")==1 & v9==""
replace v9 = regexs(1) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]* )")==1 & v9==""
replace v10 = regexs(2) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]* )")==1 & v10==""

ed v9 v10 NameProv  if v9==""


***************************
* II. Separando Nombres
*************************** 

cap drop v7
gen v7 = ""

cap drop v8
gen v8 = ""

cap drop NmP
gen NmP = NameProv
replace NmP = subinstr(NameProv,v9,"",1)
ed v7 v8 v9 v10 NameProv NmP

replace NmP = subinstr(NmP,v10,"",1)
ed v7 v8 v9 v10 NameProv NmP

replace v7 = regexs(1) if regexm(NmP,"^([A-ZÑ]+ )([A-ZÑ]*)")==1 
replace v8 = regexs(2) if regexm(NmP,"^([A-ZÑ]+ )([A-ZÑ]*)")==1 
ed v7 v8 v9 v10 NameProv NmP

ed v7 v8 v9 v10 NameProv NmP if v7==""
replace v7 = NmP if v7==""

ed v7 v8 v9 v10 NameProv NmP if v7==""
replace v9 =  regexs(1) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]*)")==1 & v7=="" & v9=="" & NmP==""
replace v7 =  regexs(2) if regexm(NameProv,"^([A-ZÑ]* )([A-ZÑ]*)")==1 & v7=="" & NmP==""

ed v7 v8 v9 v10 NameProv NmP if NmP==""



