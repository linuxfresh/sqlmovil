SELECT to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'yyyy') ANUAL,to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'mm') MES,to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'dd') DIA, to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'dd/mm/yyyy') FECHA,
origen||' - '||destino, 
ruta, TURNO, --agencia,
SERVICIO,
SUM(T_BOLETO) BOL, sum(T_MONTO) IMP, SUM(KMS) KILOM, SUM(CAPACIDAD_BUS) CAP, COUNT(*) CANT_SERV

FROM(

select distinct ptmy.EMPRESA,  
                 ptmy.FECHA_PARTIDA,  
                 ptmy.TURNO,      
                 ptmy.ORIGEN,  
                 ptmy.DESTINO,   
                 ptmy.SERVICIO,
                 ptmy.NRO_BUS,  
                 ptmy.PLACA_BUS,
								ptmy.CAPACIDAD_BUS,
								--ptmy.AGENCIA,
								ptmy.ruta,
								ptmy.KMS kms,
								
                TO_CHAR(count(1)) T_BOLETO, 
								sum(ptmy.T_MONTO) T_MONTO  
                from (SELECT  E.C_NOMCOR EMPRESA,     
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO,          
                REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  
                REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO, 
								r.N_KILOMETROS KMS,
								tru.RUTA_BUS ruta,
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
                B.C_CODIGO AS NRO_BUS,  
                B.C_NUMPLACA AS PLACA_BUS,
								TR.C_NUMDOC AS DNITERRAMOZA,	  
                (TR.C_APEPAT||' '||TR.C_APEMAT||' '||TR.C_NOMBRE) AS TERRAMOZA,  
                I.ITINERARIO_ID AS NRO_PROGRAMACION,
								PE.C_NUMDOC AS DNIPILOTO,
                (PE.C_APEPAT||' '||PE.C_APEMAT||' '||PE.C_NOMBRE) AS PILOTO,  
 								CO.C_NUMDOC AS DNICOPILOTO,
                (CO.C_APEPAT||' '||CO.C_APEMAT||' '||CO.C_NOMBRE) AS COPILOTO,  
                DECODE(I.C_ADICIONAL,0,'FIJO',1,'ADICIONAL') AS ADICIONAL_FIJO,     
                S.N_NUMASIPIS1 as DISNIVEL1 ,NVL(S.N_NUMASIPIS2,0) as DISNIVEL2,  
                (S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,            
                v.N_TARIFA+v.N_RECARGO+v.N_PENALIDAD-v.N_DESCUENTO as  T_MONTO     
                FROM VRTVENPAS v    
                left join ( select max(proser_id) proser_id, itinerario_id  from VRTPROSER  group by itinerario_id ) PROS0 on PROS0.itinerario_id=v.itinerario_id  
                left join VRTPROSER PROS on PROS.proser_id = PROS0.proser_id  
                inner join ( select max(venpas_id)venpas_id, c_numcontrol  from vrtvenpas  group by c_numcontrol ) max_venta on max_venta.venpas_id=v.venpas_id  
                inner join vrtitinerario i on i.itinerario_id  = V.itinerario_id        
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id  
                inner join vrmempresa    e on e.empresa_id     = i.empresa_id       
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR  
                LEFT JOIN VRMBUS        B  ON B.BUS_ID        = PROS.BUS_ID  
                LEFT JOIN  VRMPERSONAL   TR ON TR.PERSONAL_ID  = PROS.personal_idterramoza  
                LEFT JOIN VRMPERSONAL   PE ON PE.PERSONAL_ID  = PROS.PERSONAL_IDPILOTO  
                LEFT JOIN  VRMPERSONAL   CO ON CO.PERSONAL_ID  = PROS.PERSONAL_IDCOPILOTO
								INNER JOIN TEMPR tru on 	tru.ORIG_DEST = r.c_origen||' - '||r.c_destino
								INNER JOIN VRMAGENCIA a ON a.AGENCIA_ID = v.AGENCIA_ID
                where v.tipmov_id not in( 5,6,13,14)
								AND r.ruta_id not in (630,602,594,629)
								
								--AND v.agencia_id=67 -- SIN ESSALUD
								--AND v.cliente_id = 32
								--and v.TIPCOM_ID = 2
								--and ((r.c_origen ='LIMA') and (r.c_destino ='AYACUCHO')  OR (r.c_origen ='AYACUCHO') and (r.c_destino ='LIMA'))
								
                AND v.c_estreg='A'         
                and (v.d_fecpar between to_date('01/01/2019','dd/mm/yyyy') and to_date('04/11/2019','dd/mm/yyyy'))
											 --or v.d_fecpar between to_date('01/08/2019','dd/mm/yyyy') and to_date('30/09/2019','dd/mm/yyyy'))
                and v.agencia_id <> 69) ptmy        
                group by  ptmy.EMPRESA,     
                     ptmy.FECHA_PARTIDA,  
                     ptmy.TURNO,          
                     ptmy.ORIGEN,  
                     ptmy.DESTINO,   
                     ptmy.SERVICIO,   
                     ptmy.NRO_BUS,  
                     ptmy.PLACA_BUS,
										 ptmy.DNITERRAMOZA,  
                     ptmy.TERRAMOZA,  
                     ptmy.NRO_PROGRAMACION,  
										 ptmy.DNIPILOTO,
                     ptmy.PILOTO, 
										 ptmy.DNICOPILOTO,
                     ptmy.COPILOTO,  
                     ptmy.ADICIONAL_FIJO,  
                     ptmy.CAPACIDAD_BUS,
										 --ptmy.AGENCIA,
							ptmy.KMS,
			ptmy.ruta				
)
GROUP BY to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'yyyy'),to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'mm'),to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'dd'),to_char(to_date(FECHA_PARTIDA,'dd/mm/yyyy'),'dd/mm/yyyy'),origen||' - '||destino, 
ruta,TURNO,SERVICIO
HAVING RUTA = 'TRUJILLO' AND SERVICIO = 'ECONOMICO'