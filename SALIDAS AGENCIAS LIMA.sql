SELECT * FROM (
select distinct  
                 ptmy.FECHA_PARTIDA, ptmy.HORA_PART,ptmy.AGENCIA_PARTIDA,
                ptmy.TURNO,      
                 ptmy.ORIGEN||' - '||ptmy.DESTINO O_D,
                 ptmy.SERVICIO

                from (SELECT 
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO, ap.C_HORPAR HORA_PART, a.C_NOMCOR AGENCIA_PARTIDA ,         
                REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  
                REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO, i.ITINERARIO_ID,
								r.N_KILOMETROS KMS,
								DECODE(S.C_NOMCOR,
								'E. VIP MB','EJECUTIVO VIP',
								'E. VIP MT','EJECUTIVO VIP',
								'EJECUTIVO MB','EJECUTIVO',
								'EJECUTIVO MT','EJECUTIVO',
								'ECONOMICO MB','ECONOMICO',
								'ECONOMICO MT','ECONOMICO',
								'PREMIER MB','PREMIER',
								'PREMIER MT','PREMIER',
								'PRESIDENCIAL MT','PRESIDENCIAL',
								'PRESIDENCIAL MB','PRESIDENCIAL') AS SERVICIO, 
                I.ITINERARIO_ID AS NRO_PROGRAMACION--, 
                FROM 
								vrtitinerario i  
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id         
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR  
								INNER JOIN VRTITIAGEPAR ap on ap.ITINERARIO_ID = I.ITINERARIO_ID
								INNER JOIN VRMAGENCIA a ON a.AGENCIA_ID = ap.AGENCIA_ID
                where								
                 i.c_estreg='A'         
               and I.N_ESANULADO = 0 AND
								(I.d_fecpar between to_date(:fec,'dd/mm/yyyy') and to_date(:fec,'dd/mm/yyyy'))
								) ptmy        
                group by    
                     ptmy.FECHA_PARTIDA,  	
                     ptmy.TURNO, ptmy.ORIGEN,ptmy.DESTINO,
										 ptmy.HORA_PART,ptmy.AGENCIA_PARTIDA,          
                     ptmy.ORIGEN||' - '||ptmy.DESTINO,
                     ptmy.SERVICIO,   
											ptmy.KMS		
			HAVING ptmy.origen = 'LIMA' --AND 
			ORDER BY HORA_PART
	)

PIVOT (MAX(HORA_PART) FOR AGENCIA_PARTIDA IN ('JAVIER PRADO-TERM','PASEO-TERM','TOMAS VALLE TERRA'))

ORDER BY TURNO