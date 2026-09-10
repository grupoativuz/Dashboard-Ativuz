-- Carga dos termos dos contratos de financiamento, extraídos dos documentos em
-- PDF'S/. Execute DEPOIS de db/migrate_saldo_real.sql.
--
-- taxa_juros_am é a taxa efetiva MENSAL em decimal. Nos contratos pós-fixados
-- (taxa_variavel = true) ela é apenas a componente fixa convertida de a.a. para
-- a.m.; o IPCA se soma a ela e não é previsível. O saldo SAC não depende da
-- taxa — ela fica registrada para conferência e para o cálculo de juros.

-- ── CCB 62329 · AGN [AGÊNCIA DIGITAL] · SAC · pós-fixado 3,9139% a.a. + IPCA ─
update public.financiamentos_contratos set
  valor_financiado = 100000.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 45, data_inicio_amortizacao = '2026-04-15',
  periodicidade = 'mensal', taxa_variavel = true, taxa_juros_am = 0.003204
where id = 'f177d343-6877-4f7b-b801-a0fb9fc7f38f';

-- ── CCB 62970 · AGN [ATIVUZ] · SAC · pós-fixado 3,8789% a.a. + IPCA ──────────
update public.financiamentos_contratos set
  valor_financiado = 100000.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2026-09-15',
  periodicidade = 'mensal', taxa_variavel = true, taxa_juros_am = 0.003176
where id = '1c62fd74-4081-46ef-b3ee-78d63f120940';

-- ── CCB 64342 · AGN [LTV] · SAC · pós-fixado 3,8689% a.a. + IPCA ─────────────
update public.financiamentos_contratos set
  valor_financiado = 95000.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2027-01-15',
  periodicidade = 'mensal', taxa_variavel = true, taxa_juros_am = 0.003168
where id = '11b0470a-4046-4c4e-b719-2a7635d02ec4';

-- ── CET-ANEXO · SERIDO 183.2026.231.15939 · SAC · pré-fixado 0,7595% a.m. ────
-- Valor contratado 502.612,80 (líquido liberado 497.586,67, após tarifa de
-- análise de viabilidade de 5.026,13). O saldo devedor acompanha o contratado.
update public.financiamentos_contratos set
  valor_financiado = 502612.80, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 54, data_inicio_amortizacao = '2027-01-19',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007595
where id = '54b25b0c-06ac-48a5-821d-34fca80cea44';

-- ── Cartões BNB (FNE Investimento) · SAC · pré-fixado ────────────────────────
-- 035/003 ECM-1C93 ← PDF "13-03-2025 - R$ 44.505,00" (1ª amort. 15/10/2025)
update public.financiamentos_contratos set
  valor_financiado = 44505.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2025-10-15',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007499
where id = 'affe029e-32c0-458c-9e0d-cee0c5b2a328';

-- 035/006 RNC-4J20 ← PDF "18-06-2025 - R$ 44.640,00" (23 parcelas, 1ª 15/02/2026)
update public.financiamentos_contratos set
  valor_financiado = 44640.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 23, data_inicio_amortizacao = '2026-02-15',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007559
where id = 'c889f747-3fa7-4f10-b83e-b68da200ad5a';

-- 035/007 ELY-4D83 ← PDF "16-07-2025 - R$ 47.430,00" (1ª amort. 15/03/2026)
update public.financiamentos_contratos set
  valor_financiado = 47430.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2026-03-15',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.008699
where id = '74c89d5c-ecc7-4f0d-aef8-9f9cbd507b15';

-- Os dois PDFs de 02/04/2025 têm prazo, 1ª parcela e taxa idênticos; o vínculo
-- com a placa foi confirmado pelo controle de contratos da AZ Empreendimentos.
-- 035/005 EXF-1F14 ← PDF "02-04-2025 - R$ 46.170,00"
update public.financiamentos_contratos set
  valor_financiado = 46170.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2025-11-15',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007531
where id = 'f5aa553e-8035-4251-a50f-8077341dbdca';

-- 035/004 EWJ-2I45 ← PDF "02-04-2025 - R$ 47.700,00"
update public.financiamentos_contratos set
  valor_financiado = 47700.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 30, data_inicio_amortizacao = '2025-11-15',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007531
where id = '4aced2ac-c441-44bf-9fac-89975848c895';


-- ════════════════════════════════════════════════════════════════════════════
-- PENDENTES — não execute sem confirmar antes
-- ════════════════════════════════════════════════════════════════════════════

-- Sicredi 01 (10585560): não há documento na pasta. As 46 parcelas de
-- R$ 703,51 e a 1ª em 12/08/2025 batem com o caso de teste do enunciado, mas a
-- taxa de 2% a.m. de lá é suposta, não lida de contrato. Confirme antes.
--
-- update public.financiamentos_contratos set
--   valor_financiado = 32361.46, sistema_amortizacao = 'PRICE',
--   parcelas_amortizacao = 46, data_inicio_amortizacao = '2025-08-12',
--   periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.020000
-- where id = '42a8cda6-42b1-44dc-8c0b-4f98af94c23c';

-- Sem documento na pasta: Cartão BNB 02 (BNB-CARD/02, 52 parcelas de
-- R$ 2.346,70) e os 4 contratos "Ativuz BNB" (183/002 ×2, 183/003, 183/004).
-- Os 3 PDFs em "Financiamentos Ativuz/" (37.258,00 / Compra 15.942,00 /
-- Compra 46.800,00) são imagens sem camada de texto: precisam de OCR ou
-- digitação manual.


-- ════════════════════════════════════════════════════════════════════════════
-- Segunda leva — conferida contra o controle de contratos
-- ════════════════════════════════════════════════════════════════════════════
-- Os 3 PDFs de "Financiamentos Ativuz/" são imagens sem camada de texto; o
-- valor financiado veio do nome do arquivo e foi confirmado pelo controle.
-- A taxa não é legível nesses documentos e fica NULL: o saldo SAC não depende
-- dela (só o rateio de juros da parcela depende).

-- 183/003 · RQI-7A69 / RQI-7A89 ← "37.258,00.pdf" · 48 parcelas, 1ª 15/10/2025
update public.financiamentos_contratos set
  valor_financiado = 37258.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 48, data_inicio_amortizacao = '2025-10-15',
  periodicidade = 'mensal', taxa_variavel = false
where id = '8f102762-a238-47ee-9287-a53cdcb4908f';

-- 183/002 · EGX-2E31 ← "Compra 46.800,00.pdf" · 36 parcelas, 1ª 15/04/2025
update public.financiamentos_contratos set
  valor_financiado = 46800.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 36, data_inicio_amortizacao = '2025-04-15',
  periodicidade = 'mensal', taxa_variavel = false
where id = '25d587f1-2809-44b6-bd56-a1e33af1e86e';

-- 183/004 · RQJ-7H29 ← "Compra 15.942,00.pdf" · 48 parcelas, 1ª 15/05/2025
update public.financiamentos_contratos set
  valor_financiado = 15942.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 48, data_inicio_amortizacao = '2025-05-15',
  periodicidade = 'mensal', taxa_variavel = false
where id = '7e8923af-7b71-4978-8b31-aa33b4f7a30b';

-- 183/002 · RUC-8C45 ("BNB 4") ← "Demonstrativos - Ativuz - Compras 2026.pdf"
-- A tabela impressa traz principal constante de 1.350,00 (44.550 / 33), parcela
-- 1 em 15/05/2026 só de juros e a 1ª de principal em 15/06/2026, fechando em
-- 15/02/2029 — o vencimento já registrado nesta linha.
update public.financiamentos_contratos set
  valor_financiado = 44550.00, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 33, data_inicio_amortizacao = '2026-06-15',
  periodicidade = 'mensal', taxa_variavel = false
where id = '7600898a-2c4a-4f68-9ce2-c81680125e7c';

-- Sicredi 01 · 10585560 (FIN-1028) · PRICE · 2,0000% a.m.
-- A taxa foi confirmada por dois caminhos independentes: é a que reproduz o
-- valor financiado de 21.029,54 a partir de 46 parcelas de 703,51, e é a mesma
-- que gera o saldo de 16.876,19 com 33 parcelas restantes.
update public.financiamentos_contratos set
  valor_financiado = 21029.54, sistema_amortizacao = 'PRICE',
  parcelas_amortizacao = 46, data_inicio_amortizacao = '2025-08-12',
  periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.020000
where id = '42a8cda6-42b1-44dc-8c0b-4f98af94c23c';

-- Cartão BNB 02 · BNB-CARD/02 ("BNB 5") · em carência
-- ATENÇÃO: só o valor financiado (95.310,99) é documentado. O cronograma abaixo
-- foi DERIVADO do vencimento de 15/08/2031 e das 52 parcelas registradas, não
-- lido de contrato. Enquanto o contrato estiver em carência o saldo é o valor
-- financiado e isso não afeta o número; a partir de 15/05/2027 afeta. Substitua
-- pelos dados reais antes dessa data.
update public.financiamentos_contratos set
  valor_financiado = 95310.99, sistema_amortizacao = 'SAC',
  parcelas_amortizacao = 52, data_inicio_amortizacao = '2027-05-15',
  periodicidade = 'mensal', taxa_variavel = false
where id = 'def23e9f-0dfd-4b23-8538-919827cabd40';
