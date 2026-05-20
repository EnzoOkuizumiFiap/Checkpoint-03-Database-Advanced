/*
========================================================
TESTE DO EXERCÍCIO 10 — Procedure: processar uma compra completa

Autor(es): Enzo Okuizumi e Milton Jackson
RM: 561432 e 564836
Data: 19/05/2026

Descrição: Cenários de testes (sucesso e erros) para a procedure integradora de compras.
========================================================
*/

SET SERVEROUTPUT ON;

-- 1. Teste de Sucesso: Processar Compra Completa Válida
-- Resultado esperado: Exibir o resumo do processamento contendo o ID do novo pedido gerado, o valor total e o frete calculados corretamente, e confirmar o sucesso.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Testando checkout completo de produto ---*');
    -- Cliente 1 (Ana Souza) comprando 2 Smart TVs (Produto 1) no seu endereço principal (ID 1)
    cp3_pr_processar_compra(
        p_cliente_id  => 1,
        p_produto_id  => 1,
        p_qtd         => 2,
        p_endereco_id => 1
    );
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Deu erro inesperado: ' || SQLERRM);
END;
/

-- 2. Teste de Erro: Endereço pertencente a outro cliente
-- Resultado esperado: Capturar a exceção customizada (-20009) indicando que o endereço é inválido ou não pertence ao cliente.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de compra com endereço de outro cliente ---*');
    -- Cliente 1 (Ana) tentando entregar no endereço 2 (que pertence ao cliente 2 Bruno)
    cp3_pr_processar_compra(
        p_cliente_id  => 1,
        p_produto_id  => 1,
        p_qtd         => 1,
        p_endereco_id => 2
    );
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- 3. Teste de Erro: Quantidade igual a zero
-- Resultado esperado: Capturar a exceção customizada (-20004) indicando que a quantidade deve ser maior que zero.
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('*--- Teste de compra com quantidade inválida (zero) ---*');
    cp3_pr_processar_compra(
        p_cliente_id  => 1,
        p_produto_id  => 1,
        p_qtd         => 0,
        p_endereco_id => 1
    );
EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
