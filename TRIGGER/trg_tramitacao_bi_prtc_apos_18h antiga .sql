BEGIN
    DECLARE v_existe_ep INT DEFAULT 0;

    /*
      Nova regra:
      - quando lançar uma tarefa PRTC
      - e o lançamento ocorrer a partir das 18h
      - e o workflow principal da instância for um evento AP
      então reagenda o ag_data_hora conforme o dia da semana:
      
      Regras de reagendamento:
      - se o lançamento ocorrer na sexta-feira, agenda para segunda-feira (+3 dias)
      - se o lançamento ocorrer no sábado, agenda para segunda-feira (+2 dias)
      - nos demais dias, agenda para o próximo dia (+1 dia)
      
      Observação:
      - domingo entra no ELSE e também vai para segunda-feira
      - o horário final do agendamento fica em 00:00:00
    */
    IF NEW.evento = 'PRTC'
       AND TIME(NEW.data_hora_lan) >= '18:00:00' THEN

      
        SELECT COUNT(1)
          INTO v_existe_ep
          FROM tramitacao t_ep
         WHERE t_ep.id_tramitacao = NEW.id_workflow_instancia
           AND t_ep.evento = 'AP';

     
        IF v_existe_ep > 0 THEN
            SET NEW.ag_data_hora = CASE
                /* Sexta-feira: joga para segunda-feira */
                WHEN WEEKDAY(NEW.data_hora_lan) = 4 THEN TIMESTAMP(DATE(NEW.data_hora_lan) + INTERVAL 3 DAY)

                /* Sábado: joga para segunda-feira */
                WHEN WEEKDAY(NEW.data_hora_lan) = 5 THEN TIMESTAMP(DATE(NEW.data_hora_lan) + INTERVAL 2 DAY)

                /* Demais dias: joga para o próximo dia */
                ELSE TIMESTAMP(DATE(NEW.data_hora_lan) + INTERVAL 1 DAY)
            END;
        END IF;

    END IF;
END