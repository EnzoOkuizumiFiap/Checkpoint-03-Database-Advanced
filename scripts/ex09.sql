/*
========================================================
EXERCÍCIO 9 — Procedure: classificação de clientes

Autor(es): Enzo Okuizumi e Milton Jackson
RM: 561432 e 564836
Data: 19/05/2026

Descrição: Percorre todos os clientes ativos, calcula o total gasto somando seus pedidos finalizados e os classifica (VIP, REGULAR, NOVO ou INATIVO).
========================================================
*/

CREATE OR REPLACE PROCEDURE cp3_pr_classificar_clientes
IS
    cursor c_clientes is select cliente_id, nome, email from cp3_cliente where ativo = 'S';
    
    cursor c_pedidos (p_cliente_id NUMBER) is select pedido_id from cp3_pedido where cliente_id = p_cliente_id and status = 'FINALIZADO';
    v_total_gasto   NUMBER(12,2);
    v_classificacao VARCHAR2(20);
BEGIN
    for r_cliente in c_clientes loop
        v_total_gasto := 0;
        for r_pedido in c_pedidos(r_cliente.cliente_id) loop
            v_total_gasto := v_total_gasto + cp3_fn_total_pedido(p_pedido_id => r_pedido.pedido_id);
        end loop; 

        if v_total_gasto >= 5000 then
            v_classificacao := 'VIP';
        elsif v_total_gasto >= 1000 then
            v_classificacao := 'REGULAR';
        elsif v_total_gasto > 0 then
            v_classificacao := 'NOVO';
        else
            v_classificacao := 'INATIVO';
        end if;
        
        dbms_output.put_line('Cliente: ' || r_cliente.nome || ' | E-mail: ' || r_cliente.email || ' | Total Gasto: R$ ' || to_char(v_total_gasto, 'FM999G999G990D00') || ' | Classificação: ' || v_classificacao);
    end loop; 
END;
/
