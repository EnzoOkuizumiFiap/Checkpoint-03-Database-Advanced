/*
========================================================
EXERCÍCIO 2 — Procedure: relatório de produtos por categoria

Autor(es): Lucas Barros
RM: 566422
Data: 17/05/2026

Descrição:
Lista os produtos ativos de uma categoria, exibindo:
- nome do produto
- preço unitário
- quantidade em estoque
- total de produtos listados
- não exibe produtos não ativos

Caso a categoria não exista, lança exceção customizada.
========================================================
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE cp3_pr_listar_produtos_categoria (p_categoria_id IN NUMBER)
IS
    teste NUMBER;
    total NUMBER := 0;

    categoria_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(categoria_nao_encontrada, -20002);

BEGIN
    BEGIN
        SELECT COUNT(*) INTO teste FROM cp3_categoria WHERE categoria_id = p_categoria_id;

        IF teste = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Categoria com ID ' || p_categoria_id || ' não encontrada.'
            );
        END IF;
    END;

    FOR produto IN (SELECT p.nome, p.preco_unitario, e.quantidade FROM cp3_produto p
        INNER JOIN cp3_estoque e ON e.produto_id = p.produto_id
        WHERE p.categoria_id = p_categoria_id AND p.ativo = 'S')
    LOOP

        DBMS_OUTPUT.PUT_LINE(
            'Produto: ' || produto.nome ||
            ' | Preço: R$ ' || produto.preco_unitario ||
            ' | Estoque: ' || produto.quantidade
        );
        total := total + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total de produtos listados: ' || total);

EXCEPTION
    WHEN categoria_nao_encontrada THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
        RAISE;
END cp3_pr_listar_produtos_categoria;
/
