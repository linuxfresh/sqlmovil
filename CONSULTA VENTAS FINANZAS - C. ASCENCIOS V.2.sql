alter session set nls_date_format = 'DD/MM/YYYY';

select nombre_agencia,fecha_documento,canal,TIPCOM_DESCRIPCION,TIPO_MOVIMIENTO_DESCRIPCION,CANAL_VENTA,count(*) Cantidad_Registros,
       sum(total) Suma_Total
from   (
select nvl(V.VENPAS_ID,0) AS IDFACTURA,vrmcanven.C_NOMCOR AS CANAL_VENTA,
       NVL(V.AGENCIA_ID,0) AS IDAGENCIAS,
       ofi.c_denominacion NOMBRE_AGENCIA,
       TO_CHAR(V.D_FECVENT,'dd/mm/yyyy') AS FECHA_DOCUMENTO,
       NVL(V.TIPCOM_ID,0) TIPCOMPROB_ID,
       TIPO_COMPROBANTE.C_DENOMINACION AS TIPCOM_DESCRIPCION,
       LPAD(SUBSTR(C_NUMBOLETO,1,INSTR(C_NUMBOLETO,'-',1)-1),4,'0') || '-' || SUBSTR(C_NUMBOLETO,INSTR(C_NUMBOLETO,'-',1)+1,15) AS DOCUMENTO,
       LPAD(SUBSTR(c_numbolant,1,INSTR(c_numbolant,'-',1)-1),4,'0') || '-' || SUBSTR(c_numbolant,INSTR(c_numbolant,'-',1)+1,15) AS DOCUMENTO_AFECTA,
       V.C_RUCCLICRE,
       case 
          when v.c_rucclicre='20547391501' then 'BUS PORTAL'
          when v.c_rucclicre='20555893052' then 'ALIGNET'
          when v.c_rucclicre='20603315031' then 'RECORRIDO PERU'
          when v.c_rucclicre='20131257750' then 'ESSALUD'
        --  when v.agencia_id=345 then 'ORBIS'  
          when AG.tipage_id = 2 then 'AGENCIA DE VIAJES'  
          when AG.tipage_id = 3 then 'CLIENTE CORPORATIVO' 
          when V.TIPFORPAG_ID = 12 then 'ORBIS'
          when V.TIPFORPAG_ID = 13 then 'PAGOLINK'
          when V.TIPFORPAG_ID = 6 then 'DEPOSITO'    
          ELSE 'MOVIL'  
       end AS CANAL,       
       case when V.TIPMOV_ID = 13 then 0
						 when V.TIPCOM_ID = 8 then NVL(-1*V.n_imppag,0)
                       else NVL(V.n_imppag,0)
       end AS TOTAL,
       V.FORPAG_ID,
       VRMFORPAG.C_DENOMINACION AS FORMA_PAGO_DESCRIPCION,
       V.TIPFORPAG_ID,
       VRMTIPFORPAG.C_DENOMINACION AS TIPFORPAG_DESCRIPCION,
       V.TIPMOV_ID,
       tm.C_DENOMINACION AS TIPO_MOVIMIENTO_DESCRIPCION,
       V.EMPRESA_ID,V.AUDFECINS,V.AUDFECMOD

FROM   VRTVENPAS V
inner  join vrmempresa e on     e.empresa_id = v.empresa_id
inner  join vrmruta r on     r.ruta_id = v.ruta_id
inner  join vrtitinerario i on     i.itinerario_id = v.itinerario_id
inner  join vrmagencia ofi on     ofi.agencia_id = v.agencia_id and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=V.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
inner  join vrmusuario us on     us.usuario_id = v.usuario_id
inner  join vrmtipmov tm on     tm.tipmov_id = v.tipmov_id
inner  join vrmcanven on     v.canven_id = vrmcanven.canven_id
inner  join vrmforpag on     v.forpag_id = vrmforpag.forpag_id
inner  join vrmtipforpag on     v.tipforpag_id = vrmtipforpag.tipforpag_id
inner  join vrmtipcom tipo_comprobante on v.tipcom_id = tipo_comprobante.tipcom_id
where to_date(v.d_fecvent,'dd/mm/yyyy') between to_date('01/10/2019','dd/MM/yyyy') and to_date('13/10/2019','dd/MM/yyyy')  -- CAMBIAR RANGO FECHA
and   v.c_tiptra in (1,3)
and   v.tipmov_id not in (5,6)
and   v.venpas_id not in (select distinct venpas_id
                            from vrtvenpas
                           where v.tipmov_id in (1,2,3,4,7,8,9,12,14)
                             and v.n_imppag = 0.00
                             and v.forpag_id<>3
                             )
and   ltrim(rtrim(v.c_numboleto)) not in (select distinct ltrim(rtrim(c_numboleto))
                                             from    vrtvenpas
                                             where   tipmov_id = 13
                                             and     to_date(d_fecvent,'dd/mm/yyyy')
                                             between to_date('01/10/2019','dd/MM/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date('13/10/2019','dd/MM/yyyy')  -- CAMBIAR RANGO FECHA
                                             and     empresa_id = 1--POR EMPRESA
                                             and     c_numboleto is not null)
and   v.tipcom_id in (1,2,7,8,15)
and   v.c_Estreg = 'A'
and   e.empresa_id =1 --POR EMPRESA
and   v.agencia_id NOT IN (69,259) 
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')

)

GROUP BY nombre_agencia,fecha_documento,canal,TIPCOM_DESCRIPCION,TIPO_MOVIMIENTO_DESCRIPCION,CANAL_VENTA

