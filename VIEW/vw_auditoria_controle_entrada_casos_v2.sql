SELECT
  p.pj AS 'PJ',
  p.numero_integracao AS 'PASTA',

  /* (já aproveita e simplifica o PARCEIRO sem subselect) */
  CASE
    WHEN p.sigla_integracao LIKE '%DS%'   THEN 'DS'
    WHEN p.sigla_integracao LIKE '%HRCA%' THEN 'HRCA'
    WHEN p.sigla_integracao LIKE '%CCSP%' THEN 'CCSP'
    WHEN p.sigla_integracao LIKE '%CCS%'  THEN 'CCS'
    ELSE 'VERIFICAR'
  END AS 'PARCEIRO',

  p.sigla_integracao AS 'SUBPARCEIRO',
  cp.nome AS 'AUTOR',
  cp.cpf_cnpj AS 'CPF',
  cc.nome AS 'REU',
  p.numero_processo AS 'NUMERO DO PROCESSO',
  tm.descricao AS 'MATERIA',
  j.cidade AS 'CIDADE',
  t.descricao AS 'TEMA',
  j.estado AS 'UF',

  (select case tr.evento
      when 'INSS'  then 'CLIENTES AFASTADOS'
      when 'SUBST' then 'SUBSTITUIÇÃO'
      when 'NA'    then 'NÃO AJUIZAVEL'
      when 'DNA'   then 'NÃO AJUIZAVEL'
      when 'AUDI'  then 'AUDITORIA'
      when 'RPET'  then 'REDISTRIBUIÇÃO'
      when 'RED'   then 'REDISTRIBUIÇÃO'
      when 'PET'   then 'INICIAL'
   end
   from tramitacao tr
   where tr.id_processo = p.pj
     and tr.evento in ('INSS','SUBST','NA','DNA','AUDI','RPET','RED','PET')
     and tr.id_tramitacao_situacao <> 2
   order by tr.id_tramitacao desc
   limit 1) AS 'STATUS',

  (select e.descricao
   from tramitacao tr
   left join tab_evento e on e.sigla = tr.evento
   where tr.id_processo = p.pj
     and tr.evento in ('INSS','SUBST','NA','DNA','AUDI','RPET','RED','PET')
   order by tr.id_tramitacao desc
   limit 1) AS 'ULTIMO EVENTO',

  f.descricao AS 'FASE',

  /* agora NUNCA será NULL porque o JOIN exige DDE */
  'DATA DE ENTRADA' AS 'EVENTO PRINCIPAL',
  dde.data_entrada_dde AS 'DATA DE ENTRADA',

  p.z_justica AS 'COMPETÊNCIA',

  (select te.cumprido_em
   from tramitacao tr
   left join tramitacao te
     on te.id_workflow_instancia = tr.id_workflow_instancia
    and te.evento = 'PRTC'
    and te.id_tramitacao_situacao in (1,9999)
   where tr.id_processo = p.pj
     and tr.evento = 'PET'
   order by tr.data_hora_lan desc
   limit 1) AS 'PROTOCOLO DO PET'

FROM cad_processo p

/* 🔒 garante DDE (se não existe, nem entra no resultado) */
INNER JOIN (
  SELECT
    id_processo,
    MIN(data_hora_lan) AS data_entrada_dde
  FROM tramitacao
  WHERE evento = 'DDE'
  GROUP BY id_processo
) dde
  ON dde.id_processo = p.pj

LEFT JOIN cad_pessoa cp ON cp.codigo = p.primeiro_autor
LEFT JOIN cad_pessoa cc ON cc.codigo = p.primeiro_reu
LEFT JOIN tab_materia tm ON tm.codigo = p.materia
LEFT JOIN tab_juizo j ON j.sigla = p.juizo
LEFT JOIN tab_tema t ON t.id_tema = p.id_tema
LEFT JOIN tab_fase f ON f.codigo = p.fase;
