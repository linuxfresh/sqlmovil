SELECT DISTINCT --i.ITINERARIO_ID,
TO_CHAR(i.D_FECPAR,'dd/mm/yyyy') fecha, 
--to_char(i.D_FECPAR,'dd') DIA , to_char(i.D_FECPAR,'mm') MES ,  to_char(i.D_FECPAR,'yyyy') ANUAL,
r.c_origen||' - '||r.c_destino O_D, 
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
i.C_HORPAR--tt1.C_NOMCOR tipotar1,
--t.n_tarifa1, 
--tt2.C_NOMCOR tipotar2,
--t.n_tarifa2 
FROM VRTITINERARIO iINNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID AND t.RUTA_ID = i.RUTA_IDMAYOR
LEFT JOIN VRTVENPAS v ON V.ITINERARIO_ID = i.ITINERARIO_ID
--INNER JOIN VRMTIPTAR tt1 ON tt1.TIPTAR_ID = t.TIPTAR_ID1
--INNER JOIN VRMTIPTAR tt2 ON tt2.TIPTAR_ID = t.TIPTAR_ID2
--INNER JOIN VRMRUTA r2 on r2.ruta_id = t.ruta_id 
where (i.D_FECPAR between sysdate-1 and sysdate+48)																	 --to_date('31/01/2019','dd/mm/yyyy'))
--OR (i.D_FECPAR between to_date('27/12/2017','dd/mm/yyyy') and to_date('27/12/2018','dd/mm/yyyy'))
and i.C_ESTREG = 'A' 
--and t.C_ESTREG = 'A' 
--and i.TIPITI_ID = 1 
AND I.N_ESANULADO = 0
and (N_TARIFA1 IS NULL AND N_TARIFA2 IS NULL)
and i.RUTA_IDMAYOR not in (630,602,594,629,4,275,607,609,767,608,613,766,19,290,269)--,33,270,304,3,267,274,269,270,271,266,267,268)
and  i.ITINERARIO_ID not in (
SELECT ITINERARIO_ID from VRTITINERARIO WHERE i.RUTA_IDMAYOR in (331,315) AND i.SERVICIO_ID = 29 and i.D_FECPAR between sysdate-1 and sysdate+48)
and v.venpas_id is null
and SUBSTR(i.C_HORPAR,5,1) not in ('1','2','3','4')
ORDER BY TO_DATE(FECHA,'dd/mm/yyyy')
