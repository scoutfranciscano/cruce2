
* III. CREANDO LOS DIRECTORIOS DE NOMBRES Y APELLIDOS
**************************************************************************************	
	
	
	// Desactivado porque solo se corre 1 vez para todos los archivos
	do "${mydir_DoFiles}\II_Algoritmo_3_DirectorioUnico_SNIES_ICFES_OML_02_11.do" 

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
	
