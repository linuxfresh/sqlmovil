--SELECT vc.DIA,vc.MES,vc.ANUAL,vc.CANAL,vc.AGENCIA,(vc.VENTA-NVL(nc.VENTA,0)) VENTA, (vc.BOL-NVL(nc.BOL,0)) BOL
--FROM
--(

--SELECT * FROM (
/*************       VENTA POR AGENCIA          *************/
SELECT DIA,MES,ANUAL,CANAL, AGENCIA, SUM(VENTA) VENTA, COUNT(BOL) BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   
case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when vp.c_rucclicre='20131257750' then 'ESSALUD'
        --  when vp.agencia_id=345 then 'ORBIS'  
          when AG.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when AG.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when vp.TIPFORPAG_ID = 12 then 'ORBIS'
          when vp.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when vp.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'VENTANILLA'  
       end AS CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, vp.n_imppag VENTA, 1 AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')


 --AND vp.c_rucclicre NOT IN ('20547391501','20555893052','20603315031','20131257750')
 --AND AG.tipage_id NOT IN (2,3)
 --AND vp.TIPFORPAG_ID NOT IN (12,13,6) 
 
 --AND vp.c_rucclicre<>'20547391501' AND vp.c_rucclicre<>'20555893052' AND vp.c_rucclicre <> '20603315031' AND vp.c_rucclicre<>'20131257750'
	--AND AG.tipage_id <> 2 AND AG.tipage_id <> 3
	--AND vp.TIPFORPAG_ID<>12 AND vp.TIPFORPAG_ID<>13 AND vp.TIPFORPAG_ID<>6
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy')  -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259,345) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

)

GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA
HAVING CANAL = 'VENTANILLA'

UNION ALL
/*************    VENTA WEB    *************/
SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA WEB' CANAL, --e.c_razsoc EMPRESA, 

case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
					end as AGENCIA, 


SUM(vp.n_imppag) VENTA , COUNT(*) AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (2,7)  -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND (vp.c_rucclicre='20547391501'  OR vp.c_rucclicre='20555893052' OR vp.c_rucclicre='20603315031')
AND vp.agencia_id<>69 and vp.agencia_id<>345
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
vp.c_rucclicre,to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 

UNION ALL

/*************    VENTA POR AGENCIA VIRTUAL    *************/
SELECT DIA,MES,ANUAL,CANAL, AGENCIA, SUM(VENTA) VENTA, COUNT(BOL) BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   
case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when vp.c_rucclicre='20131257750' then 'ESSALUD'
        --  when vp.agencia_id=345 then 'ORBIS'  
          when AG.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when AG.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when vp.TIPFORPAG_ID = 12 then 'ORBIS'
          when vp.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when vp.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'VENTANILLA'  
       end AS CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, vp.n_imppag VENTA, 1 AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')


 --AND vp.c_rucclicre NOT IN ('20547391501','20555893052','20603315031','20131257750')
 --AND AG.tipage_id NOT IN (2,3)
 --AND vp.TIPFORPAG_ID NOT IN (12,13,6) 
 
 --AND vp.c_rucclicre<>'20547391501' AND vp.c_rucclicre<>'20555893052' AND vp.c_rucclicre <> '20603315031' AND vp.c_rucclicre<>'20131257750'
	--AND AG.tipage_id <> 2 AND AG.tipage_id <> 3
	--AND vp.TIPFORPAG_ID<>12 AND vp.TIPFORPAG_ID<>13 AND vp.TIPFORPAG_ID<>6
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy')  -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259,345) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

)

GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA
HAVING CANAL = 'AGENCIA DE VIAJES'

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
and A.tipage_id = 3
--AND vp.tipcom_id IN (6) -- Voucher Corporativo
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
WHERE vp.c_tiptra=1 AND vp.c_rucclicre='20131257750'
--when vp.c_rucclicre='20131257750' then 'ESSALUD'
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

GROUP BY cve.c_denominacion, 
--e.c_razsoc, 
a.c_denominacion  , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 

UNION ALL
/*************    VENTA CALL CENTER  *************/
SELECT DIA,MES,ANUAL,CANAL, AGENCIA, SUM(VENTA) VENTA, COUNT(BOL) BOL
FROM
(

SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA CALL CENTER' CANAL, --e.c_razsoc EMPRESA, 

case 
					when VP.c_rucclicre='20547391501' then 'BUS PORTAL'
          when VP.c_rucclicre='20555893052' then 'DELIVERY'
          when VP.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when VP.c_rucclicre='20131257750' then 'ESSALUD'
        --  when VP.agencia_id=345 then 'ORBIS'  
          when A.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when A.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when VP.TIPFORPAG_ID = 12 then 'PAGOEFECTIVO'
          when VP.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when VP.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'DELIVERY'  
       end AS AGENCIA,       

--a.c_denominacion AGENCIA, 

vp.n_imppag VENTA , 1 BOL
FROM vrtvenpas vp
--INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA A ON A.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
--INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
--INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=1
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
--AND vp.canven_id in (1)
AND vp.agencia_id=345
AND vp.ruta_id not in (594, 602, 629,630)
--GROUP BY --e.c_razsoc, 
--a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
--) venta
--ORDER BY venta.canal, venta.agencia--) vc
)
GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA
--) venta
--ORDER BY venta.canal, venta.agencia--) vc

--LEFT JOIN

/*NOTAS DE CREDITO*/
--(
UNION ALL 

SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA WEB' CANAL, --e.c_razsoc EMPRESA, 

case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
					end as AGENCIA, 


-1*SUM(vp.n_imppag) VENTA , 0 AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipcom_id IN (8)  -- Boletos de viaje y recibos de caja
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
AND (vp.c_rucclicre='20547391501'  OR vp.c_rucclicre='20555893052' OR vp.c_rucclicre='20603315031')
AND vp.agencia_id<>69 and vp.agencia_id<>345
AND vp.ruta_id not in (594, 602, 629,630)
GROUP BY --e.c_razsoc, 
vp.c_rucclicre,to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 

UNION ALL

SELECT DIA,MES,ANUAL,CANAL, AGENCIA, -1*SUM(VENTA) VENTA, 0 BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   
case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when vp.c_rucclicre='20131257750' then 'ESSALUD'
        --  when vp.agencia_id=345 then 'ORBIS'  
          when AG.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when AG.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when vp.TIPFORPAG_ID = 12 then 'ORBIS'
          when vp.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when vp.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'VENTANILLA'  
       end AS CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, vp.n_imppag VENTA, 1 AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')


 --AND vp.c_rucclicre NOT IN ('20547391501','20555893052','20603315031','20131257750')
 --AND AG.tipage_id NOT IN (2,3)
 --AND vp.TIPFORPAG_ID NOT IN (12,13,6) 
 
 --AND vp.c_rucclicre<>'20547391501' AND vp.c_rucclicre<>'20555893052' AND vp.c_rucclicre <> '20603315031' AND vp.c_rucclicre<>'20131257750'
	--AND AG.tipage_id <> 2 AND AG.tipage_id <> 3
	--AND vp.TIPFORPAG_ID<>12 AND vp.TIPFORPAG_ID<>13 AND vp.TIPFORPAG_ID<>6
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy')  -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259,345) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

)

GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA
HAVING CANAL = 'VENTANILLA'

UNION ALL

/*************    VENTA CALL CENTER  *************/
SELECT DIA,MES,ANUAL,CANAL, AGENCIA, -1*SUM(VENTA) VENTA, 0 BOL
FROM
(

SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA CALL CENTER' CANAL, --e.c_razsoc EMPRESA, 

case 
          when VP.c_rucclicre='20547391501' then 'BUS PORTAL'
          when VP.c_rucclicre='20555893052' then 'DELIVERY'
          when VP.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when VP.c_rucclicre='20131257750' then 'ESSALUD'
        --  when VP.agencia_id=345 then 'ORBIS'  
          when A.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when A.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when VP.TIPFORPAG_ID = 12 then 'PAGOEFECTIVO'
          when VP.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when VP.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'DELIVERY'  
       end AS AGENCIA,       

--a.c_denominacion AGENCIA, 

vp.n_imppag VENTA , 1 BOL
FROM vrtvenpas vp
--INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA A ON A.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
--INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
--INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
AND vp.tipmov_id not in (5, 6, 12, 13)  --menos anulados automaticos, devoluciones, prepagados, anulados
--AND vp.canven_id in (1)
AND vp.agencia_id=345
AND vp.ruta_id not in (594, 602, 629,630)
--GROUP BY --e.c_razsoc, 
--a.c_denominacion , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy') 
--) venta
--ORDER BY venta.canal, venta.agencia--) vc
)
GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA

UNION ALL

SELECT to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL , 'VENTA ESSALUD' CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, -1*SUM(vp.n_imppag) VENTA , 0 AS BOL
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
INNER JOIN vrmcanven cve ON cve.canven_id=vp.canven_id
WHERE vp.c_tiptra=3 AND vp.c_rucclicre='20131257750'
--when vp.c_rucclicre='20131257750' then 'ESSALUD'
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

GROUP BY cve.c_denominacion, 
--e.c_razsoc, 
a.c_denominacion  , to_char(vp.d_fecvent,'dd') , to_char(vp.d_fecvent,'mm') , to_char(vp.d_fecvent,'yyyy')

UNION ALL

SELECT DIA,MES,ANUAL,CANAL, AGENCIA, -1*SUM(VENTA) VENTA, 0 BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   
case 
          when vp.c_rucclicre='20547391501' then 'BUS PORTAL'
          when vp.c_rucclicre='20555893052' then 'ALIGNET'
          when vp.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when vp.c_rucclicre='20131257750' then 'ESSALUD'
        --  when vp.agencia_id=345 then 'ORBIS'  
          when AG.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when AG.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when vp.TIPFORPAG_ID = 12 then 'ORBIS'
          when vp.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when vp.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'VENTANILLA'  
       end AS CANAL, --e.c_razsoc EMPRESA, 
a.c_denominacion AGENCIA, vp.n_imppag VENTA, 1 AS BOL-- vp.venpas_id, vp.c_numboleto, vp.n_imppag, vp.d_fecliq, vp.tipmov_id
FROM vrtvenpas vp
INNER JOIN vrmagencia a ON (vp.agencia_id = a.agencia_id)
INNER JOIN vrmempresa e on e.empresa_id=vp.empresa_id
inner  join vrmagencia ofi on     ofi.agencia_id = vp.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=VP.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
WHERE vp.c_tiptra=3
AND to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date([$fini], 'dd/mm/yyyy') AND to_date([$ffin], 'dd/mm/yyyy')


 --AND vp.c_rucclicre NOT IN ('20547391501','20555893052','20603315031','20131257750')
 --AND AG.tipage_id NOT IN (2,3)
 --AND vp.TIPFORPAG_ID NOT IN (12,13,6) 
 
 --AND vp.c_rucclicre<>'20547391501' AND vp.c_rucclicre<>'20555893052' AND vp.c_rucclicre <> '20603315031' AND vp.c_rucclicre<>'20131257750'
	--AND AG.tipage_id <> 2 AND AG.tipage_id <> 3
	--AND vp.TIPFORPAG_ID<>12 AND vp.TIPFORPAG_ID<>13 AND vp.TIPFORPAG_ID<>6
and   vp.tipmov_id not in (5,6)
and   vp.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where vp.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and vp.n_imppag = 0.00
                             and vp.forpag_id<>3
                             )
and   ltrim(rtrim(vp.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date([$fini], 'dd/mm/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date([$ffin], 'dd/mm/yyyy')  -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   vp.tipcom_id in (1,2,7,8,15)
and   vp.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   vp.agencia_id NOT IN (69,259,345) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

)

GROUP BY --e.c_razsoc, 
DIA,MES,ANUAL,CANAL,AGENCIA
HAVING CANAL = 'AGENCIA DE VIAJES'


--)nc
--ON vc.dia = nc.dia and vc.mes = nc.mes and vc.anual = nc.anual and vc.canal = nc.canal and vc.agencia = nc.agencia


