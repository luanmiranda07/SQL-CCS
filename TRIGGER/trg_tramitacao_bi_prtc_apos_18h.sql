BEGIN
    DECLARE v_existe_ep INT DEFAULT 0;
    DECLARE v_data_agendamento DATE;

    IF NEW.evento = 'PRTC'
       AND TIME(NEW.data_hora_lan) >= '18:00:00' THEN

        SELECT EXISTS (
            SELECT 1
            FROM tramitacao t_ep
            WHERE t_ep.id_tramitacao = NEW.id_workflow_instancia
              AND t_ep.evento = 'AP'
        )
        INTO v_existe_ep;

        IF v_existe_ep = 1 THEN

            /*
              Primeira tentativa de agendamento:
              sempre começa no próximo dia.
            */
            SET v_data_agendamento = DATE(NEW.data_hora_lan) + INTERVAL 1 DAY;

            /*
              Enquanto a data encontrada for:
              - sábado
              - domingo
              - feriado cadastrado na tabela dias_feriados

              ela soma +1 dia até encontrar uma data válida.
            */
            WHILE WEEKDAY(v_data_agendamento) IN (5, 6)
                  OR EXISTS (
                      SELECT 1
                      FROM dias_feriados df
                      WHERE df.`data` = v_data_agendamento
                  )
            DO
                SET v_data_agendamento = v_data_agendamento + INTERVAL 1 DAY;
            END WHILE;

            SET NEW.ag_data_hora = TIMESTAMP(v_data_agendamento, '00:00:00');

        END IF;

    END IF;
END