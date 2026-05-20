/*
========================================================
EXERCÍCIO 4 — Procedure: detalhamento dos itens de cada pedido

Autor(es): Gustavo Okada
RM: 563428
Data: 17/05/2026

Descrição:
Gera um relatório detalhado dos pedidos realizados em um intervalo
de datas, listando seus itens, subtotais (tratando descontos nulos)
e totais calculados através de cursores aninhados.

Parâmetros:
- p_data_ini (IN DATE): Data inicial do período
- p_data_fim (IN DATE): Data final do período
========================================================
*/

CREATE OR REPLACE PROCEDURE cp3_pr_detalhar_pedidos_periodo (
    p_data_ini IN DATE,
    p_data_fim IN DATE
)

IS
    -- Exceção customizada: intervalo inválido (reaproveita o mesmo código do ex03)
    ex_periodo_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_periodo_invalido, -20001);

    -- Cursor externo: pedidos do período
    CURSOR cur_pedidos IS
        SELECT p.pedido_id,
               p.data_pedido,
               c.nome   AS nome_cliente,
               p.status,
               p.valor_frete
          FROM cp3_pedido  p
          JOIN cp3_cliente c ON c.cliente_id = p.cliente_id
         WHERE p.data_pedido BETWEEN p_data_ini AND p_data_fim + 1 - 1/86400
         ORDER BY p.data_pedido;

    -- Cursor interno: itens de um pedido específico (parâmetro de cursor)
    CURSOR cur_itens (p_pedido_id IN NUMBER) IS
        SELECT pi.item_id,
               pr.nome          AS nome_produto,
               pi.quantidade,
               pi.preco_unitario,
               pi.desconto,
               (pi.quantidade * pi.preco_unitario) - pi.desconto AS subtotal
          FROM cp3_pedido_item pi
          JOIN cp3_produto     pr ON pr.produto_id = pi.produto_id
         WHERE pi.pedido_id = p_pedido_id
         ORDER BY pi.item_id;

    -- Variáveis para os cursores
    v_ped   cur_pedidos%ROWTYPE;
    v_item  cur_itens%ROWTYPE;

    -- Contadores e acumuladores
    v_total_pedidos NUMBER := 0;
    v_total_itens   NUMBER := 0;
    v_total_geral   NUMBER := 0;
    v_subtotal_ped  NUMBER := 0;

BEGIN
    -- Validação do período
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
    DBMS_OUTPUT.PUT_LINE('DETALHAMENTO DE PEDIDOS: ' ||
                         TO_CHAR(p_data_ini, 'DD/MM/YYYY') || ' a ' ||
                         TO_CHAR(p_data_fim,  'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('=================================================');

    -- Abre o cursor externo
    OPEN cur_pedidos;

    LOOP
        FETCH cur_pedidos INTO v_ped;
        EXIT WHEN cur_pedidos%NOTFOUND;

        v_total_pedidos := v_total_pedidos + 1;
        v_subtotal_ped  := 0;

        -- Cabeçalho do pedido
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('  Pedido #' || v_ped.pedido_id ||
                             ' | ' || TO_CHAR(v_ped.data_pedido, 'DD/MM/YYYY') ||
                             ' | ' || v_ped.nome_cliente ||
                             ' | Status: ' || v_ped.status);
        DBMS_OUTPUT.PUT_LINE('  -----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('  PRODUTO                 QTD    PREÇO     DESC      SUBTOTAL');
        DBMS_OUTPUT.PUT_LINE('  -----------------------------------------');

        -- Abre o cursor interno para os itens deste pedido
        OPEN cur_itens(v_ped.pedido_id);

        LOOP
            FETCH cur_itens INTO v_item;
            EXIT WHEN cur_itens%NOTFOUND;

            v_total_itens  := v_total_itens  + 1;
            v_subtotal_ped := v_subtotal_ped + v_item.subtotal;

            DBMS_OUTPUT.PUT_LINE(
                '  ' ||
                RPAD(v_item.nome_produto, 22)       || ' ' ||
                LPAD(v_item.quantidade,    3)        || '  ' ||
                LPAD(TO_CHAR(v_item.preco_unitario, 'FM9990.00'), 8) || '  ' ||
                LPAD(TO_CHAR(v_item.desconto,        'FM9990.00'), 8) || '  ' ||
                LPAD(TO_CHAR(v_item.subtotal,         'FM9990.00'), 9)
            );
        END LOOP;

        CLOSE cur_itens;

        -- Rodapé do pedido
        DBMS_OUTPUT.PUT_LINE('  -----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('  Subtotal dos itens : R$ ' ||
                             TO_CHAR(v_subtotal_ped,    'FM9G990D00'));
        DBMS_OUTPUT.PUT_LINE('  Frete              : R$ ' ||
                             TO_CHAR(v_ped.valor_frete, 'FM9G990D00'));
        DBMS_OUTPUT.PUT_LINE('  TOTAL DO PEDIDO    : R$ ' ||
                             TO_CHAR(v_subtotal_ped + v_ped.valor_frete, 'FM9G990D00'));

        v_total_geral := v_total_geral + v_subtotal_ped + v_ped.valor_frete;
    END LOOP;

    CLOSE cur_pedidos;

    -- Sumário geral
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=================================================');
    DBMS_OUTPUT.PUT_LINE('Pedidos listados : ' || v_total_pedidos);
    DBMS_OUTPUT.PUT_LINE('Itens listados   : ' || v_total_itens);
    DBMS_OUTPUT.PUT_LINE('Receita no período: R$ ' ||
                         TO_CHAR(v_total_geral, 'FM9G999G990D00'));
    DBMS_OUTPUT.PUT_LINE('=================================================');

EXCEPTION
    WHEN OTHERS THEN
        -- Fecha cursores abertos antes de propagar o erro
        IF cur_itens%ISOPEN  THEN CLOSE cur_itens;  END IF;
        IF cur_pedidos%ISOPEN THEN CLOSE cur_pedidos; END IF;
        RAISE;
END cp3_pr_detalhar_pedidos_periodo;
/