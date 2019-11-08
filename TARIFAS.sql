SELECT DISTINCT TO_CHAR(i.D_FECPAR,'dd/mm/yyyy') fecha, 
to_char(i.D_FECPAR,'dd') DIA , to_char(i.D_FECPAR,'mm') MES ,  to_char(i.D_FECPAR,'yyyy') ANUAL,
r.c_origen||' - '||r.c_destino O_D, tru.RUTA_BUS ruta,
r2.c_origen||' - '||r2.c_destino tramo,
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
								
i.C_HORPAR TURNO,--tt1.C_NOMCOR tipotar1,
ap.C_HORPAR,al.C_HORLLE,apa.C_DENOMINACION,alle.C_DENOMINACION,
t.n_tarifa1, 
--tt2.C_NOMCOR tipotar2,
t.n_tarifa2 
FROM VRTITINERARIO i
INNER JOIN VRMRUTA r ON r.ruta_id=i.RUTA_IDMAYOR
INNER JOIN VRMSERVICIO s ON s.SERVICIO_ID = i.SERVICIO_ID
INNER JOIN VRTITIAGEPAR ap ON ap.ITINERARIO_ID = I.ITINERARIO_ID
INNER JOIN VRTITIAGELLE al ON al.ITINERARIO_ID = I.ITINERARIO_ID
INNER JOIN VRMAGENCIA apa ON apa.AGENCIA_ID = ap.AGENCIA_ID 
INNER JOIN VRMAGENCIA alle ON alle.AGENCIA_ID = al.AGENCIA_ID 
INNER JOIN TEMPR tru on 	tru.ORIG_DEST = r.c_origen||' - '||r.c_destino
LEFT JOIN VRTTARIFAXNIVEL t ON t.ITINERARIO_ID = i.ITINERARIO_ID
--INNER JOIN VRMTIPTAR tt1 ON tt1.TIPTAR_ID = t.TIPTAR_ID1
--INNER JOIN VRMTIPTAR tt2 ON tt2.TIPTAR_ID = t.TIPTAR_ID2
INNER JOIN VRMRUTA r2 on r2.ruta_id = t.ruta_id 
where (i.D_FECPAR between to_date('03/04/2019','dd/mm/yyyy') and to_date('03/04/2019','dd/mm/yyyy'))
--OR (i.D_FECPAR between to_date('27/12/2017','dd/mm/yyyy') and to_date('27/12/2018','dd/mm/yyyy'))
and i.C_ESTREG = 'A' --AND (I.AGENCIA_IDLLEGADA =17 OR I.AGENCIA_IDPARTIDA=17)
--and t.C_ESTREG = 'A' 
--and i.TIPITI_ID = 1 
AND I.N_ESANULADO = 0