SELECT --e.c_nomcor   DSC_EMPRESA, 
r.c_origen   ORIGEN, r.c_destino  DESTINO,  TO_CHAR(v.d_fecpar,'dd/mm/yyyy') FECHA_VIAJE,  
v.c_horpar HORA_EMBARQUE,  I.C_HORPAR TURNO,        
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
--cv.c_NOMCOR CANAL_VENTA,
r.N_KILOMETROS KMS,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)) AS CAPACIDAD_BUS,
TO_CHAR(v.itinerario_id) NRO_PROGRAMACION,
count(*) BOL,
  
--v.c_numboleto NRO_BOLETO,  p.c_numdoc NRO_DNI,
sum(v.n_tarifa) PRECIO_TARIFA,  
sum(v.N_TARIFA+v.N_RECARGO+v.N_PENALIDAD-v.N_DESCUENTO) as  PRECIO_PAGO,  
--tdoc.C_DENOMINACION TIPO_DOCUMENTO,  TO_CHAR(v.n_numasiento) NRO_ASIENTO, DECODE(p.sexo_id,1,'FEMENINO',2,'MASCULINO') SEXO,  
  
--p.c_telefono TELEFONO,  
--us.c_apepat ||' '|| nvl(us.c_apemat,'') ||' '||us.c_nombre usuario,  
rm.c_origen ORIGEN_BUS,  
rm.c_destino DESTINO_BUS  
--p.c_nombre  nombre ,p.c_apepat paterno , p.c_apemat materno ,  
--ub.C_NOMBREUBIGEO DISTRITO,  
--tm.c_denominacion MOVIMIENTO,
  
FROM VRTVENPAS v    
inner join ( select max(venpas_id)venpas_id, c_numcontrol  from vrtvenpas  group by c_numcontrol ) max_venta on max_venta.venpas_id=v.venpas_id  
--inner join vrmempresa    e   on e.empresa_id    = v.empresa_id    
inner join vrmruta       r   on r.ruta_id       = v.ruta_id  
inner join vrtitinerario i   on i.itinerario_id = v.itinerario_id  
inner join vrmservicio   s   on s.servicio_id   = i.servicio_id  
--inner join vrmagencia   ofi  on ofi.agencia_id  = v.agencia_id   
--inner join vrmpasajero   p   on p.pasajero_id   = v.pasajero_id  
--inner join vrmtipdoc    tdoc on tdoc.tipdoc_id  = p.tipdoc_id  
inner join vrmruta      rm   on rm.ruta_id      = i.ruta_idmayor  
--inner join vrmubigeo    ub   on ub.ubigeo_id    = p.ubigeo_id     
--inner join vrmusuario   us   on us.usuario_id   = v.usuario_id     
INNER JOIN VRMCANVEN    cv   on cv.canven_id    = v.canven_id  
--inner join vrmtipmov    tm  on tm.tipmov_id    = v.tipmov_id      
where v.tipmov_id not in( 5,6,13,14)   
AND v.c_estreg='A'  
and v.d_fecpar between to_date('01/10/2019','dd/mm/yyyy') and to_date('15/10/2019','dd/mm/yyyy')  
and v.agencia_id <> 69 --and r.c_destino='AREQUIPA'
--and r.RUTA_ID in (627,628)

and ((rm.c_origen ='CARAZ' and rm.c_destino='LIMA') or (rm.c_origen ='LIMA' and rm.c_destino='CARAZ'))
--and v.ITINERARIO_ID = '79513'
GROUP BY
r.c_origen, r.c_destino,  rm.c_origen,  
rm.c_destino, 
TO_CHAR(v.d_fecpar,'dd/mm/yyyy'),  
v.c_horpar,I.C_HORPAR,    

S.C_NOMCOR, 
--cv.c_NOMCOR,
TO_CHAR(v.itinerario_id),
r.N_KILOMETROS,
(S.N_NUMASIPIS1 + NVL(S.N_NUMASIPIS2,0)),
TO_CHAR(v.itinerario_id)

ORDER BY COUNT(*) DESC