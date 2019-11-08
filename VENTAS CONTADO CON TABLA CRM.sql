select --cv.c_denominacion canal,
crm.FUNCIONARIO,c.c_razsoc CLIENTE, c.c_numdoc RUC, sum(n_imppag) IMPORTE,to_char(vp.d_fecvent,'MONTH') MES
from vrtvenpas vp 
inner join vrmcliente c on c.cliente_id=vp.cliente_id
INNER JOIN VRMCANVEN cv ON cv.CANVEN_ID = vp.CANVEN_ID
INNER JOIN TMP_RUCS crm ON crm.RUC = c.c_numdoc
where 
--c.c_numdoc in (SELECT RUC FROM TMP_RUCS

      /*,
      '20422293699'*/--) and 
to_date(to_char(vp.d_fecvent,'dd/mm/yyyy'),'dd/mm/yyyy') BETWEEN to_date('01/10/2019', 'dd/mm/yyyy') AND to_date('31/10/2019', 'dd/mm/yyyy') and vp.c_rucclicre is null
and tipcom_id in (1,2,7) and tipmov_id not in (5,13)
group by --cv.c_denominacion,
crm.FUNCIONARIO,c.c_razsoc, c.c_numdoc, to_char(vp.d_fecvent,'MONTH')
order by c.c_razsoc



