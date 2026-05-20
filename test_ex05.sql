/*
========================================================
TESTE DO EXERCÍCIO 5 — Function: total de um pedido

Autor(es): Luna de Carvalho Guimarães
RM: 562290
Data: 18/05/2026

Descrição: Cenários de testes (sucesso e erro) para a função que calcula o valor total de um pedido.
========================================================
*/

SET SERVEROUTPUT ON;

DECLARE
    v_resultado NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando pedido que existe ---*');
    v_resultado := cp3_fn_total_pedido(1);
    DBMS_OUTPUT.PUT_LINE('Total do Pedido: R$ ' || v_resultado);
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Deu erro: ' || SQLERRM);
END;
/

DECLARE
    v_resultado NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de pedido que não existe na tabela ---*');
    v_resultado := cp3_fn_total_pedido(999);
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/