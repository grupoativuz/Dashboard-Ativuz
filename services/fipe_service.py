"""
Serviço de integração com a API da Tabela FIPE (Parallelum v2).
Consulta pública, gratuita e sem necessidade de autenticação.
API: https://parallelum.com.br/fipe/api/v2/
"""

import re
import urllib.request
import urllib.error
import json
import logging

logger = logging.getLogger(__name__)

BASE_URL = "https://parallelum.com.br/fipe/api/v2"

# Cache em memória: {(tipo, cod_fipe, ano_modelo): res_dict}
_CACHE = {}


def extrair_ano_modelo(ano_str: str) -> str:
    """
    Extrai o ano modelo a partir de strings como:
    '2019/2020' -> '2020'
    '2021/2021' -> '2021'
    '2020'      -> '2020'
    """
    if not ano_str:
        return ""
    ano_str = str(ano_str).strip()
    if "/" in ano_str:
        partes = ano_str.split("/")
        return partes[-1].strip()
    m = re.findall(r"\b\d{4}\b", ano_str)
    if m:
        return m[-1]
    return ano_str


def _fazer_requisicao(url: str, timeout: int = 8):
    """Executa requisição GET com User-Agent para a API FIPE."""
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "Dashboard-Ativuz/1.0 (Mozilla/5.0 compatible)"}
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        if resp.status == 200:
            return json.loads(resp.read().decode("utf-8"))
    return None


def consultar_preco_fipe(cod_fipe: str, ano_modelo_str: str, tipo_veiculo: str = "cars") -> dict:
    """
    Consulta o valor venal do veículo na Tabela FIPE.
    Retorna dict:
    {
        "ok": True,
        "cod_fipe": "005490-9",
        "ano_modelo": "2020",
        "valor": 45000.0,
        "valor_fmt": "R$ 45.000,00",
        "mes_ref": "setembro de 2026",
        "modelo": "Gol 1.0 Flex 12V 5p",
        "marca": "VW - VolksWagen"
    }
    ou {"ok": False, "erro": "..."}
    """
    cod = (cod_fipe or "").strip()
    # Remove qualquer caractere fora de dígitos e hífen
    cod = re.sub(r"[^0-9\-]", "", cod)
    if not cod:
        return {"ok": False, "erro": "Código FIPE inválido."}

    # Garante formato com hífen se tiver 7 dígitos sem hífen (ex: 0054909 -> 005490-9)
    if len(cod) == 7 and "-" not in cod:
        cod = f"{cod[:6]}-{cod[6:]}"

    ano_alvo = extrair_ano_modelo(ano_modelo_str)
    if not ano_alvo:
        return {"ok": False, "erro": "Ano modelo não informado."}

    # Se código FIPE começa com 8, é motocicleta no padrão da FIPE
    if cod.startswith("8") and tipo_veiculo == "cars":
        tipo_veiculo = "motorcycles"

    cache_key = (tipo_veiculo, cod, ano_alvo)
    if cache_key in _CACHE:
        return _CACHE[cache_key]

    # Tenta tipos de veículo: começa pelo selecionado, depois outros se falhar
    tipos = [tipo_veiculo]
    for alt in ["cars", "motorcycles", "trucks"]:
        if alt not in tipos:
            tipos.append(alt)

    for tipo in tipos:
        try:
            # 1. Consulta anos disponíveis para o código FIPE
            url_anos = f"{BASE_URL}/{tipo}/{cod}/years"
            anos = _fazer_requisicao(url_anos)
            if not anos or not isinstance(anos, list):
                continue

            # 2. Localiza o ano que inicia com o ano modelo (ex: "2020-5" começa com "2020")
            ano_selecionado = None
            for item in anos:
                code = str(item.get("code", ""))
                if code.startswith(ano_alvo):
                    ano_selecionado = code
                    break

            if not ano_selecionado:
                # Se não achou exato, tenta verificar se o nome contém o ano
                for item in anos:
                    if ano_alvo in str(item.get("name", "")):
                        ano_selecionado = item["code"]
                        break

            if not ano_selecionado:
                continue

            # 3. Consulta cotação detalhada do veículo naquele ano
            url_preco = f"{BASE_URL}/{tipo}/{cod}/years/{ano_selecionado}"
            dados = _fazer_requisicao(url_preco)
            if not dados or "price" not in dados:
                continue

            preco_str = str(dados.get("price", "0"))
            # Limpa preço: "R$ 51.200,00" -> 51200.00
            preco_limpo = re.sub(r"[^\d,]", "", preco_str).replace(",", ".")
            valor_num = float(preco_limpo) if preco_limpo else 0.0

            res = {
                "ok": True,
                "cod_fipe": cod,
                "ano_modelo": ano_alvo,
                "ano_codigo": ano_selecionado,
                "valor": valor_num,
                "valor_fmt": preco_str,
                "mes_ref": dados.get("referenceMonth", ""),
                "modelo": dados.get("model", ""),
                "marca": dados.get("brand", ""),
                "combustivel": dados.get("fuel", ""),
            }
            _CACHE[cache_key] = res
            return res

        except Exception as e:
            # 404 é normal ao tentar um tipo que não é aquele veículo
            continue

    return {
        "ok": False,
        "cod_fipe": cod,
        "ano_modelo": ano_alvo,
        "erro": f"Cotação não encontrada na FIPE para {cod} ano {ano_alvo}."
    }


def consultar_lote_fipe(entradas: list) -> list:
    """
    Consulta uma lista de dicts [{'cod_fipe': '...', 'ano_modelo': '...', ...}]
    em paralelo para resposta rápida (sub-segundo).
    """
    from concurrent.futures import ThreadPoolExecutor

    def _worker(item):
        cod = item.get("cod_fipe", "")
        ano = item.get("ano_modelo", "")
        res = consultar_preco_fipe(cod, ano)
        return {**item, **res}

    with ThreadPoolExecutor(max_workers=6) as executor:
        resultados = list(executor.map(_worker, entradas))

    return resultados

