SELECT p.pj AS 'PJ', p.numero_integracao AS 'PASTA',
(SELECT 
IF(p.sigla_integracao LIKE '%DS%', 'DS',
IF(p.sigla_integracao LIKE '%HRCA%', 'HRCA',
IF(p.sigla_integracao LIKE '%CCSP%', 'CCSP',
IF(p.sigla_integracao LIKE '%CCS%', 'CCS', 'VERIFICAR'))))
FROM cad_processo p
WHERE p.pj=p.pj
LIMIT 1) AS 'PARCEIRO',
 
p.sigla_integracao AS 'SUBPARCEIRO', cp.nome AS 'AUTOR',
cp.cpf_cnpj AS 'CPF', cc.nome AS 'REU', p.numero_processo AS 'NUMERO DO PROCESSO',
tm.descricao AS 'MATERIA', j.cidade AS 'CIDADE', t.descricao AS 'TEMA',
j.estado AS 'UF',

(select case t.evento
when 'INSS' then 'CLIENTES AFASTADOS'
when 'SUBST' then 'SUBSTITUIÇÃO'
when 'NA' then 'NÃO AJUIZAVEL'
when 'DNA' then 'NÃO AJUIZAVEL'
when 'AUDI' then 'AUDITORIA'
when 'RPET' then 'REDISTRIBUIÇÃO'
when 'RED' then 'REDISTRIBUIÇÃO'
when 'PET' then 'INICIAL'
end as evento
from tramitacao t
where t.id_processo=p.pj 
and t.evento in ('INSS','SUBST','NA','DNA','AUDI','RPET','RED','PET') 
and t.id_tramitacao_situacao<>2
order by t.id_tramitacao desc limit 1) AS 'STATUS',

(select e.descricao
from tramitacao t
left join tab_evento e on e.sigla=t.evento
where t.id_processo=p.pj
and t.evento in 
('INSS','SUBST','NA','DNA','AUDI','RPET','RED','PET') 
order by t.id_tramitacao desc
limit 1) AS 'ULTIMO EVENTO',

f.descricao AS 'FASE',

(select e.descricao
from tramitacao t
join tab_evento e on e.sigla=t.evento
where t.id_processo=p.pj
and t.evento in ('DDE')
limit 1) AS 'EVENTO PRINCIPAL',

(select t.data_hora_lan
from tramitacao t
left join tab_evento e on e.sigla=t.evento
where t.id_processo=p.pj
and t.evento in ('DDE')
order by t.data_hora_lan desc
limit 1) AS 'DATA DE ENTRADA',

p.z_justica AS 'COMPETÊNCIA',

(select te.cumprido_em
from tramitacao t 
left join tab_evento e on e.sigla=t.evento
left join tramitacao te on te.id_workflow_instancia=t.id_workflow_instancia
where t.id_processo=p.pj
and t.evento in ('PET')
and te.evento in ('PRTC')
and te.id_tramitacao_situacao in (1,9999)
order by t.data_hora_lan desc limit 1) AS 'PROTOCOLO DO PET'


FROM cad_processo p
LEFT JOIN cad_pessoa cp ON cp.codigo = p.primeiro_autor
LEFT JOIN cad_pessoa cc ON cc.codigo = p.primeiro_reu
LEFT JOIN tab_materia tm ON tm.codigo = p.materia 
LEFT JOIN tab_juizo j ON j.sigla = p.juizo
LEFT JOIN tab_tema t ON t.id_tema = p.id_tema
LEFT JOIN tab_fase f ON f.codigo = p.fase

