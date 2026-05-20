/*
========================================================
TESTE DO EXERCÍCIO 7 — Procedure: movimentação de estoque

Autor(es): Enzo Okuizumi
RM: 561432
Data: 19/05/2026

Descrição: Cenários de testes (entrada, saída e erro) para a procedure de movimentação de estoque.
========================================================
*/

SET SERVEROUTPUT ON;

-- 1. Teste de Entrada de Estoque
-- Resultado esperado: Mensagem "Entrada realizada com sucesso." e o estoque do produto 1 deve aumentar em 10.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando entrada de estoque ---*');
    cp3_pr_movimentar_estoque(1, 'E', 10, 'Entrada de teste');
    DBMS_OUTPUT.PUT_LINE('Entrada realizada com sucesso.');
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Deu erro: ' || SQLERRM);
END;
/

-- 2. Teste de Saída de Estoque
-- Resultado esperado: Mensagem "Saída realizada com sucesso." e o estoque do produto 1 deve diminuir em 5.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando saída de estoque ---*');
    cp3_pr_movimentar_estoque(1, 'S', 5, 'Saída de teste');
    DBMS_OUTPUT.PUT_LINE('Saída realizada com sucesso.');
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Deu erro: ' || SQLERRM);
END;
/

-- 3. Teste de Erro: Estoque Insuficiente
-- Resultado esperado: Exibir a exceção customizada (-20002) indicando que o estoque é insuficiente.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de estoque insuficiente ---*');
    cp3_pr_movimentar_estoque(1, 'S', 9999, 'Estouro de estoque');
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
