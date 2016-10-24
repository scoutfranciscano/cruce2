/*
El presente archivo contiene todo el procedimiento necesario para realizar el cruce de los resultados de SABER 11° y SABER PRO pensando en 
los insumos necesarios para llevar a cabo los análisis de VALOR AGREGADO 2012- 2014. Dado que los resultados de SABER 11° anteriores a 2005 no cuentan 
con las características necesarias para garantizar la comparabilidad de los resultados y que se trataba de pruebas con grandes diferencias 
de fondo y estructura, el cruce se realiza con SABER 11° desde 2006 y se toma hasta 2011, año para el cual la diferencia con SABER PRO 
2012-2014 es lo suficientemente amplia para llevar a cabo los análisis.
*/

clear all
set mem 15000m
set more off

global CRUCE "E:\ECUELLAR\Cruce SABER 11 - SABER PRO"

/*
global AISB11=2006 // Año INICIAL de Saber11 a incluir en Cruce 
global SISB11=1    // Semestre INICIAL de Saber11 a incluir en Cruce 
global AFSB11=2011 // Año FINAL de Saber11 a incluir en Cruce 
global SFSB11=2    // Semestre FINAL de Saber11 a incluir en Cruce 


global AISBP=2012 // Año INICIAL de SaberPro a incluir en Cruce 
global SISBP=1    // Semestre INICIAL de SaberPro a incluir en Cruce 
global AFSBP=2014 // Año FINAL de SaberPro a incluir en Cruce 
global SFSBP=2    // Semestre FINAL de SaberPro a incluir en Cruce. Usar igual a 3 si se quiere incluir aplicacion 2010-3 
*/

global short=0   // Se utiliza para hacer pruebas. Si es igual a 1 utiliza tan solo 100 registros de cada archivo de Saber11 y SaberPro 
				 // para hacer pruebas


// Localizacion de los programas
**************************************
	global mydir_DoFiles "${CRUCE}\src"

// Archivos Planos:
**************************************	


// Solamente se toman las variables correspondientes a la información socio-demográfica para llevar a cabo el cruce.
// SABER-11
	global mydir_Data_SB11 "${CRUCE}\input\SABER 11"
// SABER-11: Correspondencia Codigo FTP y Cita_snee 
//	global mydir_Data_SB11_FTP_Cita "${CRUCE}\input\SABER 11\Codigos_FTP_CitaSnee"

// Solamente se toman las variables correspondientes a la información socio-demográfica para llevar a cabo el cruce.
// SABER-Pro
	global mydir_Data_SBPro "${CRUCE}\input\SABER PRO"	
// SABER-Pro: Correspondencia Codigo FTP y Cita_snee 	
//	global mydir_Data_SBPro_FTP_Cita "${CRUCE}\1 Archivos Planos\SaberPro\Codigos_FTP_CitaSnee"

	global mydir_Data_SB11P "${CRUCE}\input\SABER 11 PRO"	
		
// Localizacion de los directorios
	global mydir_DctrData "${CRUCE}\output\Directorios"	
	
******************************************************************
// I. CARGANDO DATOS A PARTIR DE ARCHIVOS PLANOS
******************************************************************

// Desde que el FTP sirve como herramienta de publicación para los archivos de resultados para los investigadores, se han actualizado los archivos 
// para garantizar su uniformidad en el tiempo y su fácil acceso. Actualmente los archivos se encuentran en formato .txt Se armó un único archivo con 
// la información de identificación de todos los estudiantes de SABER 11° desde 2006 a 2011.
// Para evitar múltiples problemas relacionados con la codificación en la cual se encuentran los archivos, se transfieren los archivos previamente 
// a formato .dta. El siguiente do-File modifica los caracteres extraños para evitar problemas de codificación más adelante. 
// En caso de no poder transformar los archivos a .dta, el siguiente do file modifica los carácteres extraños que se generan por los problemas de
// codificación

	// B. INSCRITOS SABER-11
	* Usa sb11_2006-2011_v1-0.dta y devuelve sb11_2006-2011_v2-0.dta
	* En el proceso usa do-files:
	*	II_Algoritmo_1_EditorDeNombresyApellidos.do
	*	I_A_File_Construction_1_SeparadorNomAp.do
	do "${mydir_DoFiles}\I_2_File_Construction_0_Saber11.do"
	
	
	// C. INSCRITOS SABER-PRO
	* Usa saberpro AAAA_S.dsv y devuelve SBPro_Inscritos_AAAA_0S.dta
	* En el proceso usa do-files:
	*	II_Algoritmo_1_EditorDeNombresyApellidos.do
	*	I_A_File_Construction_1_SeparadorNomAp.do
	do "${mydir_DoFiles}\I_3_File_Construction_0_SaberPro.do"
	
******************************************************************
// II.  Construccion de Codigos Soundex + Leveshtein
******************************************************************

	// Toma los diferentes archivos construidos en parte I y devuelve versiones cortas con Codigo Soundex + 
	// Leveshetein y los nombres y apellidos homologados sin caracteres extranhos.
	
	// De SABER11 usa SB11_Inscritos_AAAA_0S.dta y devuelve SB11_Inscritos_AAAA_0S_P.dta
	// De SABER-PRO usa SBPro_Inscritos_AAAA_0S.dta y devuelve SBPro_Inscritos_AAAA_0S_P.dta
		
	do "${mydir_DoFiles}\II_Algoritmo_0_Maestro.do"
	
	* Utiliza los siguientes Do_Files:
	* 	II_Algoritmo_0_Subrutinas.do:
	*		II_Algoritmo_1_EditorDeNombresyApellidos
	*		II_Algoritmo_2_SeparadorDeNombres
	*		II_Algoritmo_4_SeparadorDeApellidos
	* 		II_Algoritmo_4B_SeparadorDeApellidos
	*		II_Algoritmo_5_SDX_LVT_3
	* 		II_Algoritmo_6_FechaNacimiento
	*		II_Algoritmo_7_0_Duplicados
	* 		II_Algoritmo_7_1_DoblePrograma
	
	* Note que no se ni II_Algoritmo_3_Directorios.do ni II_Algoritmo_4_SeparadorDeApellidos_UsandoDirecorio
	* El do file II_Algoritmo_5_SDX_LVT_3.do usa un dicicionario general que se crea en el directorio "Directorios"
	
	
	
***********************************************************************************************************
// III.  Merging los archivos al interior de cada institucion - Creando los Codigos Cod_SNIES y Cod_Icfes
***********************************************************************************************************

		
	* B. Archivos Saber-11 y Saber-Pro: Creando Cod_Icfes
	********************************************************
	*	1.  Halla aquellos que presentaron Saber11 varias veces, guarda la cita y crea 1 registro por estudiante
	*	... Para ello usa III_2_1_SB11_SBPRO_CitasDup_Sab11.do
	*	... Usa SB11_Inscritos_2002_01_P.dta --> append --> devuelve SB11_Inscritos_2002_2011.dta
	
	*	2.  Halla aquellos que presentaron SaberPro varias veces, guarda la cita y crea 1 registro por estudiante
	*	... Para ello usa III_2_2_SB11_SBPRO_CitasDup_SabPro.do
	*	... Usa SBPro_Inscritos_2007_01_P.dta --> Append --> devuelve SBPro_Inscritos_2007_2011.dta
	
	* 	3. Usa SB11_Inscritos_2002_2011.dta y merge con SN_DobleDocumento_20071_20112.dta para guardar doble documentos
	
	* 	4. Usa SBPro_Inscritos_2007_2011.dta y append de SB11_Inscritos_2002_2011.dta para crear Codigos
	* 		i.    Documento Identidad
	* 		ii.   Nombre SxLv2
	*		iii.  Nombre Completo SxLv + Fecha Nacimiento
	*		iv.   Nombre Competo SxLv + Fecha Presentacion
	*		v.    Nombre Parcial SxLv + Fecha Nacimiento
	*		vi.   Nombre Parcial SxLv + Fecha Presentacion
	
	*   5.  Crea Cod_Icfes y se guarda como SB11Pro_2002_2011.dta
	
	*   6.  Collapse by (Cod_Icfes) y se crea SB11Pro_2002_2011_NoRep.dta. La idea es cruzar este con SNIES_NoPanel
	
	do "${mydir_DoFiles}\III_2_0_SB11_SBPRO_Merged.do"

		
***********************************************************************************************************
// V. Organizando los archivos finales para entregar
***********************************************************************************************************
	
	* 1. SNIES: Pegandole Cod_MEN_ICF a todos los archivos matriculados_AAAA_0S.dta
	* ... se guardan como "${mydir_Entrega}\SNIES_20`u'_0`v'.dta" y se hace 
	* ... outsheet using "${mydir_Entrega}\SNIES_20`u'_0`v'.csv", comma replace		
	
	* 2. Observatorio: Pegandole Cod_MEN_ICF al archivo graduados_2007-2011.csv
	* ... se guardan como ${mydir_Entrega}\OML_graduados_2007-2011.dta y se hace 
	* ... outsheet using "${mydir_Entrega}\OML_graduados_2007-2011.csv", comma replace		
	
	* 3. ICFES: Pegandole Cod_MEN_ICF a "${mydir_Data_SB11P}\SB11Pro_2002_2011.dta"
	* ... se guardan como ${mydir_Entrega}\SB11Pro_2002_2011_Cod_MEN_Icfes.dta y se hace 
	* ... outsheet using "${mydir_Entrega}\SB11Pro_2002_2011_Cod_MEN_Icfes.csv", comma replace
	
	do "${mydir_DoFiles}\IV_2_ConstruccionFinalDeArchivos.do"
	
