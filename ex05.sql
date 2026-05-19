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

    SELECT SUM((quantidade * preco_unitario) - desconto)
      INTO v_total_pedido
      FROM cp3_pedido_item
     WHERE pedido_id = p_pedido_id;

    IF v_total_pedido IS NULL THEN
        v_total_pedido := 0;
    END IF;

    RETURN v_total_pedido;
END cp3_fn_total_pedido;
/