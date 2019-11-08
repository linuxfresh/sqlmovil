select distinct ptmy.USUC,ptmy.FECC,ptmy.USUM,ptmy.FECM,ptmy.AUDUSUINS,ptmy.AUDFECINS,

ptmy.AUDUSUMOD,ptmy.audfecmod,--ptmy.EMPRESA,  
                 ptmy.FECHA_PARTIDA,-- ptmy.HORA_PART,ptmy.AGENCIA_PARTIDA,
                 ptmy.TURNO,      
                 ptmy.ORIGEN,  ptmy.ITINERARIO_ID,
                 ptmy.DESTINO,-- ptmy.ITINERARIO_ID,  
                 ptmy.SERVICIO--,ptmy.NRO_PROGRAMACION--,
								-- ptmy.usuins_t,ptmy.usumod_t
                 --ptmy.NRO_BUS,  
                 --ptmy.PLACA_BUS,
								--ptmy.CAPACIDAD_BUS,
								--ptmy.AGENCIA,
								--ptmy.ruta--,
								--ptmy.KMS kms,
								
                --TO_CHAR(count(1)) T_BOLETO--, 
								--sum(ptmy.T_MONTO) T_MONTO  
                from (SELECT AP.AUDUSUINS USUC,AP.AUDFECINS FECC,AP.AUDUSUMOD USUM,AP.AUDFECMOD FECM, t.AUDUSUINS usuins_t,t.AUDUSUMOD usumod_t,
								I.AUDUSUINS, i.AUDFECINS,I.AUDUSUMOD, i.AUDFECMOD,--E.C_NOMCOR EMPRESA,     
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO, ap.C_HORPAR HORA_PART, a.C_NOMCOR AGENCIA_PARTIDA ,         
                REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  
                REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO, i.ITINERARIO_ID,
								r.N_KILOMETROS KMS,
								--tru.RUTA_BUS ruta,
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
								'PRESIDENCIAL MB','PRESIDENCIAL') AS SERVICIO,  --a.c_denominacion agencia,
--                 B.C_CODIGO AS NRO_BUS,  
--                 B.C_NUMPLACA AS PLACA_BUS,
-- 								TR.C_NUMDOC AS DNITERRAMOZA,	  
--                 (TR.C_APEPAT||' '||TR.C_APEMAT||' '||TR.C_NOMBRE) AS TERRAMOZA,  
                I.ITINERARIO_ID AS NRO_PROGRAMACION--,
-- 								PE.C_NUMDOC AS DNIPILOTO,
--                 (PE.C_APEPAT||' '||PE.C_APEMAT||' '||PE.C_NOMBRE) AS PILOTO,  
--  								CO.C_NUMDOC AS DNICOPILOTO,
--                 (CO.C_APEPAT||' '||CO.C_APEMAT||' '||CO.C_NOMBRE) AS COPILOTO,  
--                 DECODE(I.C_ADICIONAL,0,'FIJO',1,'ADICIONAL') AS ADICIONAL_FIJO,     
--                 S.N_NUMASIPIS1 as DISNIVEL1 ,NVL(S.N_NUMASIPIS2,0) as DISNIVEL2,  
--                 (S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,            
--                 v.N_TARIFA+v.N_RECARGO+v.N_PENALIDAD-v.N_DESCUENTO as  T_MONTO     
                FROM --VRTVENPAS v    
--                 left join ( select max(proser_id) proser_id, itinerario_id  from VRTPROSER  group by itinerario_id ) PROS0 on PROS0.itinerario_id=v.itinerario_id  
--                 left join VRTPROSER PROS on PROS.proser_id = PROS0.proser_id  
--                 inner join ( select max(venpas_id)venpas_id, c_numcontrol  from vrtvenpas  group by c_numcontrol ) max_venta on max_venta.venpas_id=v.venpas_id  
                --inner join 
								vrtitinerario i --on i.itinerario_id  = V.itinerario_id        
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id  
                --inner join vrmempresa    e on e.empresa_id     = i.empresa_id       
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR 
							left JOIN VRTTARIFAXNIVEL t on t.ITINERARIO_ID = i.ITINERARIO_ID	
							INNER JOIN VRTITIAGEPAR ap on ap.ITINERARIO_ID = I.ITINERARIO_ID
--                 LEFT JOIN VRMBUS        B  ON B.BUS_ID        = PROS.BUS_ID  
--                 LEFT JOIN  VRMPERSONAL   TR ON TR.PERSONAL_ID  = PROS.personal_idterramoza  
--                 LEFT JOIN VRMPERSONAL   PE ON PE.PERSONAL_ID  = PROS.PERSONAL_IDPILOTO  
--                 LEFT JOIN  VRMPERSONAL   CO ON CO.PERSONAL_ID  = PROS.PERSONAL_IDCOPILOTO
								--INNER JOIN TEMPR tru on 	tru.ORIG_DEST = r.c_origen||' - '||r.c_destino
								
								--INNER JOIN VRMAGENCIA ap on ap.AGENCIA_ID = v.AGENCIA_IDPARTIDA
								INNER JOIN VRTITIAGEPAR ap on ap.ITINERARIO_ID = I.ITINERARIO_ID
								INNER JOIN VRMAGENCIA a ON a.AGENCIA_ID = ap.AGENCIA_ID
                where --v.tipmov_id not in( 5,6,13,14)AND 
								--r.ruta_id not in (630,602,594,629,21,22,292,293,38,47,318,309)  AND
								
								--AND v.agencia_id=67 -- SIN ESSALUD
								--AND v.cliente_id = 32
								--and v.TIPCOM_ID = 2
								--and ((r.c_origen ='LIMA') and (r.c_destino ='AYACUCHO')  OR (r.c_origen ='AYACUCHO') and (r.c_destino ='LIMA'))
								
                 --i.c_estreg='I'   AND      
               --and 
							 I.N_ESANULADO = 0 AND
								(I.d_fecpar between to_date('06/11/2019','dd/mm/yyyy') and to_date('06/11/2019','dd/mm/yyyy'))
											--or v.d_fecpar between to_date('01/07/2019','dd/mm/yyyy') and to_date('1/08/2019','dd/mm/yyyy'))
                --and v.agencia_id <> 69
								) ptmy        
                group by --ptmy.AUDUSUINS,
								ptmy.AUDUSUMOD,ptmy.audfecmod,ptmy.USUC,ptmy.FECC,ptmy.USUM,ptmy.FECM, --ptmy.EMPRESA,     
                     ptmy.AUDUSUINS,ptmy.AUDFECINS,ptmy.FECHA_PARTIDA,  	
                     ptmy.TURNO,  ptmy.ITINERARIO_ID,
										 --ptmy.HORA_PART,ptmy.AGENCIA_PARTIDA,          
                     ptmy.ORIGEN,  
                     ptmy.DESTINO, --  ptmy.ITINERARIO_ID,
                     ptmy.SERVICIO,   
                     --ptmy.NRO_BUS,  
                     --ptmy.PLACA_BUS,
                     ptmy.NRO_PROGRAMACION,  
										 --ptmy.usuins_t,ptmy.usumod_t,
                     --ptmy.ADICIONAL_FIJO,  
                     --ptmy.CAPACIDAD_BUS,
										 --ptmy.AGENCIA,
							ptmy.KMS--,
			--ptmy.ruta				
			HAVING ptmy.destino = 'CUSCO' AND ptmy.origen = 'LIMA'
			--ptmy.TURNO = '21:15' --AND 
			--ptmy.AGENCIA_PARTIDA='JAVIER PRADO-TERM'
			--ptmy.AGENCIA_PARTIDA='TOMAS VALLE TERRA'
			ORDER BY AUDFECMOD