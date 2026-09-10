-- Saldo devedor real (valor de quitação) dos contratos de FINANCIAMENTO.
-- Execute no Supabase SQL Editor. Consórcios não são afetados por nada aqui.
--
-- Contexto: até aqui o saldo era `parcelas_restantes * valor_parcela` — soma
-- nominal, que embute juros ainda não corridos e ignora carência. Estas colunas
-- guardam os termos de cada contrato para que o saldo seja recalculado na data
-- de hoje a cada renderização da página.

-- ── 1. Correção de classificação ────────────────────────────────────────────
-- A migração anterior (migrate_consorcio.sql) tratou "Ativuz BNB" como
-- consórcio. São financiamentos do Banco do Nordeste, assim como "AZ BNB" e
-- "Cartão BNB", que já estavam corretos. O SERIDO idem.
update public.financiamentos_contratos
set tipo = 'financiamento'
where id in (
  '25d587f1-2809-44b6-bd56-a1e33af1e86e',  -- Ativuz BNB  183/002  EGX-2E31
  '7e8923af-7b71-4978-8b31-aa33b4f7a30b',  -- Ativuz BNB  183/004  RQJ-7H29
  '8f102762-a238-47ee-9287-a53cdcb4908f',  -- Ativuz BNB  183/003  RQI-7A69 / RQI-7A89
  '7600898a-2c4a-4f68-9ce2-c81680125e7c',  -- Ativuz BNB  183/002  RUC-8C45
  '54b25b0c-06ac-48a5-821d-34fca80cea44'   -- SERIDO BNB  [SERIDO] 183.2026.231.15939
);

-- ── 2. Termos do contrato ───────────────────────────────────────────────────
alter table public.financiamentos_contratos
  -- principal contratado; NULL = contrato ainda não cadastrado, cai no nominal
  add column if not exists valor_financiado        numeric(12,2),
  add column if not exists sistema_amortizacao     text
    check (sistema_amortizacao in ('SAC', 'PRICE')),
  -- taxa efetiva MENSAL em decimal: 0.007531 = 0,7531% a.m.
  add column if not exists taxa_juros_am           numeric(9,6),
  -- nº de parcelas de PRINCIPAL (não conta as parcelas de carência, que são só juros)
  add column if not exists parcelas_amortizacao    integer,
  -- vencimento da 1ª parcela de PRINCIPAL; diferente da 1ª parcela de carência
  add column if not exists data_inicio_amortizacao date,
  add column if not exists periodicidade           text default 'mensal'
    check (periodicidade in ('mensal', 'trimestral')),
  -- pós-fixado (taxa + IPCA): os juros futuros não são estimáveis
  add column if not exists taxa_variavel           boolean default false,
  add column if not exists inadimplente            boolean default false,
  add column if not exists saldo_requer_revisao    boolean default false,
  -- saldo lido de tabela de parcelas impressa; tem precedência sobre a fórmula
  add column if not exists saldo_tabela            numeric(12,2);
