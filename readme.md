# 📈 Commercial KPIs by Dimension — Q1 2024

![SQL](https://img.shields.io/badge/SQL-Server-blue?style=flat-square&logo=microsoftsqlserver)
![Período](https://img.shields.io/badge/período-Q1%202024-lightgrey?style=flat-square)
![Dimensões](https://img.shields.io/badge/dimensões-região%20·%20canal%20·%20vendedor%20·%20segmento-informational?style=flat-square)

> Análise multidimensional de performance comercial de um e-commerce B2B no Q1 2024. O objetivo foi decompor a receita por diferentes ângulos — região, canal, segmento de cliente, categoria e vendedor — para identificar onde o negócio performa bem, onde há risco e onde existe oportunidade.

---

## 🔎 Principais Achados

### Receita está concentrada, não distribuída
O **Sudeste responde por mais de 70% da receita total** do período, puxado principalmente por SP. As regiões Norte e Centro-Oeste juntas representam menos de 8% — o que pode indicar tanto baixa penetração quanto potencial inexplorado dependendo da estratégia de expansão.

### Canal Online lidera em receita, mas Televendas tem melhor ticket médio
O canal **Online** gera o maior volume de transações e receita absoluta. No entanto, o **Televendas** apresenta ticket médio superior — sugerindo que o contato consultivo favorece vendas de maior valor. Loja Física registra a maior taxa de cancelamento dos três canais.

### Clientes Premium representam a maior parte da receita com menos clientes
O segmento **Premium** concentra receita desproporcional ao seu tamanho na base — comportamento esperado em B2B, mas que reforça a importância de programas de retenção e expansão desse segmento. Clientes Standard têm ticket médio significativamente menor e maior dispersão de canal.

### Eletrônicos domina, mas Periféricos tem o maior volume de transações
**Eletrônicos** lidera em receita absoluta por conta do preço unitário elevado. **Periféricos** aparece com mais transações — indicando maior recorrência de compra e potencial para estratégias de cross-sell. A categoria Outros (impressoras) tem o menor giro e maior concentração de pedidos pendentes.

### Um vendedor concentra mais de 40% das transações
**Lucas Andrade** aparece em mais de 40% das vendas concluídas do período, com o maior número de clientes atendidos. Isso pode ser um ponto de atenção para gestão de risco de concentração — ou um benchmark interno para os demais.

### Descontos acima de 10% aparecem em produtos de alto valor sem critério claro
Alguns produtos da categoria Eletrônicos registram desconto médio acima de 10%, o que compromete a margem sem evidência de que está associado a volume ou segmento. Vale revisão de política comercial.

---

## 🎯 Contexto da Análise

Em B2B, olhar apenas o total de receita esconde mais do que revela. Este projeto parte de 36 transações do Q1 2024 com 15 atributos e aplica agregações por múltiplas dimensões para responder perguntas que aparecem em reuniões de resultado, revisões de estratégia e apresentações para liderança.

---

## 🗂️ Estrutura do Repositório

```
commercial-kpis-by-dimension/
│
├── data/
│   └── vendas_q1_2024.csv              # 36 transações · 15 atributos
│
├── scripts/
│   ├── setup.sql                       # Criação da tabela e carga dos dados
│   └── performance_comercial.sql       # Análises organizadas por dimensão
│
└── README.md
```

---

## 📐 Estrutura do Dataset

| Atributo | Descrição |
|----------|-----------|
| `data_venda` | Data da transação |
| `cliente` / `segmento` | Identificação e classificação (Premium · Standard) |
| `canal` | Canal de origem (Online · Loja · Televendas) |
| `regiao` / `estado` | Localização geográfica |
| `vendedor` | Responsável pela venda |
| `produto` / `categoria` | Item vendido e sua categoria |
| `quantidade` / `preco_unitario` | Volume e valor unitário |
| `desconto_pct` | Percentual de desconto aplicado |
| `status` | Situação da venda (Concluída · Cancelada · Pendente) |

---

## 💡 Destaques Técnicos

**Participação percentual na receita sem subquery** — usando `SUM() OVER()`:
```sql
SELECT segmento,
       ROUND(
           SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))
           / SUM(SUM(preco_unitario * quantidade * (1 - desconto_pct / 100.0))) OVER () * 100
       , 1) AS participacao_receita_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY segmento;
```

**HAVING para alertas de política comercial** — filtra apenas grupos que excedem o limiar:
```sql
SELECT produto, ROUND(AVG(desconto_pct * 1.0), 1) AS desconto_medio_pct
FROM vendas
WHERE status = 'Concluída'
GROUP BY produto
HAVING AVG(desconto_pct * 1.0) > 5
ORDER BY desconto_medio_pct DESC;
```

---

## 🚀 Como Executar

```bash
git clone https://github.com/MileneCaldeira/commercial-kpis-by-dimension.git
```

No seu client SQL (SSMS, DBeaver, Azure Data Studio):
1. Execute `scripts/setup.sql` para criar e carregar a tabela
2. Execute `scripts/performance_comercial.sql` bloco a bloco

Compatível com **SQL Server**, **PostgreSQL** e **MySQL**.
Teste online sem instalação em [db-fiddle.com](https://www.db-fiddle.com).

---

## 📅 Série: 28 Dias de Dados

| Dia | Projeto | Foco Analítico |
|-----|---------|----------------|
| ✅ 01 | [sql-consultas-basicas](https://github.com/MileneCaldeira/sql-consultas-basicas) | Filtragem e exploração de dados |
| ✅ 02 | [ecommerce-b2b-sql-analysis](https://github.com/MileneCaldeira/ecommerce-b2b-sql-analysis) | Modelo relacional e cruzamento de tabelas |
| ✅ 03 | [commercial-kpis-by-dimension](.) | KPIs comerciais por dimensão |
| 🔜 04 | Em breve | Subconsultas e análises avançadas |
| 🔜 ... | ... | ... |

---

## 👩‍💻 Sobre

**Milene Caldeira** — BI Analyst com foco em dados comerciais, SQL, Power BI e cloud.

[![GitHub](https://img.shields.io/badge/GitHub-MileneCaldeira-black?style=flat-square&logo=github)](https://github.com/MileneCaldeira)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/milene-caldeira/)
