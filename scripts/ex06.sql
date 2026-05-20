/*
========================================================
EXERCÍCIO 6 — Function: cálculo do frete

Autor(es): Luna de Carvalho Guimarães
RM: 562290
Data: 18/05/2026

Descrição:
Calcula o valor do frete do pedido com base no peso total
dos itens e na UF de entrega. Se o pedido não existir ou
não tiver endereço associado, lança exceções específicas.

Parâmetros:
- p_pedido_id: ID do pedido para o qual se deseja calcular o frete
========================================================
*/

CREATE OR REPLACE FUNCTION cp3_fn_calcular_frete (
    p_pedido_id IN NUMBER
) RETURN NUMBER IS
    v_pedido       NUMBER;
    v_uf           cp3_cep.uf%TYPE;
    v_peso_total   cp3_produto.peso_kg%TYPE;
    v_frete        cp3_pedido.valor_frete%TYPE;
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

    BEGIN
        SELECT
            cp.uf
        INTO v_uf
        FROM
            cp3_pedido     ped
            INNER JOIN cp3_endereco   ende ON ped.endereco_entrega_id = ende.endereco_id
            INNER JOIN cp3_cep        cp ON ende.cep = cp.cep
        WHERE
            ped.pedido_id = p_pedido_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Erro: Endereço de entrega ou CEP não localizado para o pedido ' || p_pedido_id || '.');
    END;

    SELECT
        SUM(i.quantidade * NVL(prod.peso_kg, 0))
    INTO v_peso_total
    FROM
        cp3_pedido_item   i
        INNER JOIN cp3_produto prod ON i.produto_id = prod.produto_id
    WHERE
        i.pedido_id = p_pedido_id;

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