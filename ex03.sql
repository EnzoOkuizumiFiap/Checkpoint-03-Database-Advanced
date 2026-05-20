/*
========================================================
EXERCÍCIO 3 — Procedure: pedidos de um período

Autor(es): Gustavo Okada
RM: 563428
Data: 17/05/2026

Descrição:
Gera um relatório dos pedidos realizados em um intervalo
de datas específico, utilizando um cursor explícito.
Valida se as datas informadas formam um período válido.

Parâmetros:
- p_data_ini (IN DATE): Data inicial do período
- p_data_fim (IN DATE): Data final do período
========================================================
*/

CREATE OR REPLACE PROCEDURE cp3_pr_listar_pedidos_periodo (
    p_data_ini IN DATE,
    p_data_fim IN DATE
)

IS
    -- Exceção customizada: intervalo de datas inválido
    ex_periodo_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_periodo_invalido, -20001);

    -- Cursor explícito: percorre pedidos do período
    CURSOR cur_pedidos IS
        SELECT p.pedido_id,
               p.data_pedido,
               c.nome   AS nome_cliente,
               p.status
          FROM cp3_pedido  p
          JOIN cp3_cliente c ON c.cliente_id = p.cliente_id
         WHERE p.data_pedido BETWEEN p_data_ini AND p_data_fim + 1 - 1/86400
         ORDER BY p.data_pedido;

    -- Variável de linha do cursor usando %ROWTYPE
    v_reg cur_pedidos%ROWTYPE;
    v_total NUMBER := 0;

BEGIN
    -- Validação: data final deve ser >= data inicial
    IF p_data_fim < p_data_ini THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Período inválido: p_data_fim (' ||
            TO_CHAR(p_data_fim, 'DD/MM/YYYY') ||
            ') é anterior a p_data_ini (' ||
            TO_CHAR(p_data_ini, 'DD/MM/YYYY') || ').'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('=================================================');
    DBMS_OUTPUT.PUT_LINE('PEDIDOS DE ' || TO_CHAR(p_data_ini, 'DD/MM/YYYY') ||
                         ' A '        || TO_CHAR(p_data_fim,  'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('=================================================');

    OPEN cur_pedidos;

    LOOP
        FETCH cur_pedidos INTO v_reg;
        EXIT WHEN cur_pedidos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Pedido #' || v_reg.pedido_id                      ||
            ' | Data: '  || TO_CHAR(v_reg.data_pedido, 'DD/MM/YYYY') ||
            ' | Cliente: ' || v_reg.nome_cliente               ||
            ' | Status: '  || v_reg.status
        );

        v_total := v_total + 1;
    END LOOP;

    CLOSE cur_pedidos;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de pedidos encontrados: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('=================================================');

EXCEPTION
    WHEN OTHERS THEN
        -- Garante o fechamento do cursor em caso de erro inesperado
        IF cur_pedidos%ISOPEN THEN
            CLOSE cur_pedidos;
        END IF;
        RAISE;
END cp3_pr_listar_pedidos_periodo;
/