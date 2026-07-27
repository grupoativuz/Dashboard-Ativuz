-- ── Hodômetros semanais ──────────────────────────────────────────────────────
-- Leituras de hodômetro enviadas pelos motoristas toda segunda-feira.
-- Uma linha por (placa, segunda-feira). O km gravado é a LEITURA ABSOLUTA do
-- painel, não o rodado da semana — o rodado é calculado como a diferença entre
-- leituras consecutivas.

create table if not exists hodometros (
    id           uuid primary key default gen_random_uuid(),
    placa        text        not null,
    data_segunda date        not null,
    km           numeric(12,2) not null check (km >= 0),
    created_at   timestamptz not null default now(),
    updated_at   timestamptz not null default now(),
    constraint hodometros_placa_data_uk unique (placa, data_segunda)
);

create index if not exists hodometros_placa_idx on hodometros (placa, data_segunda);

-- Mantém updated_at coerente quando a célula é reeditada.
create or replace function hodometros_touch_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists hodometros_touch on hodometros;
create trigger hodometros_touch
    before update on hodometros
    for each row execute function hodometros_touch_updated_at();


-- Parâmetros de cobrança por placa. Só precisa de linha quando o contrato foge
-- do padrão (1.500 km/semana a R$ 0,50 o km excedente); na ausência de linha o
-- backend aplica os defaults.
create table if not exists hodometro_config (
    placa           text primary key,
    franquia_km     numeric(10,2) not null default 1500 check (franquia_km >= 0),
    valor_km_extra  numeric(10,2) not null default 0.50  check (valor_km_extra >= 0),
    updated_at      timestamptz   not null default now()
);
