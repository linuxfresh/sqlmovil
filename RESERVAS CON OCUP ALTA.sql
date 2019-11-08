SELECT RE.*,OA.BOL-RE.RESERVAS VENTAS,OA.BOL,OA.OCUP

FROM

(select --usuario,agencia,
fecha_partida,o_d,servicio,turno,SUM(capacidad_bus) CAPACIDAD, SUM(t_boleto) RESERVAS--, round(SUM(t_boleto)/SUM(capacidad_bus),2) ocup
from
(
select distinct --ptmy.EMPRESA, 
								--ptmy.usuario,ptmy.agencia,
                 ptmy.FECHA_PARTIDA,  
                 ptmy.TURNO,      
                 ptmy.ORIGEN||' - '||ptmy.DESTINO o_d,   
                 ptmy.SERVICIO,
                 --ptmy.NRO_BUS,  
                 --ptmy.PLACA_BUS,
								ptmy.CAPACIDAD_BUS,
                TO_CHAR(count(1)) T_BOLETO, 
								round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) ocup
								--sum(ptmy.T_MONTO) T_MONTO  
                from (SELECT u.C_NOMBRE||' '||u.C_APEPAT usuario, a.c_denominacion agencia,E.C_NOMCOR EMPRESA,     
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO,          
                REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  
                REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO,   
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
                FROM vrtitinerario i  
								left join VRTVENPAS v    on v.itinerario_id  = i.itinerario_id
                left join ( select max(proser_id) proser_id, itinerario_id  from VRTPROSER  group by itinerario_id ) PROS0 on PROS0.itinerario_id=v.itinerario_id  
                left join VRTPROSER PROS on PROS.proser_id = PROS0.proser_id  
                inner join ( select max(venpas_id)venpas_id, c_numcontrol  from vrtvenpas  group by c_numcontrol ) max_venta on max_venta.venpas_id=v.venpas_id  
      
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id  
                inner join vrmempresa    e on e.empresa_id     = i.empresa_id       
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR 
									INNER JOIN VRMUSUARIO u on u.C_LOGIN = v.AUDUSUINS
									LEFT JOIN VRMAGENCIA a on a.AGENCIA_ID = v.AGENCIA_ID
                LEFT JOIN VRMBUS        B  ON B.BUS_ID        = PROS.BUS_ID  
                LEFT JOIN  VRMPERSONAL   TR ON TR.PERSONAL_ID  = PROS.personal_idterramoza  
                LEFT JOIN VRMPERSONAL   PE ON PE.PERSONAL_ID  = PROS.PERSONAL_IDPILOTO  
                LEFT JOIN  VRMPERSONAL   CO ON CO.PERSONAL_ID  = PROS.PERSONAL_IDCOPILOTO  
                --where v.tipmov_id not in( 5,6,13,14)
								where v.tipmov_id = 11
								AND r.ruta_id not in (630,602,594,629)   
                AND v.c_estreg='A'    --and i.TIPITI_ID = 1 
								AND I.N_ESANULADO = 0     
                and --(v.d_fecpar between to_date('27/01/2018','dd/mm/yyyy') and to_date('27/01/2018','dd/mm/yyyy')
											 --or 
											 --v.d_fecpar between to_date('28/01/2019','dd/mm/yyyy') and to_date('03/02/2019','dd/mm/yyyy')--)
											 (i.D_FECPAR between sysdate-1 and sysdate+27)
                and v.agencia_id <> 69) ptmy        
                group by  --ptmy.EMPRESA,     
                     ptmy.FECHA_PARTIDA, -- ptmy.agencia,ptmy.usuario,
                     ptmy.TURNO,          
                     ptmy.ORIGEN||' - '||ptmy.DESTINO,   
                     ptmy.SERVICIO,   
                     --ptmy.NRO_BUS,  
                     --ptmy.PLACA_BUS,
-- 										 ptmy.DNITERRAMOZA,  
--                      ptmy.TERRAMOZA,  
--                      ptmy.NRO_PROGRAMACION,  
-- 										 ptmy.DNIPILOTO,
--                      ptmy.PILOTO, 
-- 										 ptmy.DNICOPILOTO,98
--                      ptmy.COPILOTO,  
--                      ptmy.ADICIONAL_FIJO,  
                     ptmy.CAPACIDAD_BUS     
										 --having round(TO_CHAR(count(1))/CAPACIDAD_BUS,2)>0.75
--order by round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) desc
)

GROUP BY --usuario,agencia,
fecha_partida,o_d,servicio,turno
--HAVING round(SUM(t_boleto)/SUM(capacidad_bus),2)>0.8
HAVING SUM(t_boleto) >=5
ORDER BY TO_DATE(FECHA_PARTIDA),TURNO
)RE

INNER JOIN


(
select fecha_partida,o_d,turno,servicio,SUM(capacidad_bus) CAP, SUM(t_boleto) BOL, round(SUM(t_boleto)/SUM(capacidad_bus),2) ocup
from
(
select distinct --ptmy.EMPRESA,  
                 ptmy.FECHA_PARTIDA,  
                 ptmy.TURNO,      
                 ptmy.ORIGEN||' - '||ptmy.DESTINO o_d,   
                 ptmy.SERVICIO,
                 --ptmy.NRO_BUS,  
                 --ptmy.PLACA_BUS,
								ptmy.CAPACIDAD_BUS,
                TO_CHAR(count(1)) T_BOLETO, 
								round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) ocup
								--sum(ptmy.T_MONTO) T_MONTO  
                from (SELECT  E.C_NOMCOR EMPRESA,     
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO,          
                REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  
                REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO,   
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
                FROM vrtitinerario i  
								left join VRTVENPAS v    on v.itinerario_id  = i.itinerario_id
                left join ( select max(proser_id) proser_id, itinerario_id  from VRTPROSER  group by itinerario_id ) PROS0 on PROS0.itinerario_id=v.itinerario_id  
                left join VRTPROSER PROS on PROS.proser_id = PROS0.proser_id  
                inner join ( select max(venpas_id)venpas_id, c_numcontrol  from vrtvenpas  group by c_numcontrol ) max_venta on max_venta.venpas_id=v.venpas_id  
      
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id  
                inner join vrmempresa    e on e.empresa_id     = i.empresa_id       
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR  
                LEFT JOIN VRMBUS        B  ON B.BUS_ID        = PROS.BUS_ID  
                LEFT JOIN  VRMPERSONAL   TR ON TR.PERSONAL_ID  = PROS.personal_idterramoza  
                LEFT JOIN VRMPERSONAL   PE ON PE.PERSONAL_ID  = PROS.PERSONAL_IDPILOTO  
                LEFT JOIN  VRMPERSONAL   CO ON CO.PERSONAL_ID  = PROS.PERSONAL_IDCOPILOTO  
                where v.tipmov_id not in( 5,6,13,14)
								AND r.ruta_id not in (630,602,594,629)   
                AND v.c_estreg='A'    --and i.TIPITI_ID = 1 
								AND I.N_ESANULADO = 0     
                and --(v.d_fecpar between to_date('27/01/2018','dd/mm/yyyy') and to_date('27/01/2018','dd/mm/yyyy')
											 --or 
											 --v.d_fecpar between to_date('28/01/2019','dd/mm/yyyy') and to_date('03/02/2019','dd/mm/yyyy')--)
											 (i.D_FECPAR between sysdate-1 and sysdate+27)
                and v.agencia_id <> 69) ptmy        
                group by  --ptmy.EMPRESA,     
                     ptmy.FECHA_PARTIDA,  
                     ptmy.TURNO,          
                     ptmy.ORIGEN||' - '||ptmy.DESTINO,   
                     ptmy.SERVICIO,   
                     --ptmy.NRO_BUS,  
                     --ptmy.PLACA_BUS,
-- 										 ptmy.DNITERRAMOZA,  
--                      ptmy.TERRAMOZA,  
--                      ptmy.NRO_PROGRAMACION,  
-- 										 ptmy.DNIPILOTO,
--                      ptmy.PILOTO, 
-- 										 ptmy.DNICOPILOTO,98
--                      ptmy.COPILOTO,  
--                      ptmy.ADICIONAL_FIJO,  
                     ptmy.CAPACIDAD_BUS     
										 --having round(TO_CHAR(count(1))/CAPACIDAD_BUS,2)>0.75
--order by round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) desc
)

GROUP BY fecha_partida,o_d,turno,servicio
HAVING round(SUM(t_boleto)/SUM(capacidad_bus),2)>=0.5
)OA

ON RE.FECHA_PARTIDA=OA.FECHA_PARTIDA AND RE.O_D=OA.O_D AND RE.SERVICIO=OA.SERVICIO AND RE.TURNO=OA.TURNO

--where OA.BOL>RE.RESERVAS

ORDER BY TO_DATE(RE.FECHA_PARTIDA),RE.TURNO