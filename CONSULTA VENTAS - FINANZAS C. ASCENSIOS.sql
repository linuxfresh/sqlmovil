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
       case V.TIPMOV_ID when 13 then 0
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
where to_date(v.d_fecvent,'dd/mm/yyyy') between to_date('01/08/2019','dd/MM/yyyy') and to_date('31/08/2019','dd/MM/yyyy')  -- CAMBIAR RANGO FECHA
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
                                             between to_date('01/08/2019','dd/MM/yyyy') -- CAMBIAR RANGO FECHA
                                             and     to_date('31/08/2019','dd/MM/yyyy')  -- CAMBIAR RANGO FECHA
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



--ANULADOS

union all

select nvl(V.VENPAS_ID,0) AS IDFACTURA,
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
       case V.TIPMOV_ID
            when 13 then 0
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
inner  join vrmempresa e
on     e.empresa_id = v.empresa_id

inner  join vrmruta r
on     r.ruta_id = v.ruta_id

inner  join vrtitinerario i
on     i.itinerario_id = v.itinerario_id

inner  join vrmagencia ofi
on     ofi.agencia_id = v.agencia_id
and    ofi.tipage_id = 1  /*solo movil*/
LEFT JOIN VRMCONCESIONARIO CO ON CO.C_RUC=V.C_RUCCLICRE
LEFT JOIN VRMAGENCIA AG ON AG.CONCESIONARIO_ID=CO.CONCESIONARIO_ID
inner  join vrmusuario us
on     us.usuario_id = v.usuario_id

inner  join vrmtipmov tm
on     tm.tipmov_id = v.tipmov_id

inner  join vrmcanven
on     v.canven_id = vrmcanven.canven_id

inner  join vrmforpag
on     v.forpag_id = vrmforpag.forpag_id

inner  join vrmtipforpag
on     v.tipforpag_id = vrmtipforpag.tipforpag_id

inner  join vrmtipcom tipo_comprobante
on     v.tipcom_id = tipo_comprobante.tipcom_id

left  join vrmcliente clientes
on    v.c_rucclicre = clientes.c_numdoc

where to_date(v.d_fecvent,'dd/mm/yyyy') between to_date('01/09/2019','dd/MM/yyyy') and to_date('10/09/2019','dd/MM/yyyy') -- CAMBIAR RANGO FECHA
and   v.c_tiptra in (1,3)
and   v.tipmov_id in (13)
and   v.venpas_id in (select max(vm.venpas_id)
                      from   vrtvenpas vm
                      inner  join vrmempresa em
                      on     em.empresa_id = vm.empresa_id
                      inner  join vrmruta rm
                      on     rm.ruta_id = vm.ruta_id
                      inner  join vrtitinerario im
                      on     im.itinerario_id = vm.itinerario_id
                      inner  join vrmagencia ofim
                      on     ofim.agencia_id = vm.agencia_id
                      and    ofim.tipage_id = 1
                      inner  join vrmusuario usm
                      on     usm.usuario_id = vm.usuario_id
                      inner  join vrmtipmov tmm
                      on     tmm.tipmov_id = vm.tipmov_id
                      inner  join vrmcanven vcvm
                      on     vm.canven_id = vcvm.canven_id
                      inner  join vrmforpag vfpm
                      on     vm.forpag_id = vfpm.forpag_id
                      inner  join vrmtipforpag vtfpm
                      on     vm.tipforpag_id = vtfpm.tipforpag_id
                      inner  join vrmtipcom tcm
                      on     vm.tipcom_id = tcm.tipcom_id
                      left   join vrmcliente cm
                      on     vm.c_rucclicre = cm.c_numdoc
                      where  vm.c_tiptra in (1,3)
                      and    vm.tipmov_id = 13
                      and     to_date(vm.d_fecvent,'dd/mm/yyyy')
                      between to_date('01/09/2019','dd/MM/yyyy') -- CAMBIAR RANGO FECHA
                      and     to_date('10/09/2019','dd/MM/yyyy') -- CAMBIAR RANGO FECHA
                      and     vm.c_numboleto is not null
                      and     trim(vm.c_numboleto) = trim(v.c_numboleto)
                      and   v.tipcom_id in (1,2,7,8,15)
                      and   vm.c_Estreg = 'A'
                      and   em.empresa_id = 1 -- CAMBIAR EMPRESA
                     and   v.agencia_id NOT IN (69,259)
                    --  and   vm.c_numboleto not in ('064-0028838','064-0028839')
                      and   substr(lpad(substr(vm.c_numboleto,1,instr(vm.c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-'))
and   v.tipcom_id in (1,2,7,8,15)
and   v.c_Estreg = 'A'
and   e.empresa_id = 1  -- CAMBIAR EMPRESA
and   v.agencia_id NOT IN (69,259)
and   c_numboleto not in ('FB14-00003287')
and   substr(lpad(substr(c_numboleto,1,instr(c_numboleto,'-',1)-1),3,'0'),1,1) not in ('9','-')--) a;
