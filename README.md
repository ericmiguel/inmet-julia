# INMET

Coleta de dados meteorológicas das estações INMET.

:warning: É apenas um projeto de estudo inicial da linguagem Julia.

## :world_map: Conteúdo

1. [O que faz](#sparkles-o-que-faz)  
2. [Documentação](#scroll-documentação)
3. [Desenvolvimento](#construction-desenvolvimento)
   1. [Preparação do ambiente](#preparação-do-ambiente)
   2. [Testes](#testes)

## :sparkles: O que faz

:heavy_check_mark: coleta e parsing de dados da API INMET  
:heavy_check_mark: persistência dos dados em formato CSV  
:wrench: gráficos e mapas  

## :scroll: Documentação

Em construção.

## :construction: Desenvolvimento

### Preparação do ambiente

```bash
# 1. entre no diretório do projeto e ative o ambiente com o REPL
shell> cd inmet-julia
pkg> activate .

# 2. instale e pré-compile as dependências do projeto
(inmet) pkg> instantiate
(inmet) pkg> precompile
```

### Testes

Com o ambiente do projeto ativo, execute:

```bash
(inmet) pkg> test
```
