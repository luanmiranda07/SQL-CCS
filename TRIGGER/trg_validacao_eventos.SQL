DROP TRIGGER IF EXISTS trg_validacao_eventos;
DELIMITER $$

CREATE TRIGGER trg_validacao_eventos
BEFORE INSERT ON tramitacao
FOR EACH ROW
BEGIN
    DECLARE v_pj INT;

    SELECT cp.pj
      INTO v_pj
      FROM cad_processo cp
     WHERE cp.pj = NEW.id_processo
     LIMIT 1;

    IF v_pj IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
              FROM pj_bloqueado_evento p
             WHERE p.pj = v_pj
               AND p.ativo = 1
        )
        AND EXISTS (
            SELECT 1
              FROM evento_bloqueado e
             WHERE e.evento = NEW.evento
               AND e.ativo = 1
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Evento bloqueado para este PJ.';
        END IF;
    END IF;
END$$

DELIMITER ;