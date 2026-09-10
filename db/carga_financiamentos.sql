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


-- ════════════════════════════════════════════════════════════════════════════
-- PENDENTES — não execute sem confirmar antes
-- ════════════════════════════════════════════════════════════════════════════

-- 035/004 (EWJ-2I45) e 035/005 (EXF-1F14) são indistinguíveis pelos dados:
-- ambos têm 30 parcelas terminando em 15/04/2028, e os dois PDFs de 02/04/2025
-- (R$ 46.170,00 e R$ 47.700,00) têm exatamente o mesmo prazo, mesma 1ª parcela
-- e mesma taxa. Só o documento original diz qual placa é qual.
--
-- update public.financiamentos_contratos set
--   valor_financiado = 46170.00, sistema_amortizacao = 'SAC',
--   parcelas_amortizacao = 30, data_inicio_amortizacao = '2025-11-15',
--   periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007531
-- where id = '4aced2ac-c441-44bf-9fac-89975848c895';  -- 035/004 EWJ-2I45
--
-- update public.financiamentos_contratos set
--   valor_financiado = 47700.00, sistema_amortizacao = 'SAC',
--   parcelas_amortizacao = 30, data_inicio_amortizacao = '2025-11-15',
--   periodicidade = 'mensal', taxa_variavel = false, taxa_juros_am = 0.007531
-- where id = 'f5aa553e-8035-4251-a50f-8077341dbdca';  -- 035/005 EXF-1F14

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
