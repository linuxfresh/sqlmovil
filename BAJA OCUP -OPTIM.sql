--Turnos con baja ocupacion
SELECT T.FECHA_PARTIDA,T.HORA,T.O_D,
DECODE(T.SERVICIO,
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
T.CAPACIDAD_BUS,T.T_BOLETO,T.OCUP FROM
(
SELECT  (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END) TURNO,turno HORA,
fecha_partida,o_d,SERVICIO,CAPACIDAD_BUS,T_BOLETO,OCUP 

FROM
(
select distinct  
                 ptmy.FECHA_PARTIDA,  
                 ptmy.TURNO,      
                 ptmy.ORIGEN||' - '||ptmy.DESTINO o_d,   
                 ptmy.SERVICIO,
								ptmy.CAPACIDAD_BUS,
                TO_CHAR(count(1)) T_BOLETO, 
								round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) ocup 
                from (SELECT
                TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO,          
                R.C_ORIGEN ORIGEN,  
                R.C_DESTINO DESTINO,   
								S.C_NOMCOR AS SERVICIO,    
                (S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS              
                FROM vrtitinerario i  
								left join VRTVENPAS v    on v.itinerario_id  = i.itinerario_id      
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id        
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR  
                where v.tipmov_id not in( 5,6,13,14)
								AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293)   
                AND v.c_estreg='A'   
								AND I.N_ESANULADO = 0     AND I.C_ADICIONAL = 0
                and (i.D_FECPAR between sysdate-1 and sysdate) and I.C_HORPAR>to_char(sysdate, 'HH24:MI:SS')
                and v.agencia_id <> 69) ptmy        
                group by     
                     ptmy.FECHA_PARTIDA,  
                     ptmy.TURNO,          
                     ptmy.ORIGEN||' - '||ptmy.DESTINO,   
                     ptmy.SERVICIO,    
                     ptmy.CAPACIDAD_BUS     
										 having round(TO_CHAR(count(1))/CAPACIDAD_BUS,2)<0.3
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
R.C_ORIGEN||' - '||R.C_DESTINO O_D, 
								S.C_NOMCOR AS SERVICIO,							
i.C_HORPAR turno,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,

(case 
when v.ITINERARIO_ID is null then 0
else 1
end) BOL
FROM VRTITINERARIO i
INNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID
left join (SELECT * from VRTVENPAS where tipmov_id not in( 5,6,13,14) AND c_estreg='A') v   on v.itinerario_id  = i.itinerario_id
where (i.D_FECPAR between sysdate-1 and sysdate)
and i.C_ESTREG = 'A'  
AND I.N_ESANULADO = 0 AND I.C_ADICIONAL = 0
AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293) 
)
GROUP BY fecha_PARTIDA,o_d,servicio,turno,capacidad_bus
having sum(bol) = 0 
)
) T

INNER JOIN

(select 
 (case
 when TURNO<= '13:00' then 'MAÑANA' 
 when TURNO <= '18:00' then 'TARDE' 
  else 'NOCHE' 
  END) TURNO,
fecha_partida,o_d,SUM(capacidad_bus) CAPACIDAD, SUM(t_boleto) T_BOLETO, round(SUM(t_boleto)/SUM(capacidad_bus),2) ocup
from
(
(select distinct   ptmy.FECHA_PARTIDA,  
									ptmy.TURNO,
									ptmy.ORIGEN,ptmy.DESTINO, 
                 ptmy.ORIGEN||' - '||ptmy.DESTINO o_d,   
                 ptmy.SERVICIO,
								ptmy.CAPACIDAD_BUS,
                TO_CHAR(count(1)) T_BOLETO, 
								round(TO_CHAR(count(1))/ptmy.CAPACIDAD_BUS,2) ocup 
                from (SELECT  TO_CHAR(I.D_FECPAR,'DD/MM/YYYY') FECHA_PARTIDA,  
                I.C_HORPAR TURNO,          
                R.C_ORIGEN ORIGEN,  
                R.C_DESTINO DESTINO,   
								S.C_NOMCOR AS SERVICIO,    
                (S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS    
                FROM vrtitinerario i  
								left join VRTVENPAS v    on v.itinerario_id  = i.itinerario_id      
                inner join vrmservicio   s on s.servicio_id    = i.servicio_id      
                inner join vrmruta       r on r.ruta_id        = I.RUTA_IDMAYOR   
                where v.tipmov_id not in( 5,6,13,14)
								AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293)   
                AND v.c_estreg='A' 
								AND I.N_ESANULADO = 0     
                and  (i.D_FECPAR between sysdate-1 and sysdate)
                and v.agencia_id <> 69) ptmy        
                group by     
                     ptmy.FECHA_PARTIDA,   
											ptmy.TURNO,ptmy.ORIGEN,ptmy.DESTINO, 
                     ptmy.ORIGEN||' - '||ptmy.DESTINO,   
                     ptmy.SERVICIO,   
                     ptmy.CAPACIDAD_BUS     
)


UNION ALL

(
select fecha_PARTIDA,turno,origen,destino,o_d,servicio,capacidad_bus, TO_CHAR(sum(bol)) T_BOLETO, 0 ocup
from
(
SELECT DISTINCT TO_CHAR(i.D_FECPAR,'dd/mm/yyyy') fecha_PARTIDA, 
R.C_ORIGEN ORIGEN,  R.C_DESTINO DESTINO, 
R.C_ORIGEN||' - '||R.C_DESTINO O_D, 
								S.C_NOMCOR AS SERVICIO,
								
i.C_HORPAR turno,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,

(case 
when v.ITINERARIO_ID is null then 0
else 1
end) BOL
FROM VRTITINERARIO i
INNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID
left join (SELECT * from VRTVENPAS where tipmov_id not in( 5,6,13,14) AND 
						c_estreg='A') v   on v.itinerario_id  = i.itinerario_id
where (i.D_FECPAR between sysdate-1 and sysdate)
and i.C_ESTREG = 'A'  
--and i.TIPITI_ID = 1 
AND I.N_ESANULADO = 0
AND r.ruta_id not in (630,602,594,629,3,274,269,33,304,266,767,608,613,19,290,4,275,47,318,22,293) 

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
  END),
	fecha_partida,o_d
HAVING round(SUM(t_boleto)/SUM(capacidad_bus),2)<0.6
) G
ON T.TURNO=G.TURNO AND T.O_D=G.O_D AND T.FECHA_PARTIDA=G.FECHA_PARTIDA
ORDER BY hora
