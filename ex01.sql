/*
========================================================
EXERCÍCIO 1 — Verificação de estoque

Autor(es): Lucas Barros
RM: 566422
Data: 17/05/2026

Descrição:
Bloco anônimo que recebe o ID de um produto, exibindo:
- nome do produto
- categoria
- quantidade em estoque
- quantidade mínima
- status do estoque

Caso o produto não exista, lança exceção customizada.
========================================================
*/

SET SERVEROUTPUT ON;

DECLARE
    codigo NUMBER := &produto_id;
    produto cp3_produto.nome%TYPE;
    categoria cp3_categoria.nome%TYPE;
    qtd_estoque cp3_estoque.quantidade%TYPE;
    qtd_minima cp3_estoque.qtd_minima%TYPE;
    
    mensagem VARCHAR2(50);
    
    produto_nao_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(produto_nao_encontrado, -20001);
    
BEGIN
    BEGIN
        SELECT p.nome, c.nome, e.quantidade, e.qtd_minima INTO produto, categoria, qtd_estoque, qtd_minima FROM cp3_produto p
        INNER JOIN cp3_categoria c ON c.categoria_id = p.categoria_id
        INNER JOIN cp3_estoque e ON e.produto_id = p.produto_id WHERE p.produto_id = codigo;
        
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Produto com ID ' || codigo || ' não encontrado.'
            );
        END;
    
    IF qtd_estoque < qtd_minima THEN
        mensagem := 'ALERTA: REPOR ESTOQUE';
    ELSE
        mensagem := 'ESTOQUE OK';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Produto: ' || produto || ' | Categoria: ' || categoria || ' | Estoque atual: ' || qtd_estoque || ' | Estoque minimo: ' || qtd_minima || ' | Status: ' || mensagem);
    
    EXCEPTION
        WHEN produto_nao_encontrado THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
            RAISE;
    
END;
/