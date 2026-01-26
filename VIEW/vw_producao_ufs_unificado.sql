SELECT
    p.pj AS 'PJ',
    p.numero_integracao AS 'PASTA',
    p.sigla_integracao AS 'PARCEIRO',
    m.descricao AS 'MATERIA',
    pa.nome AS 'AUTOR',
    pr.nome AS 'REU',
    p.numero_processo AS 'NUMERO DO PROCESSO',
    jui.descricao AS 'ESTADO',

    ps.nome AS 'AGENDADO PARA',
    ep.descricao AS 'EVENTO PRINCIPAL',
    e.descricao AS 'SUBTAREFA',
    ts.descricao AS 'PROVIDENCIA',
    pat.nome AS 'RESPONSAVEL PELA TAREFA',
    u.nome AS 'CUMPRIDO POR',
    t.ag_data_hora AS 'DATA NA AGENDA',

    tp.ag_data_hora AS 'FATAL',
    t.id_tramitacao AS 'ID TRAMITACAO',
    t.texto AS 'COMPLEMENTO',
    t.justificativa AS 'JUSTIFICATIVA',
    t.cumprido_em AS 'DATA DO CUMPRIMENTO',
    tm.descricao AS 'MOTIVO'

FROM cad_processo p

-- pega UMA tramitacao (a mais recente) por processo, já filtrando pelos solicitados
LEFT JOIN tramitacao t
    ON t.id_tramitacao = (
        SELECT t2.id_tramitacao
        FROM tramitacao t2
        WHERE t2.id_processo = p.pj
          AND t2.id_pessoa_solicitada IN (12216,12218,12217,12219,12220,24761)
        ORDER BY t2.data_hora_lan DESC, t2.id_tramitacao DESC
        LIMIT 1
    )

LEFT JOIN tab_materia m ON m.codigo = p.materia
LEFT JOIN cad_pessoa pa ON pa.codigo = p.primeiro_autor
LEFT JOIN cad_pessoa pr ON pr.codigo = p.primeiro_reu
LEFT JOIN tab_juizo jui ON jui.sigla = p.juizo

LEFT JOIN cad_pessoa ps  ON ps.codigo  = t.id_pessoa_solicitada
LEFT JOIN tab_evento e   ON e.sigla    = t.evento
LEFT JOIN tramitacao_situacao ts ON ts.id_tramitacao_situacao = t.id_tramitacao_situacao
LEFT JOIN cad_pessoa pat ON pat.codigo = t.id_pessoa_atribuida
LEFT JOIN usuario u      ON u.id_usuario = t.cumprido_por

LEFT JOIN tramitacao_motivo tm ON tm.id_tramitacao_motivo = t.id_tramitacao_motivo

-- Evento principal = evento raiz do workflow (quando existir)
LEFT JOIN tramitacao tp ON tp.id_tramitacao = t.id_workflow_instancia
LEFT JOIN tab_evento ep ON ep.sigla = tp.evento

WHERE
    t.id_tramitacao IS NOT NULL

ORDER BY
    t.data_hora_lan DESC,
    p.pj DESC
-- LIMIT 100
;
