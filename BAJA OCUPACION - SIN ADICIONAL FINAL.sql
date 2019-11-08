SELECT T.FECHA_PARTIDA,T.HORA,T.O_D,T.SERVICIO,T.CAPACIDAD_BUS,T.T_BOLETO,T.OCUP FROM

(SELECT  (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END) TURNO,turno HORA,
fecha_partida,o_d,SERVICIO,CAPACIDAD_BUS,T_BOLETO,OCUP 

FROM

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
								AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293)   
                AND v.c_estreg='A'    --and i.TIPITI_ID = 1 
								AND I.N_ESANULADO = 0     AND I.C_ADICIONAL = 0
                and --(v.d_fecpar between to_date('27/01/2018','dd/mm/yyyy') and to_date('27/01/2018','dd/mm/yyyy')
											 --or 
											 --v.d_fecpar between to_date('28/01/2019','dd/mm/yyyy') and to_date('03/02/2019','dd/mm/yyyy')--)
											 (i.D_FECPAR between sysdate-1 and sysdate) and I.C_HORPAR>to_char(sysdate, 'HH24:MI:SS')
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
-- 										 ptmy.DNICOPILOTO,
--                      ptmy.COPILOTO,  
--                      ptmy.ADICIONAL_FIJO,  
                     ptmy.CAPACIDAD_BUS     
										 having round(TO_CHAR(count(1))/CAPACIDAD_BUS,2)<0.4
order by ptmy.turno
)

UNION ALL

(
SELECT  (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END) TURNO,turno HORA, fecha_PARTIDA,o_d,servicio,capacidad_bus, TO_CHAR(sum(bol)) T_BOLETO, 0 ocup
from
(
SELECT DISTINCT TO_CHAR(i.D_FECPAR,'dd/mm/yyyy') fecha_PARTIDA, 
--to_char(i.D_FECPAR,'dd') DIA , to_char(i.D_FECPAR,'mm') MES ,  to_char(i.D_FECPAR,'yyyy') ANUAL,
REPLACE(R.C_ORIGEN,'PUERTO','PTO')||' - '||REPLACE(R.C_DESTINO,'PUERTO','PTO') O_D, 
--r2.c_origen||' - '||r2.c_destino tramo,
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
								
i.C_HORPAR turno,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,

(case 
when v.ITINERARIO_ID is null then 0
else 1
end) BOL
--tt1.C_NOMCOR tipotar1,
--t.n_tarifa1, 
--tt2.C_NOMCOR tipotar2,
--t.n_tarifa2 
FROM VRTITINERARIO i
INNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID
left join (SELECT * from VRTVENPAS where tipmov_id not in( 5,6,13,14) AND 
						c_estreg='A') v   on v.itinerario_id  = i.itinerario_id
--INNER JOIN VRMTIPTAR tt1 ON tt1.TIPTAR_ID = t.TIPTAR_ID1
--INNER JOIN VRMTIPTAR tt2 ON tt2.TIPTAR_ID = t.TIPTAR_ID2
--INNER JOIN VRMRUTA r2 on r2.ruta_id = t.ruta_id 
where (i.D_FECPAR between sysdate-1 and sysdate)																 --to_date('31/01/2019','dd/mm/yyyy'))
--OR (i.D_FECPAR between to_date('27/12/2017','dd/mm/yyyy') and to_date('27/12/2018','dd/mm/yyyy'))
and i.C_ESTREG = 'A' 
--and t.C_ESTREG = 'A' 
--and i.TIPITI_ID = 1 
AND I.N_ESANULADO = 0 AND I.C_ADICIONAL = 0
AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293) 
--and N_TARIFA1 IS NULL
--and i.RUTA_IDMAYOR not in (607,609,767,608,613,766,19,290,4,275,33,270,304,3,267,274,269,270,271,266,267,268)
ORDER BY turno
)
GROUP BY fecha_PARTIDA,o_d,servicio,turno,capacidad_bus
having sum(bol) = 0 
)
) T














INNER JOIN

(
select 
 (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END) TURNO,
 (case
 when ORIGEN= 'LIMA' then 'LIMA-PROV' 
 when DESTINO= 'LIMA' then 'PROV-LIMA' 
  else 'REGIONALES' 
  END) GRUPO,
fecha_partida,o_d,SUM(capacidad_bus) CAPACIDAD, SUM(t_boleto) T_BOLETO, round(SUM(t_boleto)/SUM(capacidad_bus),2) ocup
from
(
(
select distinct --ptmy.EMPRESA,  
                 ptmy.FECHA_PARTIDA,  
                 --TO_CHAR(to_date(to_char(sysdate,'dd/mm/yyyy')||ptmy.TURNO, 'dd/mm/yyyy hh24:mi:ss'),'HH24:MM') HORA,  
									ptmy.TURNO,
									ptmy.ORIGEN,ptmy.DESTINO, 
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
								AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293)   
                AND v.c_estreg='A'    --and i.TIPITI_ID = 1 
								AND I.N_ESANULADO = 0     
                and --(v.d_fecpar between to_date('27/01/2018','dd/mm/yyyy') and to_date('27/01/2018','dd/mm/yyyy')
											 --or 
											 --v.d_fecpar between to_date('28/01/2019','dd/mm/yyyy') and to_date('03/02/2019','dd/mm/yyyy')--)
											 (i.D_FECPAR between sysdate-1 and sysdate)
                and v.agencia_id <> 69) ptmy        
                group by  --ptmy.EMPRESA,     
                     ptmy.FECHA_PARTIDA,  
                     --TO_CHAR(to_date(to_char(sysdate,'dd/mm/yyyy')||ptmy.TURNO, 'dd/mm/yyyy hh24:mi:ss'),'HH24:MM'), 
											ptmy.TURNO,ptmy.ORIGEN,ptmy.DESTINO, 
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


UNION ALL

(
select fecha_PARTIDA,turno,origen,destino,o_d,servicio,capacidad_bus, TO_CHAR(sum(bol)) T_BOLETO, 0 ocup
from
(
SELECT DISTINCT TO_CHAR(i.D_FECPAR,'dd/mm/yyyy') fecha_PARTIDA, 
--to_char(i.D_FECPAR,'dd') DIA , to_char(i.D_FECPAR,'mm') MES ,  to_char(i.D_FECPAR,'yyyy') ANUAL,
REPLACE(R.C_ORIGEN,'PUERTO','PTO') ORIGEN,  REPLACE(R.C_DESTINO,'PUERTO','PTO') DESTINO, 
REPLACE(R.C_ORIGEN,'PUERTO','PTO')||' - '||REPLACE(R.C_DESTINO,'PUERTO','PTO') O_D, 
--r2.c_origen||' - '||r2.c_destino tramo,
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
								
i.C_HORPAR turno,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,

(case 
when v.ITINERARIO_ID is null then 0
else 1
end) BOL
--tt1.C_NOMCOR tipotar1,
--t.n_tarifa1, 
--tt2.C_NOMCOR tipotar2,
--t.n_tarifa2 
FROM VRTITINERARIO i
INNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID
left join (SELECT * from VRTVENPAS where tipmov_id not in( 5,6,13,14) AND 
						c_estreg='A') v   on v.itinerario_id  = i.itinerario_id
--INNER JOIN VRMTIPTAR tt1 ON tt1.TIPTAR_ID = t.TIPTAR_ID1
--INNER JOIN VRMTIPTAR tt2 ON tt2.TIPTAR_ID = t.TIPTAR_ID2
--INNER JOIN VRMRUTA r2 on r2.ruta_id = t.ruta_id 
where (i.D_FECPAR between sysdate-1 and sysdate)																	 --to_date('31/01/2019','dd/mm/yyyy'))
--OR (i.D_FECPAR between to_date('27/12/2017','dd/mm/yyyy') and to_date('27/12/2018','dd/mm/yyyy'))
and i.C_ESTREG = 'A' 
--and t.C_ESTREG = 'A' 
--and i.TIPITI_ID = 1 
AND I.N_ESANULADO = 0
AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293) 
--and N_TARIFA1 IS NULL
--and i.RUTA_IDMAYOR not in (607,609,767,608,613,766,19,290,4,275,33,270,304,3,267,274,269,270,271,266,267,268)
ORDER BY turno
)
GROUP BY
fecha_PARTIDA,turno,origen,destino,o_d,servicio,capacidad_bus
having sum(bol) = 0 
)

)
GROUP BY (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END),(case
 when ORIGEN= 'LIMA' then 'LIMA-PROV' 
 when DESTINO= 'LIMA' then 'PROV-LIMA' 
  else 'REGIONALES' 
  END),fecha_partida,o_d
HAVING round(SUM(t_boleto)/SUM(capacidad_bus),2)<0.7

) G

ON T.TURNO||T.O_D||T.FECHA_PARTIDA = G.TURNO||G.O_D||G.FECHA_PARTIDA
ORDER BY hora
