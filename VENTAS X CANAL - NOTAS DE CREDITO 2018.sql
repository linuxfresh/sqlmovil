SELECT vc.DIA,vc.MES,vc.ANUAL,vc.CANAL,vc.AGENCIA,(vc.VENTA-NVL(nc.VENTA,0)) VENTA, (vc.BOL-NVL(nc.BOL,0)) BOL
FROM
(SELECT * FROM (
/*************       VENTA POR AGENCIA          *************/
SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   'VENTANILLA' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA, COUNT(*) AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (1,3,7,2)  -- Boletos de viaje, recibos de caja, boletas y facturas
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (3)
AND vp.agencia_id<>69
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
UNION ALL
/*************    VENTA WEB    *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA WEB' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (5)  -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (4)
AND vp.agencia_id<>69
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
UNION ALL
/*************    VENTA POR AGENCIA VIRTUAL    *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'AGENCIA DE VIAJES' CANAL,-- e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (5)  -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (5)
AND vp.agencia_id<>69 AND vp.agencia_id<>67
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
UNION ALL
/*************    VENTA CORPORATIVA    *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA CORPORATIVA' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (6) -- Voucher Corporativo
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.agencia_id<>69 AND vp.agencia_id<>67
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
UNION ALL
/*************    VENTA ESSALUD  *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA ESSALUD' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN(6) -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (6) AND vp.agencia_id=67
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY cve.c_denominacion, 
--e.c_razsoc, 
a.c_denominacion  , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
UNION ALL
/*************    VENTA DELIVERY  *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA CALL CENTER' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (1)
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
) venta
ORDER BY venta.canal, venta.agencia) vc

LEFT JOIN

/*NOTAS DE CREDITO*/
(SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   'VENTANILLA' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA, COUNT(*) AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (8)  -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (3)
AND vp.agencia_id<>69
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy')
UNION ALL
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA CALL CENTER' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy') 
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND vp.canven_id in (1)
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy')
)nc
ON vc.dia||vc.mes||vc.anual||vc.canal||vc.agencia = nc.dia||nc.mes||nc.anual||nc.canal||nc.agencia

