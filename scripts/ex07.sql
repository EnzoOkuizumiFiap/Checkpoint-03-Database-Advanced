/*
========================================================
EXERCÍCIO 7 — Procedure: movimentação de estoque

Autor(es): Enzo Okuizumi
RM: 561432
Data: 19/05/2026

Descrição: 
Atualiza a quantidade de produtos na tabela de estoque e insere um registro no histórico de movimentações (cp3_movimento_estoque).
Trata validações de sinal, tipo de movimento e saldo insuficiente.

Parâmetros:
- p_produto_id (IN NUMBER): ID do produto
- p_tipo (IN CHAR): Tipo da movimentação ('E' para Entrada, 'S' para Saída)
- p_qtd (IN NUMBER): Quantidade a ser movimentada
- p_observacao (IN VARCHAR2): Observação sobre o movimento
========================================================
*/


set serveroutput on;

CREATE OR REPLACE PROCEDURE cp3_pr_movimentar_estoque(p_produto_id in number, p_tipo in char, p_qtd in number, p_observacao in varchar2)
IS
    v_qtd_atual cp3_estoque.quantidade%type;
BEGIN
    -- Validação de quantidade negativa ou nula
    if p_qtd <= 0 then
        raise_application_error(-20005, 'Erro: A quantidade movimentada deve ser maior que zero.');
    end if;

    -- Validação do tipo de movimento
    if p_tipo not in ('E', 'S') then
        raise_application_error(-20006, 'Erro: Tipo de movimento inválido. Use ''E'' para entrada ou ''S'' para saída.');
    end if;

    -- Verificação da existência do produto e busca do saldo atual
    begin
        select quantidade into v_qtd_atual from cp3_estoque where produto_id = p_produto_id;
    exception when no_data_found then 
        raise_application_error(-20004, 'Erro: Produto com ID ' || p_produto_id || ' não encontrado no estoque.');
    end;

    -- Validação de estoque insuficiente para saídas e cálculo do novo saldo
    if p_tipo = 'S' then
        if v_qtd_atual - p_qtd < 0 then
            raise_application_error(-20002, 'Erro: Saldo insuficiente em estoque para realizar esta saída.');
        end if;
        v_qtd_atual := v_qtd_atual - p_qtd;
    else
        v_qtd_atual := v_qtd_atual + p_qtd;
    end if;

    -- Atualização do saldo do estoque
    update cp3_estoque set quantidade = v_qtd_atual, data_atualizacao = SYSDATE where produto_id = p_produto_id;

    -- Registro no histórico de movimentações
    insert into cp3_movimento_estoque (movimento_id, produto_id, tipo, quantidade, data_movimento, observacao) 
    values (cp3_seq_movimento.nextval, p_produto_id, p_tipo, p_qtd, SYSDATE, p_observacao);

    commit;

EXCEPTION 
    when others then
        RAISE;

END cp3_pr_movimentar_estoque;
/