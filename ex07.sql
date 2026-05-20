/*
========================================================
EXERCÍCIO 7 — Procedure: movimentação de estoque

Autor(es): Enzo Okuizumi
RM: 561432
Data: 19/05/2026

Descrição: Atualiza a quantidade de produtos na tabela de estoque e insere um registro no histórico de movimentações.

Parâmetros:
- p_produto_id (IN NUMBER): ID do produto
- p_tipo (IN CHAR): Tipo da movimentação ('E' ou 'S')
- p_qtd (IN NUMBER): Quantidade a ser movimentada
- p_observacao (IN VARCHAR2): Observação sobre o movimento
========================================================
*/


set serveroutput on;

CREATE OR REPLACE PROCEDURE cp3_pr_movimentar_estoque(p_produto_id in number, p_tipo in char, p_qtd in number, p_observacao in varchar2)
IS
    v_qtd_atual cp3_estoque.quantidade%type;

    v_sem_estoque EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_sem_estoque, -20002);
    
    v_produto_nao_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_produto_nao_encontrado, -20004);

    v_tipo_movimento_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_tipo_movimento_invalido, -20006);

    v_quantidade_invalida EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_quantidade_invalida, -20005);

BEGIN
    if p_qtd <= 0 then
        raise_application_error(-20005, 'Quantidade movimentada deve ser maior que zero');
    end if;

    if p_tipo != 'S' and p_tipo != 'E' then
        raise_application_error(-20006, 'Tipo de movimento inválido');
    end if;

    BEGIN
        select quantidade into v_qtd_atual from cp3_estoque where produto_id = p_produto_id;
    EXCEPTION
        when no_data_found then raise_application_error(-20004, 'Produto com ID ' || p_produto_id || ' não encontrado no estoque');
    END;

    if p_tipo = 'S' and v_qtd_atual - p_qtd < 0 then
        raise_application_error(-20002, 'Estoque insuficiente');
    elsif p_tipo = 'S' then
        v_qtd_atual := v_qtd_atual - p_qtd;
    elsif p_tipo = 'E' then
        v_qtd_atual := v_qtd_atual + p_qtd; 
    end if;

    update cp3_estoque set quantidade = v_qtd_atual, data_atualizacao = sysdate where produto_id = p_produto_id;

    insert into cp3_movimento_estoque(movimento_id, produto_id, tipo, quantidade, data_movimento, observacao) values (cp3_seq_movimento.NEXTVAL, p_produto_id, p_tipo, p_qtd, sysdate, p_observacao);
    
    -- COMMIT exigido pelo enunciado do Exercício 7
    commit;

    EXCEPTION WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Erro na movimentação: ' || SQLERRM);
        RAISE;

END cp3_pr_movimentar_estoque;
/