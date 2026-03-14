-- ============================================================
-- ANÁLISE: Performance Comercial Q1 2024
-- Dimensões: região, canal, segmento, categoria, vendedor
-- Autor: Milene Caldeira
-- ============================================================
-- Receita líquida = preco_unitario * quantidade * (1 - desconto_pct/100)
-- Base: apenas vendas com status = 'Concluída'
-- ============================================================


-- ============================================================
-- BLOCO 1: VISÃO GERAL DO PERÍODO
-- ============================================================

-- KPIs consolidados do Q1 — primeira linha de qualquer relatório executivo
SELECT
    COUNT(*)                                                             AS total_transacoes,
    COUNT(DISTINCT id_cliente)                                           AS clientes_ativos,
    SUM(CASE WHEN status = 'Concluída' THEN 1 ELSE 0 END)               AS vendas_concluidas,
    SUM(CASE WHEN status = 'Cancelada' THEN 1 ELSE 0 END)               AS vendas_canceladas,
    SUM(CASE WHEN status = 'Pendente'  THEN 1 ELSE 0 END)               AS vendas_pendentes,
    ROUND(
        SUM(CASE WHEN status = 'Cancelada' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 1
    )                                                                    AS taxa_cancelamento_pct,
    ROUND(
        SUM(CASE WHEN status = 'Concluída'
            THEN preco_unitario * quantidade * (1 - desconto_pct / 100.0)
            ELSE 0 END), 2
    )                                                                    AS receita_liquida_total,
    ROUND(
        AVG(CASE WHEN status = 'Concluída'
            THEN preco_unitario * quantidade * (1 - desconto_pct / 100.0)
            END), 2
    )                                                                    AS ticket_medio
FROM vendas;


-- Evolução mensal — identifica tendência de crescimento ou queda
SELECT
    MONTH(data_venda)                                                    AS mes,
    DATENAME(MONTH, data_venda)                                          AS nome_mes,
    COUNT(*)                                                             AS transacoes,
    COUNT(DISTINCT id_cliente)                                           AS clientes_unicos,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida
FROM vendas
WHERE status = 'Concluída'
GROUP BY MONTH(data_venda), DATENAME(MONTH, data_venda)
ORDER BY mes;


-- ============================================================
-- BLOCO 2: ANÁLISE POR REGIÃO E ESTADO
-- ============================================================

-- Receita por região — onde está concentrada a base de clientes
SELECT
    regiao,
    COUNT(*)                                                             AS transacoes,
    COUNT(DISTINCT id_cliente)                                           AS clientes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida,
    ROUND(
        AVG(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS ticket_medio
FROM vendas
WHERE status = 'Concluída'
GROUP BY regiao
ORDER BY receita_liquida DESC;


-- Detalhamento por estado dentro de cada região
-- Útil para identificar quais UFs puxam o resultado regional
SELECT
    regiao,
    estado,
    COUNT(*)                                                             AS transacoes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida
FROM vendas
WHERE status = 'Concluída'
GROUP BY regiao, estado
ORDER BY regiao, receita_liquida DESC;


-- ============================================================
-- BLOCO 3: ANÁLISE POR CANAL DE VENDA
-- ============================================================

-- Qual canal gera mais receita e tem melhor ticket médio?
SELECT
    canal,
    COUNT(*)                                                             AS transacoes,
    COUNT(DISTINCT id_cliente)                                           AS clientes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida,
    ROUND(
        AVG(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS ticket_medio,
    ROUND(AVG(desconto_pct * 1.0), 1)                                    AS desconto_medio_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY canal
ORDER BY receita_liquida DESC;


-- Taxa de cancelamento por canal — qual canal tem mais atrito?
SELECT
    canal,
    COUNT(*)                                                             AS total,
    SUM(CASE WHEN status = 'Concluída' THEN 1 ELSE 0 END)               AS concluidas,
    SUM(CASE WHEN status = 'Cancelada' THEN 1 ELSE 0 END)               AS canceladas,
    ROUND(
        SUM(CASE WHEN status = 'Cancelada' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 1
    )                                                                    AS taxa_cancelamento_pct
FROM vendas
GROUP BY canal
ORDER BY taxa_cancelamento_pct DESC;


-- ============================================================
-- BLOCO 4: ANÁLISE POR SEGMENTO DE CLIENTE
-- ============================================================

-- Premium vs Standard — diferença de comportamento e valor
SELECT
    segmento,
    COUNT(DISTINCT id_cliente)                                           AS clientes,
    COUNT(*)                                                             AS transacoes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_total,
    ROUND(
        AVG(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS ticket_medio,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))
        / SUM(SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))) OVER () * 100
    , 1)                                                                 AS participacao_receita_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY segmento;


-- Canal preferido por segmento — Premium e Standard compram pelo mesmo canal?
SELECT
    segmento,
    canal,
    COUNT(*)                                                             AS transacoes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita
FROM vendas
WHERE status = 'Concluída'
GROUP BY segmento, canal
ORDER BY segmento, receita DESC;


-- ============================================================
-- BLOCO 5: ANÁLISE POR CATEGORIA E PRODUTO
-- ============================================================

-- Receita e margem de desconto por categoria
SELECT
    categoria,
    COUNT(*)                                                             AS transacoes,
    SUM(quantidade)                                                      AS unidades_vendidas,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida,
    ROUND(AVG(desconto_pct * 1.0), 1)                                    AS desconto_medio_pct,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))
        / SUM(SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))) OVER () * 100
    , 1)                                                                 AS share_receita_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY categoria
ORDER BY receita_liquida DESC;


-- Top 10 produtos por receita gerada no período
SELECT TOP 10
    produto,
    categoria,
    COUNT(*)                                                             AS pedidos,
    SUM(quantidade)                                                      AS unidades,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida
FROM vendas
WHERE status = 'Concluída'
GROUP BY produto, categoria
ORDER BY receita_liquida DESC;


-- ============================================================
-- BLOCO 6: ANÁLISE POR VENDEDOR
-- ============================================================

-- Ranking de vendedores por receita e volume
SELECT
    vendedor,
    COUNT(*)                                                             AS transacoes,
    COUNT(DISTINCT id_cliente)                                           AS clientes_atendidos,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_liquida,
    ROUND(
        AVG(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS ticket_medio,
    ROUND(AVG(desconto_pct * 1.0), 1)                                    AS desconto_medio_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY vendedor
ORDER BY receita_liquida DESC;


-- Desempenho de vendedores por mês — identifica consistência ou sazonalidade
SELECT
    vendedor,
    DATENAME(MONTH, data_venda)                                          AS mes,
    COUNT(*)                                                             AS transacoes,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita
FROM vendas
WHERE status = 'Concluída'
GROUP BY vendedor, DATENAME(MONTH, data_venda), MONTH(data_venda)
ORDER BY vendedor, MONTH(data_venda);


-- ============================================================
-- BLOCO 7: ANÁLISE DE DESCONTO — HAVING para filtros pós-agregação
-- ============================================================

-- Produtos com desconto médio acima de 5% — alerta de política comercial
SELECT
    produto,
    categoria,
    COUNT(*)                                                             AS transacoes,
    ROUND(AVG(desconto_pct * 1.0), 1)                                    AS desconto_medio_pct,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_com_desconto,
    ROUND(SUM(preco_unitario * quantidade), 2)                           AS receita_sem_desconto,
    ROUND(
        SUM(preco_unitario * quantidade)
        - SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))
    , 2)                                                                 AS desconto_concedido_R$
FROM vendas
WHERE status = 'Concluída'
GROUP BY produto, categoria
HAVING AVG(desconto_pct * 1.0) > 5
ORDER BY desconto_concedido_R$ DESC;


-- Clientes com mais de 2 compras no período — base de clientes recorrentes
SELECT
    cliente,
    segmento,
    COUNT(*)                                                             AS total_compras,
    ROUND(
        SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0)), 2
    )                                                                    AS receita_total
FROM vendas
WHERE status = 'Concluída'
GROUP BY cliente, segmento
HAVING COUNT(*) > 2
ORDER BY total_compras DESC, receita_total DESC;
