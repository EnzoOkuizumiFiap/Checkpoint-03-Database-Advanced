/*
========================================================
TESTE DO EXERCÍCIO 6 — Function: cálculo do frete

Autor(es): Luna de Carvalho Guimarães
RM: 562290
Data: 18/05/2026

Descrição: Cenários de testes (sucesso e erro) para a função que calcula o valor do frete de um pedido.
========================================================
*/

SET SERVEROUTPUT ON;

DECLARE
    v_frete NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando frete de pedido que existe ---*');
    v_frete := cp3_fn_calcular_frete(1);
    DBMS_OUTPUT.PUT_LINE('Valor do Frete: R$ ' || v_frete);
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Deu erro: ' || SQLERRM);
END;
/

DECLARE
    v_frete NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de frete com pedido que não existe na tabela ---*');
    v_frete := cp3_fn_calcular_frete(1000);
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/