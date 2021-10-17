using Test

include("../src/inmet.jl")

using Main.inmet:listarEstacoes, coletarDadosEstacao, coletarDadosEstacoesCSV
using DataFrames
import Dates

@testset "Listagem de estações INMET" begin
    listaEstacoes = listarEstacoes(true)
    colunasListaEstacoes = names(listaEstacoes)
    @test typeof(listaEstacoes) == DataFrame
    @test nrow(listaEstacoes) > 0
    @test "CD_SITUACAO" in colunasListaEstacoes
    @test "CD_ESTACAO" in colunasListaEstacoes
end

@testset "Coleta de dados de uma estação" begin
    formato = Dates.DateFormat("y-m-d")
    dataInicial = Dates.Date("2021-01-01", formato)
    dataFinal = Dates.Date("2021-01-02", formato)
    serie = coletarDadosEstacao("A756", dataInicial, dataFinal)
    @test typeof(serie) == DataFrame
    @test nrow(serie) > 0
    @test "CHUVA" in names(serie)
end

@testset "Persistência de dados em CSV" begin
    formato = Dates.DateFormat("y-m-d")
    dataInicial = Dates.Date("2021-01-01", formato)
    dataFinal = Dates.Date("2021-01-02", formato)
    coletarDadosEstacoesCSV(["A756", "A255"], "/tmp/inmet", dataInicial, dataFinal)
end