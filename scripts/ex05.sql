/*
========================================================
EXERCÍCIO 5 — Function: total de um pedido

Autor(es): Luna de Carvalho Guimarães
RM: 562290
Data: 18/05/2026

Descrição:
Retorna o valor total do pedido somando todos os seus itens
(quantidade * preco_unitario - desconto), tratando o desconto
como zero caso esteja nulo. Se o pedido não existir, lança 
uma exceção customizada.

Parâmetros:
- p_pedido_id: ID do pedido
========================================================
*/

CREATE OR REPLACE FUNCTION cp3_fn_total_pedido(
    p_pedido_id IN NUMBER
) RETURN NUMBER IS
    v_pedido       NUMBER;
    v_total_pedido cp3_pedido.valor_total%TYPE;
BEGIN
    SELECT COUNT(pedido_id)
      INTO v_pedido
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_pedido = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro: O pedido ' || p_pedido_id || ' não existe na tabela.');
    END IF;

    SELECT SUM((quantidade * preco_unitario) - NVL(desconto, 0))
      INTO v_total_pedido
      FROM cp3_pedido_item
     WHERE pedido_id = p_pedido_id;

    IF v_total_pedido IS NULL THEN
        v_total_pedido := 0;
    END IF;

    RETURN v_total_pedido;
END cp3_fn_total_pedido;
/