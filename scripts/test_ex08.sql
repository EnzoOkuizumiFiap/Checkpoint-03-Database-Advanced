/*
========================================================
TESTE DO EXERCÍCIO 8 — Procedure: finalizar um pedido

Autor(es): Enzo Okuizumi
RM: 561432
Data: 19/05/2026

Descrição: Cenários de testes (sucesso e erros) para a procedure de finalização de pedidos.
========================================================
*/

SET SERVEROUTPUT ON;

-- 1. Teste de Sucesso: Finalizar Pedido Pendente que existe
-- Resultado esperado: Mensagem "Pedido finalizado com sucesso!". O status do pedido 6 deve mudar para 'FINALIZADO' e os valores de total e frete serão calculados e preenchidos no banco.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando finalização do pedido 6 ---*');
    cp3_pr_finalizar_pedido(6);
    DBMS_OUTPUT.PUT_LINE('Pedido finalizado com sucesso.');
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Deu erro: ' || SQLERRM);
END;
/

-- 2. Teste de Erro: Pedido Inexistente
-- Resultado esperado: Exibir exceção customizada (-20001) indicando que o pedido não foi encontrado.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de finalização com pedido inexistente ---*');
    cp3_pr_finalizar_pedido(9999);
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- 3. Teste de Erro: Pedido com status inválido (que não está PENDENTE)
-- Resultado esperado: Exibir exceção customizada (-20002) indicando que o pedido não está pendente (ex: pedido 1 já está finalizado).
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de finalização com pedido já finalizado ---*');
    cp3_pr_finalizar_pedido(1);
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
