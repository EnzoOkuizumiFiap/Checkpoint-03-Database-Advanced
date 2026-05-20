/*
========================================================
EXERCÍCIO 10 — Procedure: processar uma compra completa

Autor(es): Enzo Okuizumi e Milton Jackson
RM: 561432 e 564836
Data: 19/05/2026

Descrição: Procedure integradora que valida o cliente, produto e endereço, cria o pedido (status PENDENTE), insere o item congelando o preço, faz a movimentação do estoque e finaliza a compra em uma única transação atômica.

Parâmetros:
- p_cliente_id (IN NUMBER): ID do cliente
- p_produto_id (IN NUMBER): ID do produto
- p_qtd (IN NUMBER): Quantidade comprada
- p_endereco_id (IN NUMBER): ID do endereço de entrega

Observação:
    O enunciado do Exercício 10 pede para chamar cp3_pr_finalizar_pedido (ex08)
    na etapa 5, porém essa procedure internamente percorre os itens do pedido e chama
    cp3_pr_movimentar_estoque novamente, causando desconto DUPLO no estoque.
    Para corrigir esse bug, a finalização (cálculo do total, frete e atualização
    do status para 'FINALIZADO') é feita manualmente nesta procedure.

========================================================
*/

CREATE OR REPLACE PROCEDURE cp3_pr_processar_compra(p_cliente_id IN NUMBER, p_produto_id IN NUMBER, p_qtd IN NUMBER, p_endereco_id IN NUMBER) IS
    v_etapa          VARCHAR2(100);
    v_cliente_ativo  cp3_cliente.ativo%TYPE;
    v_produto_ativo  cp3_produto.ativo%TYPE;
    v_preco_unitario cp3_produto.preco_unitario%TYPE;
    v_end_valido     NUMBER;
    v_pedido_id      cp3_pedido.pedido_id%TYPE;
    
    v_total          cp3_pedido.valor_total%TYPE;
    v_frete          cp3_pedido.valor_frete%TYPE;
BEGIN
    -- Etapa 1: Validações Iniciais
    v_etapa := 'Validações iniciais dos dados da compra';

    -- 1. Valida se a quantidade é maior que zero
    if p_qtd <= 0 then
        raise_application_error(-20004, 'A quantidade de itens deve ser maior que zero.');
    end if;

    -- 2. Valida se o cliente existe e se está ativo
    BEGIN
        select ativo into v_cliente_ativo from cp3_cliente where cliente_id = p_cliente_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20005, 'Cliente com ID ' || p_cliente_id || ' não encontrado.');
    END;

    if v_cliente_ativo != 'S' then
        raise_application_error(-20006, 'O cliente com ID ' || p_cliente_id || ' não está ativo.');
    end if;

    -- 3. Valida se o produto existe e se está ativo, guardando seu preço unitário
    BEGIN
        select ativo, preco_unitario into v_produto_ativo, v_preco_unitario from cp3_produto where produto_id = p_produto_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20007, 'Produto com ID ' || p_produto_id || ' não encontrado.');
    END;

    if v_produto_ativo != 'S' then
        raise_application_error(-20008, 'O produto com ID ' || p_produto_id || ' não está ativo.');
    end if;

    -- 4. Valida se o endereço existe e pertence a este cliente
    select count(*) into v_end_valido from cp3_endereco where endereco_id = p_endereco_id and cliente_id = p_cliente_id;

    if v_end_valido = 0 then
        raise_application_error(-20009, 'Endereço inválido ou não pertence a este cliente!');
    end if;
    
    
    -- Etapa 2: Criar o cabeçalho do pedido
    v_etapa := 'Criação do pedido com status PENDENTE';
    
    select cp3_seq_pedido.NEXTVAL into v_pedido_id from dual;
    
    -- Inserimos incluindo a coluna obrigatória endereco_entrega_id e ajustando status_pedido para status
    insert into cp3_pedido (pedido_id, cliente_id, endereco_entrega_id, data_pedido, status, valor_total, valor_frete) 
    values (v_pedido_id, p_cliente_id, p_endereco_id, sysdate, 'PENDENTE', 0, 0);
    
    
    -- Etapa 3: Criar o item do pedido
    v_etapa := 'Criação do item do pedido (congelando preço)';
    
    insert into cp3_pedido_item (item_id, pedido_id, produto_id, quantidade, preco_unitario) 
    values (cp3_seq_item.NEXTVAL, v_pedido_id, p_produto_id, p_qtd, v_preco_unitario);
    
    
    -- Etapa 4: Dar baixa no estoque
    v_etapa := 'Baixa no estoque do produto';
    
    cp3_pr_movimentar_estoque(
        p_produto_id => p_produto_id,
        p_tipo       => 'S',
        p_qtd        => p_qtd,
        p_observacao => 'Compra processada - pedido ' || v_pedido_id
    );
    
    
    -- Etapa 5: Finalizar o pedido
    
    -- AVISO: Não chamamos cp3_pr_finalizar_pedido aqui pois ela internamente 
    -- chama cp3_pr_movimentar_estoque novamente, causando desconto duplo no estoque.
    -- cp3_pr_finalizar_pedido(v_pedido_id);
    
    -- Fazemos a finalização manualmente para evitar esse bug.
    v_etapa := 'Finalização do pedido';
    
    v_total := cp3_fn_total_pedido(p_pedido_id => v_pedido_id);
    v_frete := cp3_fn_calcular_frete(p_pedido_id => v_pedido_id);
    
    update cp3_pedido set status = 'FINALIZADO',
        valor_total = v_total,
        valor_frete = v_frete
    where pedido_id = v_pedido_id;
    
    
    -- Etapa 6: Exibir o resumo do processamento
    v_etapa := 'Exibição do resumo da compra';

    dbms_output.put_line('Resumo do Processamento: '
                        || ' Pedido ID: ' || v_pedido_id 
                        || ' Valor Total: R$ ' || to_char(v_total, 'FM999G999G990D00')
                        || ' Valor Frete: R$ ' || to_char(v_frete, 'FM999G999G990D00')
                        || ' Total a Pagar: R$ ' || to_char(v_total + v_frete, 'FM999G999G990D00'));
    
    commit;

EXCEPTION
    WHEN OTHERS THEN
        -- Desfaz qualquer alteração feita nesta transação (inclusive as inserções e a baixa de estoque)
        ROLLBACK;
        raise_application_error(-20010, 'Erro ao processar a compra na etapa ' || v_etapa || ' - Erro: ' || SQLERRM);
END cp3_pr_processar_compra;
/
