CREATE OR REPLACE FUNCTION cp3_fn_calcular_frete (
    p_pedido_id IN NUMBER
) RETURN NUMBER IS
    v_pedido       NUMBER;
    v_uf           CHAR(2);
    v_peso_total   NUMBER;
    v_frete        NUMBER;
BEGIN

    SELECT
        COUNT(pedido_id)
    INTO v_pedido
    FROM
        cp3_pedido
    WHERE
        pedido_id = p_pedido_id;

    IF v_pedido = 0 THEN
        raise_application_error(-20002, 'Erro: O pedido '
                                        || p_pedido_id
                                        || ' não existe para calcular o frete!');
    END IF;

    SELECT
        cp.uf
    INTO v_uf
    FROM
        cp3_pedido     ped
        JOIN cp3_endereco   ende ON ped.endereco_entrega_id = ende.endereco_id
        JOIN cp3_cep        cp ON ende.cep = cp.cep
    WHERE
        ped.pedido_id = p_pedido_id;

    SELECT
        SUM(i.quantidade * prod.peso_kg)
    INTO v_peso_total
    FROM
        cp3_pedido_item   i,
        cp3_produto       prod
    WHERE
        i.produto_id = prod.produto_id
        AND i.pedido_id = p_pedido_id;

    IF v_peso_total IS NULL THEN
        v_peso_total := 0;
    END IF;

    IF v_uf = 'SP' OR v_uf = 'RJ' THEN
        v_frete := 15.00 + ( 2.00 * v_peso_total );
    ELSIF v_uf = 'MG' OR v_uf = 'ES' THEN
        v_frete := 20.00 + ( 3.00 * v_peso_total );
    ELSE
        v_frete := 30.00 + ( 5.00 * v_peso_total );
    END IF;

    RETURN v_frete;
END cp3_fn_calcular_frete;
/