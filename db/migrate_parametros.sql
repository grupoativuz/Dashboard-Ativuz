-- Parâmetros editáveis pela interface (chave/valor numérico).
-- Usado pelo card de Patrimônio Líquido em /benchmarking:
--   pl_frota_fipe  → Valor da Frota (FIPE)
--   pl_saldo_conta → Saldo em Conta
create table if not exists public.parametros (
  chave       text primary key,
  valor       numeric not null default 0,
  updated_at  timestamptz not null default now()
);
