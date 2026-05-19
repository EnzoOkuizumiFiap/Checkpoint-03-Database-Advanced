/*
========================================================
TESTE DO EXERCÍCIO 2 — Procedure: relatório de produtos por categoria
Autor(es): Grupo __________________________
RMs: ______________________________________
Data: ____/____/2026

Descrição:
Dois testes da procedure cp3_pr_listar_produtos_categoria:
- caminho feliz, em que tudo dá certo.
- cenário de erro, que exibe uma exception 
========================================================
*/

SET SERVEROUTPUT ON;

/*
=========================================
TESTE 1 - CAMINHO FELIZ
CATEGORIA EXISTENTE
=========================================
*/

CALL cp3_pr_listar_produtos_categoria(1);

/*
=========================================
TESTE 2 - CENÁRIO DE ERRO
CATEGORIA INEXISTENTE
=========================================
*/

CALL cp3_pr_listar_produtos_categoria(2857956);
/