-- =============================================================
-- Arquivo  : test_ex04.sql
-- Testa    : cp3_pr_detalhar_pedidos_periodo (Exercício 4)
-- Autor(es): Grupo __________________________
-- RMs: _56348________________________________
-- Data: _17_/_05_/2026
-- =============================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Caminho feliz: todos os pedidos do setup

PROMPT
PROMPT Detalhamento completo, últimos 120 dias
BEGIN
    cp3_pr_detalhar_pedidos_periodo(
        p_data_ini => SYSDATE - 120,
        p_data_fim => SYSDATE
    );
END;
/

-- Pedido único com desconto (pedido 3 do setup)
-- item 5: produto 2, qtd=1, preço=349.90, desconto=170.10
PROMPT
PROMPT Foco no pedido com desconto (últimos 65 dias)
BEGIN
    cp3_pr_detalhar_pedidos_periodo(
        p_data_ini => SYSDATE - 65,
        p_data_fim => SYSDATE - 55
    );
END;
/

-- Período sem pedidos
PROMPT
PROMPT Sem pedidos no período
BEGIN
    cp3_pr_detalhar_pedidos_periodo(
        p_data_ini => DATE '2010-01-01',
        p_data_fim => DATE '2010-12-31'
    );
END;
/

-- Erro: data_fim < data_ini
PROMPT
PROMPT (ERRO ESPERADO): período invertido
BEGIN
    cp3_pr_detalhar_pedidos_periodo(
        p_data_ini => SYSDATE,
        p_data_fim => SYSDATE - 10
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Exceção capturada: ' || SQLERRM);
END;
/