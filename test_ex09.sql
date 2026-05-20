/*
========================================================
TESTE DO EXERCÍCIO 9 — Procedure: classificação de clientes

Autor(es): Enzo Okuizumi e Milton Jackson
RM: 561432 e 564836
Data: 19/05/2026

Descrição: Cenário de teste para a procedure de classificação geral de clientes.
========================================================
*/

SET SERVEROUTPUT ON;

-- 1. Teste de Exibição do Relatório
-- Resultado esperado: Exibir na tela a lista contendo nome, e-mail, total gasto e a classificação (VIP, REGULAR, NOVO ou INATIVO) de cada cliente ativo.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Gerando relatório de classificação de clientes ---*');
    cp3_pr_classificar_clientes;
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Deu erro ao classificar: ' || SQLERRM);
END;
/
