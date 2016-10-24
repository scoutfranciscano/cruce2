	
				// Salvando Codigo IES de aquellos con doble/triple programa
				// Se juntan el codigo IES y el de programa pq el codigo IES no es unico para cada persona y asi se garantiza que las vars v3,  v3_2 y v3_3
				// tengan el mismo ordenb de las variables v104_1 v104_2 v104_3
				cap drop v3_1
					gen v3_1 = string(v3)+v104
				cap drop v3_Min
					egen v3_Min = mode(v3_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM) minmode
				cap drop v3_Max
					egen v3_Max = mode(v3_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM)  maxmode
				cap drop v3_2
					gen  v3_2 = v3_Max if v3_Max!="" & v3_1==v3_Min &  v3_Min!="" & Tid_SLM_v5==2
					replace  v3_2 = v3_Min if v3_Min!="" & v3_1==v3_Max &  v3_Max!="" & Tid_SLM_v5==2
				
				
				// Salvando Codigo PROGRAMA de aquellos con doble/triple programa				
				cap drop v104_1
					gen v104_1 = v104
				cap drop v104_Min
					egen v104_Min = mode(v104_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM) minmode 
				cap drop v104_Max
					egen v104_Max = mode(v104_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM) maxmode
				cap drop v104_2
					gen  v104_2 = v104_Max if v104_Max!="" & v104_1==v104_Min &  v104_Min!="" & Tid_SLM_v5==2
					replace  v104_2 = v104_Min if v104_Min!="" & v104_1==v104_Max &  v104_Max!="" & Tid_SLM_v5==2
				
				/*
				// Salvando Cohorte para cada programa 	
				cap drop v1078_1
					gen v1078_1 = v1078
				cap drop v1078_Min
					egen v1078_Min = mode(v1078_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM) minmode 
				cap drop v1078_Max
					egen v1078_Max = mode(v1078_1) if id_SLM_v5!=1 & id_SLM_v5_IP==1, by(id_SLM) maxmode
				cap drop v1078_2
					gen  v1078_2 = v1078_Max if v1078_Max!="" & v1078_1==v1078_Min &  v1078_Min!="" & Tid_SLM_v5==2
					replace  v1078_2 = v1078_Min if v1078_Min!="" & v1078_1==v1078_Max &  v1078_Max!="" & Tid_SLM_v5==2
				
				*/
				
				
							
				order  EVAL_PERIODO v3 v3_1 v3_2 v3_Min v3_Max v5-v104 v104_1 v104_2 v104_Min v104_Max
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==2
				
				
					// Esta parte es solo para triple programa					
							
				cap drop v3_3
				gen v3_3 = ""
				
				cap drop v3_P // Guarda la segunda moda 
					gen v3_P = v3_1 if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3 & v3_1!=v3_Min & v3_1!=v3_Max
				cap drop v3_Med 
					egen v3_Med = mode(v3_P) if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3, by(id_SLM) maxmode
				drop v3_P 
			
					
					// Creando variables de IES asociadas a los diferentes programas
				*order  FileOrigen-v3 v3_1 v3_2 v3_3 v3_Min v3_Med v3_Max v5-v104 v104_2 v104_Min v104_Max
				order  EVAL_PERIODO v3 v3_1 v3_2 v3_3 v3_Min v3_Med v3_Max v5-v104 
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3
	
				replace v3_2 = v3_Med if v3_1==v3_Min & v3_Med!="" & v3_Min!="" & Tid_SLM_v5==3
				replace v3_3 = v3_Max if v3_1==v3_Min & v3_Max!="" & v3_Min!="" & Tid_SLM_v5==3
				
				replace v3_2 = v3_Min if v3_1==v3_Max & v3_Min!="" & v3_Max!="" & Tid_SLM_v5==3
				replace v3_3 = v3_Med if v3_1==v3_Max & v3_Med!="" & v3_Max!="" & Tid_SLM_v5==3
				
				replace v3_2 = v3_Max if v3_1==v3_Med & v3_Max!="" & v3_Med!="" & Tid_SLM_v5==3
				replace v3_3 = v3_Min if v3_1==v3_Med & v3_Min!="" & v3_Med!="" & Tid_SLM_v5==3
				
				drop v3_Min v3_Max v3_Med 
				
				
						
					// Lo mismo pero para programa
				cap drop v104_3
				gen v104_3 = ""
				
				cap drop v104_P // Guarda la segunda moda 
					gen v104_P = v104_1 if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3 & v104_1!=v104_Min & v104_1!=v104_Max
				
				cap drop v104_Med 
					egen v104_Med = mode(v104_P) if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3, by(id_SLM) maxmode
				drop v104_P 
				
				order  EVAL_PERIODO v3 v3_1 v3_2 v3_3 v5-v104 v104_1 v104_2 v104_3 v104_Min v104_M*ed v104_Max  
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3
	
				replace v104_2 = v104_Med if v104_1==v104_Min & v104_Med!="" & v104_Min!="" & Tid_SLM_v5==3
				replace v104_3 = v104_Max if v104_1==v104_Min & v104_Max!="" & v104_Min!="" & Tid_SLM_v5==3
				
				replace v104_2 = v104_Min if v104_1==v104_Max & v104_Min!="" & v104_Max!="" & Tid_SLM_v5==3
				replace v104_3 = v104_Med if v104_1==v104_Max & v104_Med!="" & v104_Max!="" & Tid_SLM_v5==3
				
				replace v104_2 = v104_Max if v104_1==v104_Med & v104_Max!="" & v104_Med!="" & Tid_SLM_v5==3
				replace v104_3 = v104_Min if v104_1==v104_Med & v104_Min!="" & v104_Med!="" & Tid_SLM_v5==3
				
				drop v104_Min v104_Max v104_M*ed 
				
				
				
				
					// Extrayendo el codigo de IES de nuevo
				cap drop v3_P1
					gen v3_P1 = subinstr(v3_1,v104_1,"",1)
					replace v3_P1 = subinstr(v3_1,v104_2,"",1) if length(v3_P1)>4
					replace v3_P1 = subinstr(v3_1,v104_3,"",1) if length(v3_P1)>4
				cap drop v3_P2	
					gen v3_P2 = subinstr(v3_2,v104_2,"",1)
					replace v3_P2 = subinstr(v3_2,v104_1,"",1) if length(v3_P2)>4
					replace v3_P2 = subinstr(v3_2,v104_3,"",1) if length(v3_P2)>4
				cap drop v3_P3
					gen v3_P3 = subinstr(v3_3,v104_3,"",1)
					replace v3_P3 = subinstr(v3_3,v104_1,"",1) if length(v3_P3)>4
					replace v3_P3 = subinstr(v3_3,v104_2,"",1) if length(v3_P3)>4
				
				
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3
				
				
				cap drop v104_P1
					gen v104_P1 = subinstr(v3_1,v3_P1,"",1)
				cap drop v104_P2	
					gen v104_P2 = subinstr(v3_2,v3_P2,"",1)
				cap drop v104_P3
					gen v104_P3 = subinstr(v3_3,v3_P3,"",1)
								
				order  CITA_SNEE EVAL_PERIODO v3 v3_1 v3_2 v3_3 v3_P1 v3_P2 v3_P3 v5-v104 v104_1 v104_2 v104_3 v104_P1 v104_P2 v104_P3 
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3
				
				drop v3_1 v3_2 v3_3 v104_1 v104_2 v104_3
				
				
				rename v3_P1 v3_1
				rename v3_P2 v3_2
				rename v3_P3 v3_3
				
				rename v104_P1 v104_1
				rename v104_P2 v104_2
				rename v104_P3 v104_3
				

					
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 
				*ed v5 v3 v3_* v104* if id_SLM_v5!=1 & id_SLM_v5_IP==1 & Tid_SLM_v5==3
			
				
