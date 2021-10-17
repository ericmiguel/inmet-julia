module inmet

using HTTP
using CSV
using JSON3
import Dates
using DataFrames


"""
Executa uma chamada GET simples a uma API e retorna uma resposta JSON.

# Examples
```jldoctest
julia> url = "https://apitempo.inmet.gov.br/estacao/2021-01-01/2021-01-02/A756"
julia> resposta = chamarAPI(url)
julia> println(resposta[1])
```
"""
function chamarAPI(url::String)::JSON3.Array
    resposta = HTTP.get(url)
    respostaString = String(resposta.body)
    return JSON3.read(respostaString, allow_inf=true)
end;

"""
Lista as estações meteorológicas no INMET.

# Examples
```jldoctest
julia> estacoes = listarEstacoes(true)
julia> println(estacoes[:, 1])
```
"""
function listarEstacoes(operantes::Bool)::DataFrame
    url = "https://apitempo.inmet.gov.br/estacoes/T"
    listaEstacoesAutomaticasJSON = chamarAPI(url)
    listaEstacoesAutomaticas = DataFrame(listaEstacoesAutomaticasJSON);
    if operantes == true
        listaEstacoesAutomaticasOperantes = listaEstacoesAutomaticas[
            listaEstacoesAutomaticas[:, "CD_SITUACAO"] .== "Operante", :];
    end

    return listaEstacoesAutomaticas
end

"""
Coleta os dados de uma estação INMET.

# Examples
```jldoctest
julia> formato = Dates.DateFormat("y-m-d")
julia> dataInicial = Dates.Date("2021-01-01", formato)
julia> dataFinal = Dates.Date("2021-01-02", formato)
julia> dados = coletarDadosEstacao("A756", dataInicial, dataFinal)
julia> println(resposta[1])
```
"""
function coletarDadosEstacao(
        codigoEstacao::String,
        dataInicial::Dates.Date,
        dataFinal::Dates.Date
)::DataFrame
    urlBaseDadosEstacoes = "https://apitempo.inmet.gov.br/estacao"
    urlQueryDadosEstacoes = "$(dataInicial)/$(dataFinal)/$(codigoEstacao)"
    urlCompleta = "$(urlBaseDadosEstacoes)/$(urlQueryDadosEstacoes)"

    serieEstacaoJSON = chamarAPI(urlCompleta)
    serieEstacao = DataFrame(serieEstacaoJSON)
    
    # substitui valores 'nothing' por 'missing'
    for coluna in names(serieEstacao)
        serieEstacao[!, coluna] = replace(
            serieEstacao[!, coluna], nothing => missing
        )
    end
    
    # se o dataframe gerador for vazio, a função irá parar
    if size(dropmissing(serieEstacao))[1] == 0
        error("não há dados disponíveis para a estação '$(codigoEstacao)'.")
    end
    
    return serieEstacao
end;

"""
Coleta os dados de todas as estações (operantes) e persiste as saídas em formato CSV.

# Examples
```jldoctest
julia> formato = Dates.DateFormat("y-m-d")
julia> dataInicial = Dates.Date("2021-01-01", formato)
julia> dataFinal = Dates.Date("2021-01-02", formato)
julia> coletarDadosEstacoesCSV(
    ["A756", "A223"], dados_estacoes", dataInicial, dataFinal
)
```
"""
function coletarDadosEstacoesCSV(
    dataInicial::Dates.Date,
    dataFinal::Dates.Date,
    diretorioPersistencia::String,
    codigosEstacoes::Union{Vector, Nothing} = nothing,
)

    if !Base.isdir(diretorioPersistencia)
        Base.mkpath(diretorioPersistencia)
    end

    if codigosEstacoes === nothing
        codigosEstacoes = listarEstacoes(true)
    end

    for codigoEstacao in codigosEstacoes
        try
            serieEstacao = coletarDadosEstacao(codigoEstacao, dataInicial, dataFinal)
            CSV.write("$(diretorioPersistencia)/$(codigoEstacao).csv", serieEstacao)
            println("Dados da estação '$(codigoEstacao)' obtidos.")
        catch e
            println("Não foi possível processar os dados de '$(codigoEstacao)': $(e)")
        end
        #=
        Intervalos de tempo são necessários para que a coleta seja feita com sucesso.
        Caso contrário, a API INMET passa a retornar código 200 com mensagens de erro,
        vetando todas as requisições por um período de, normalmente, 1 minuto.
        =#
        Base.sleep(1)
    end
end;


end # module
