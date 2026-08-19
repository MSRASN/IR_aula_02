
# Carregamento das bibliotecas necessárias

install.packages("tidyverse")
install.packages("readxl")


library(tidyverse)
library(readxl)

# ------------------------------------------------------------------------------
# PARTE 1: IMPORTAÇÃO E EXPLORAÇÃO INICIAL
# ------------------------------------------------------------------------------

# Importação dos dados tratando valores ausentes (NAs) de forma consistente
alunos <- read_delim("dados/alunos.txt", delim = " ", na = c("NA", ""), show_col_types = FALSE)
desempenho <- read_csv("dados/desempenho.csv", na = c("NA", ""), show_col_types = FALSE)
pagamentos <- read_excel("dados/pagamentos.xlsx")


# Visualização estrutural rápida das variáveis carregadas na memória
glimpse(alunos)
glimpse(desempenho)
glimpse(pagamentos)

# visualização da base
View(alunos)
View(desempenho)
View(pagamentos)


# ------------------------------------------------------------------------------
# PARTE 2: SELEÇÃO E FILTRAGEM (select, filter e arrange)
# ------------------------------------------------------------------------------

# Seleção de colunas usando funções auxiliares (tidyselect)
alunos |>
  select(id_aluno, nome, starts_with("fone_"), "email")



# Filtragem de linhas com base em múltiplos operadores lógicos e vetoriais

alunos |> filter(situacao == "Ativo" & 
                   estado %in% c("PE", "PB", "BA")  )


alunos |>
  filter(
    situacao == "Ativo",
    estado %in% c("PE", "PB", "BA"),
    turno != "Noite"
  )

# Ordenação de registros com base em variáveis numéricas (decrescente)
desempenho_estudo <- desempenho |>
  arrange(desc(horas_estudo))

# ------------------------------------------------------------------------------
# PARTE 3: CRIAÇÃO E MODIFICAÇÃO DE VARIÁVEIS (mutate)
# ------------------------------------------------------------------------------

# Criação de variável numérica simples
desempenho_media <- desempenho |>
  mutate(media_provas = (prova_1 + prova_2) / 2)



if(FALSE){
print("OLA MUNDO")
} else{
  print("ola mundo")
}


# Criação de variável categórica binária usando if_else()
desempenho_categoria <- desempenho_media |>
  mutate(
    status_prova = if_else(media_provas >= 7.0, "Acima da Media", "Abaixo da Media")
  )


# Criação de variável categórica múltipla usando case_when()
desempenho_perfil <- desempenho |>
  mutate(
    perfil_horas = case_when(
      horas_estudo >= 25 ~ "Alta Dedicacao",
      horas_estudo >= 12 ~ "Dedicacao Regular",
      TRUE ~ "Dedicacao Baixa"
    )
  )

# ------------------------------------------------------------------------------
# PARTE 4: AGREGAÇÕES E SUMARIZAÇÕES (group_by + summarise)
# ------------------------------------------------------------------------------

# Resumos descritivos agregados com remoção explícita de agrupamentos posteriores
relatorio_cursos <- desempenho |>
  group_by(curso_id) |>
  summarise(
    total_alunos = n(),
    media_projeto = mean(projeto, na.rm = TRUE),
    mediana_horas = median(horas_estudo, na.rm = TRUE),
    desvio_padrao_trabalho = sd(trabalho, na.rm = TRUE),
  ) |>
  ungroup()




desempenho |> 
  group_by(curso_id) |> 
  summarise(
    media_projeto_curso = mean(projeto, na.rm = TRUE)
  )

# e se eu quiser adicionar a média do projeto do curso para cada aluno pertencente a ele?
# assim poderei calcular o quanto o aluno se desviou em relação a média do seu grupo

desempenho |> 
  group_by(curso_id) |> 
  mutate(
    media_projeto_curso = mean(projeto, na.rm = TRUE),
    desvio_da_media = projeto - media_projeto_curso
  ) |> 
  select(id_aluno, curso_id, projeto, media_projeto_curso, desvio_da_media)


# agora imagine que quero pegar apenas os alunos que possuem uma nota maior que a média em cada curso

desempenho |> 
  group_by(curso_id) |> 
  mutate(media_projeto_curso = mean(projeto, na.rm = TRUE)) |>
  filter(projeto > media_projeto_curso) |>
  select(id_aluno,projeto,media_projeto_curso)
 
# e se eu quiser o aluno com a maior nota em cada curso?

desempenho |> 
  group_by(curso_id) |> 
  slice_max(projeto, n = 1) |>
  arrange(curso_id) |>
  ungroup()

# se quiser tirar os empates

desempenho |> 
  group_by(curso_id) |> 
  slice_max(projeto, n = 1, with_ties = FALSE) |> 
  arrange(curso_id) |> 
  ungroup()

# Em caso de empate na nota do projeto, escolhe quem teve mais horas de estudo
desempenho |> 
  group_by(curso_id) |> 
  slice_max(order_by = tibble(projeto, horas_estudo), n = 1, with_ties = FALSE) |> 
  arrange(curso_id) |> 
  ungroup()



# ------------------------------------------------------------------------------
# PARTE 5: TRANSFORMAÇÕES EM ESCALA (across)
# ------------------------------------------------------------------------------

nome_funcao = function(x){
  x
}

nome_funcao = function(x) x

nome_funcao = \(x)x

nome_funcao(10)

# Aplicação de funções em lote para imputar valores ausentes e arredondar notas
desempenho_tratado <- desempenho |>
  mutate(
    across(
      c(prova_1, prova_2, trabalho, projeto),
      ~ round(replace_na(.x,0), 1)
    )
  )

# e se eu quiser criar uma função customizada?

# Define a regra customizada fora do pipeline
tratar_nota_custom <- function(x, teto = 10, padrao_na = 0) {
  x |> 
    replace_na(padrao_na) |>  # Substitui qualquer valor ausente (NA) pelo valor definido em padrao_na (que por padrão é 0).
    pmin(teto) |>  # Se algum valor for maior que 10 (ex: 10.5 por ponto extra), ele é truncado para exatamente 10.0. Qualquer valor abaixo de 10 permanece inalterado.
    round(digits = 1)
}


desempenho |> 
  mutate( 
    across(c(prova_1,prova_2), tratar_nota_custom)
    )

desempenho$comportamento_frequencia

desempenho |> select(comportamento_frequencia)

# ------------------------------------------------------------------------------
# PARTE 6: HIGIENIZAÇÃO E REESTRUTURAÇÃO DE STRINGS (tidyr)
# ------------------------------------------------------------------------------

# 1. separate(): Divisão simples de texto por caractere delimitador
desempenho_comportamento <- desempenho |>
  separate(
    col = comportamento_frequencia,
    into = c("frequencia_raw", "participacao_raw"),
    sep = "\\|"
  )

# 2. extract(): Divisão complexa de texto via expressões regulares com grupos de captura
pagamentos_extraidos <- pagamentos |>
  # 1. Remove o prefixo fixo "TRX-" da string usando stringr (sem regex)
  mutate(codigo_limpo = str_remove(codigo_transacao, "TRX-")) |>
  
  # 2. Divide a coluna pelo separador "_" (gera a data de um lado e o resto do outro)
  separate_wider_delim(
    cols = codigo_limpo,
    delim = "_",
    names = c("data_pagamento_raw", "metodo_comprovante")
  ) |>
  
  # 3. Divide a segunda parte pelo separador "-" em metodo e comprovante
  separate_wider_delim(
    cols = metodo_comprovante,
    delim = "-",
    names = c("metodo_pagamento", "comprovante_num")
  ) |>
  
  # 4. Converte a data e limpa colunas auxiliares
  mutate(data_pagamento = ymd(data_pagamento_raw)) |>
  select(-data_pagamento_raw)

# 3. separate_rows(): Desdobramento de strings com múltiplos valores em novas linhas
alunos_idiomas_longo <- alunos |>
  drop_na(idiomas) |>
  separate_rows(idiomas, sep = ";")

alunos$idiomas

#visualizando
alunos_idiomas_longo |> filter(id_aluno == 1001) |> select(idiomas)
alunos |> filter(id_aluno == 1001) |> select(idiomas)


# 4. pivot_longer(): Mudança estrutural de tabela do formato largo para formato longo
desempenho_longo <- desempenho |>
  pivot_longer(
    cols = c(prova_1, prova_2, trabalho, projeto),
    names_to = "avaliacao_tipo",
    values_to = "nota"
  )

# ------------------------------------------------------------------------------
# PARTE 7: CRUZAMENTO DE TABELAS (joins)
# ------------------------------------------------------------------------------

# Junção externa à esquerda preservando todos os registros da base principal
alunos_notas_financas <- alunos |>
  left_join(desempenho, by = c("id_aluno", "curso_id")) |>
  left_join(pagamentos, by = "id_aluno")

View(alunos_notas_financas)



# Junção de filtragem para identificar inconsistências cadastrais entre tabelas
# filtrar a primeira tabela (alunos), mantendo apenas os registros que NÃO encontram nenhuma correspondência na segunda tabela (pagamentos).

alunos_inconsistentes <- alunos |>
  anti_join(pagamentos, by = "id_aluno")
View(alunos_inconsistentes)
View(pagamentos)
