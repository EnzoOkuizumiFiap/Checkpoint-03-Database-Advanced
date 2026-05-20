/*
========================================================
EXERCÍCIO 8 — Procedure: finalizar um pedido

Autor(es): Enzo Okuizumi
RM: 561432
Data: 19/05/2026

Descrição: Finaliza um pedido pendente, atualiza o estoque de seus itens, calcula o valor total e o frete, e atualiza o status para finalizado.

Parâmetros:
- p_pedido_id (IN NUMBER): ID do pedido a ser finalizado
========================================================
*/

CREATE OR REPLACE PROCEDURE cp3_pr_finalizar_pedido(p_pedido_id IN NUMBER)
IS
    v_status cp3_pedido.status%TYPE;
    v_etapa  VARCHAR2(100);
    
    cursor c_itens(p_id cp3_pedido.pedido_id%TYPE) is 
        select produto_id, quantidade from cp3_pedido_item where pedido_id = p_id;

    v_valor_total cp3_pedido.valor_total%TYPE;
    v_valor_frete cp3_pedido.valor_frete%TYPE;
BEGIN
    -- Validação do pedido
    v_etapa := 'Validação da existência e status do pedido';
    BEGIN
        select status into v_status from cp3_pedido where pedido_id = p_pedido_id;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20001, 'Pedido de ID ' || p_pedido_id || ' não encontrado.');
    END; 
    
    if v_status != 'PENDENTE' then
        raise_application_error(-20002, 'Pedido de ID ' || p_pedido_id || ' não está pendente.');
    end if;
    
    -- Percorrer os itens e movimentar o estoque
    v_etapa := 'Baixa no estoque dos itens';
    for r_item in c_itens(p_pedido_id) loop
        cp3_pr_movimentar_estoque(
            p_produto_id => r_item.produto_id,
            p_tipo => 'S',
            p_qtd => r_item.quantidade,
            p_observacao => 'Baixa por finalização de pedido ' || p_pedido_id
        );
    end loop;
    
    -- Chamando as outras funções
    v_etapa := 'Cálculo do valor total e frete';
    v_valor_total := cp3_fn_total_pedido(p_pedido_id => p_pedido_id);
    
    v_etapa := 'Cálculo do frete do pedido';
    v_valor_frete := cp3_fn_calcular_frete(p_pedido_id => p_pedido_id);
    
    -- Atualização final do pedido!!!
    v_etapa := 'Atualização final do status e valores do pedido';
    update cp3_pedido set status = 'FINALIZADO',
        valor_total = v_valor_total,
        valor_frete = v_valor_frete
    where pedido_id = p_pedido_id;
    
    commit;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20003, 'Erro ao finalizar pedido ' || p_pedido_id || ' na etapa ' || v_etapa || ': ' || SQLERRM);

END cp3_pr_finalizar_pedido;
/
