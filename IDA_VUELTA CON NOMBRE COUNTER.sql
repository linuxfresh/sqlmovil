SELECT DIA,MES,ANUAL,CANAL, AGENCIA, IDA_VUELTA,C_NOMBRE||' '||C_APEPAT||' '||C_APEMAT,SUM(VENTA) VENTA, COUNT(BOL) BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   decode(VP.N_IDARET,1,'ida_vuelta',0,'ida') ida_vuelta,US.C_APEPAT,US.C_APEMAT,US.C_NOMBRE,
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
INNER JOIN VRMUSUARIO US ON US.USUARIO_ID=vp.USUARIO_ID
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
DIA,MES,ANUAL,CANAL,AGENCIA,IDA_VUELTA,C_NOMBRE||' '||C_APEPAT||' '||C_APEMAT
HAVING CANAL = 'VENTANILLA'




UNION ALL

SELECT DIA,MES,ANUAL,CANAL, AGENCIA, IDA_VUELTA,-1*SUM(VENTA) VENTA, 0 BOL
FROM
(

SELECT  to_char(vp.d_fecvent,'dd') DIA , to_char(vp.d_fecvent,'mm') MES ,  to_char(vp.d_fecvent,'yyyy') ANUAL ,   decode(VP.N_IDARET,1,'ida_vuelta',0,'ida') ida_vuelta,
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
DIA,MES,ANUAL,CANAL,AGENCIA,IDA_VUELTA
HAVING CANAL = 'VENTANILLA'
