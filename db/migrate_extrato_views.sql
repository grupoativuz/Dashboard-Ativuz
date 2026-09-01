-- Views de leitura do extrato ASAAS para projetos que compartilham este banco.
--
-- A tabela asaas_extratos guarda um lote por arquivo importado, com todos os
-- lançamentos dentro da coluna JSON "transacoes". Ler esse JSON direto obriga
-- cada projeto a repetir o parsing. Estas views expõem os mesmos dados em
-- linhas, já deduplicados por tx_id, com data em tipo date.
--
-- Fonte da classificação: _asaas_montar_transacao() em app.py. As categorias
-- gravadas no JSON já vêm classificadas; as regras de reclassificação
-- (_asaas_reclassificar, aliases de motorista, devoluções por tx_id) continuam
-- em Python e NÃO são aplicadas aqui.

-- ── Lançamento a lançamento ────────────────────────────────────────────────
create or replace view vw_asaas_transacoes as
select distinct on (chave)
    e.id                                          as extrato_id,
    coalesce(e.frota, 'luz-divina')               as frota,
    e.periodo,
    coalesce(nullif(t->>'tx_id', ''),
             concat_ws('|', t->>'data', t->>'descricao', t->>'valor')) as chave,
    nullif(t->>'tx_id', '')                       as tx_id,
    to_date(t->>'data', 'DD/MM/YYYY')             as data,
    (to_date(t->>'data', 'DD/MM/YYYY')
       - extract(isodow from to_date(t->>'data', 'DD/MM/YYYY'))::int + 1) as semana,
    t->>'tipo'                                    as tipo,
    t->>'descricao'                               as descricao,
    (t->>'valor')::numeric                        as valor,
    t->>'lancamento'                              as lancamento,
    t->>'categoria'                               as categoria,
    upper(coalesce(t->>'motorista', ''))          as motorista,
    t->>'pagador'                                 as pagador,
    t->>'placa_seguro'                            as placa_seguro,
    coalesce((t->>'relevante')::boolean, true)    as relevante,
    e.created_at
from asaas_extratos e
cross join lateral jsonb_array_elements(e.transacoes::jsonb) as t
where t->>'data' is not null
order by chave, e.created_at;

-- ── Entradas por motorista e semana ────────────────────────────────────────
-- Mesma regra de /api/rentabilidade-real: só aluguel e adesão relevantes; na
-- adesão a caução (fixa por frota) sai do valor, restando a 1ª semana.
create or replace view vw_asaas_por_motorista_semana as
select
    x.frota,
    x.motorista,
    x.semana,
    sum(
      case when x.categoria = 'adesao'
           then greatest(x.valor - c.caucao, 0)
           else x.valor
      end
    ) as recebido
from vw_asaas_transacoes x
join (values ('luz-divina', 3000.0::numeric),
             ('joao-paulo', 1200.0::numeric)) as c(frota, caucao)
  on c.frota = x.frota
where x.relevante
  and x.categoria in ('aluguel', 'adesao')
  and x.motorista <> ''
group by x.frota, x.motorista, x.semana;

-- ── Totais por categoria ───────────────────────────────────────────────────
create or replace view vw_asaas_totais_categoria as
select frota, categoria, count(*) as lancamentos, sum(valor) as total
from vw_asaas_transacoes
where relevante
group by frota, categoria;
