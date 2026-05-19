-- =============================================================
-- Arquivo  : test_ex03.sql
-- Testa    : cp3_pr_listar_pedidos_periodo (Exercício 3)
-- Autor(es): Grupo __________________________
-- RMs: _56348________________________________
-- Data: _17_/_05_/2026
-- =============================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Caminho feliz: últimos 120 dias
PROMPT
PROMPT Pedidos dos últimos 120 dias
BEGIN
    cp3_pr_listar_pedidos_periodo(
        p_data_ini => SYSDATE - 120,
        p_data_fim => SYSDATE
    );
END;
/

-- Período sem pedidos

PROMPT
PROMPT Período sem pedidos (5 anos atrás)
BEGIN
    cp3_pr_listar_pedidos_periodo(
        p_data_ini => DATE '2010-01-01',
        p_data_fim => DATE '2010-12-31'
    );
END;
/

-- Erro: data_fim < data_ini

PROMPT
PROMPT (ERRO ESPERADO): data_fim < data_ini
BEGIN
    cp3_pr_listar_pedidos_periodo(
        p_data_ini => SYSDATE,
        p_data_fim => SYSDATE - 10
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Exceção capturada: ' || SQLERRM);
END;
/

-- Apenas pedidos FINALIZADOS nos últimos 100 dias

PROMPT
PROMPT Intervalo focado nos 5 primeiros pedidos
BEGIN
    cp3_pr_listar_pedidos_periodo(
        p_data_ini => SYSDATE - 100,
        p_data_fim => SYSDATE - 5
    );
END;
/