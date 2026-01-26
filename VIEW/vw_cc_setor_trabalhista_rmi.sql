SELECT
    p.pj                                                 AS 'PJ',
    p.numero_integracao                                  AS 'PASTA',
    p.sigla_integracao                                   AS 'PARCEIRO',
    pa.nome                                              AS 'AUTOR',
    pr.nome                                              AS 'REU',
    p.numero_processo                                    AS 'NUMERO DO PROCESSO',
    pa.estado                                            AS 'ESTADO',

 (SELECT t.cumprido_em
 FROM tramitacao t
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'DATA DO CUMPRIMENTO',

 (SELECT resp.nome 
 FROM tramitacao t
 LEFT JOIN cad_pessoa resp
    ON resp.codigo = t.id_pessoa_atribuida
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'RESPONSAVEL PELA TAREFA',

 (SELECT u.nome
 FROM tramitacao t
 LEFT JOIN usuario u ON u.id_usuario = t.update_usuario 
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'ATUALIZADO POR',

 (SELECT te.descricao 
 FROM tramitacao t 
 LEFT JOIN tramitacao tp ON tp.id_workflow_instancia = t.id_workflow_instancia
 LEFT JOIN tab_evento te ON te.sigla = tp.evento 
 WHERE t.id_processo = p.pj 
 ORDER BY t.data_hora_lan DESC
 LIMIT 1) AS 'EVENTO PRINCIPAL',

 (SELECT ste.descricao 
 FROM tramitacao t
 LEFT JOIN tab_evento ste
    ON ste.sigla = t.evento
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'SUBTAREFA',

 (SELECT ts.descricao 
 FROM tramitacao t 
 LEFT JOIN tramitacao_situacao ts 
 ON ts.id_tramitacao_situacao = t.id_tramitacao_situacao 
 WHERE t.id_processo = p.pj 
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1 ) AS 'PROVIDENCIA',

 (SELECT u.nome
 FROM tramitacao t
 LEFT JOIN usuario u ON u.id_usuario = t.cumprido_por
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC
 LIMIT 1) AS 'CUMPRIDO POR',

 (SELECT t.ag_data_hora 
 FROM tramitacao t
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'DATA DA AGENDA',
 
 (SELECT td.ag_data_hora 
 FROM tramitacao t 
 LEFT JOIN tramitacao td 
 ON td.id_tramitacao = t.id_workflow_instancia 
 WHERE t.id_processo = p.pj 
 ORDER BY t.data_hora_lan DESC 
 LIMIT 1) AS 'DATA FATAL',
 
 
 (SELECT t.id_tramitacao 
 FROM tramitacao t
 WHERE t.id_processo = p.pj
 ORDER BY t.data_hora_lan DESC
 LIMIT 1) AS 'ID Tramitacao'
 
 
FROM cad_processo p
LEFT JOIN cad_pessoa pa
       ON pa.codigo = p.primeiro_autor
       
LEFT JOIN cad_pessoa pr
       ON pr.codigo = p.primeiro_reu

WHERE p.materia = 5