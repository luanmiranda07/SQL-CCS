### consulta para buscar todos os cids do sistema ######

SELECT distinct
    TRIM(e.sigla) AS sigla,
    TRIM(e.descricao) AS descricao
FROM tab_evento e
WHERE TRIM(e.sigla) REGEXP '^[A-Z][0-9]{2}(\\.[0-9A-Z]{1,2}|[0-9A-Z]{0,2})$'
ORDER BY TRIM(e.sigla);