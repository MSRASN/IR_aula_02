# ==============================================================================
# SCRIPT DE RESOLUÇÃO DAS QUESTÕES (1 A 8)
# CONTEXTO: BANCO DE DADOS DE ALUNOS
# ==============================================================================

# Carregamento de bibliotecas básicas
library(tidyverse)
library(readxl)

# Importação das tabelas de dados
alunos <- read_delim("dados/alunos.txt", delim = " ", na = c("NA", ""), show_col_types = FALSE)
desempenho <- read_csv("dados/desempenho.csv", na = c("NA", ""), show_col_types = FALSE)
pagamentos <- read_excel("dados/pagamentos.xlsx")


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 1
# ------------------------------------------------------------------------------
resultado_q1 <- alunos |>
  select(id_aluno, nome, email, starts_with("data"))


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 2
# ------------------------------------------------------------------------------
resultado_q2 <- alunos |>
  filter(situacao == "Ativo",  estado %in% c("PE", "PB"))


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 3
# ------------------------------------------------------------------------------
resultado_q3 <- desempenho |>
  mutate(media_provas = (prova_1 + prova_2) / 2)


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 4
# ------------------------------------------------------------------------------
# Definição vetorizada da função usando case_when()
classificar_horas <- function(numero) {
  case_when(
    numero >= 20 ~ "Alta Dedicacao",
    numero >= 10 ~ "Dedicacao Regular",
    TRUE         ~ "Dedicacao Baixa"
  )
}

# Aplicação da função na tabela de desempenho
resultado_q4 <- desempenho |>
  mutate(perfil_estudo = classificar_horas(horas_estudo))


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 5
# ------------------------------------------------------------------------------
resultado_q5 <- desempenho |>
  mutate(
    across(
      c(prova_1, prova_2, trabalho, projeto),
      ~ round(replace_na(.x, 0), 1)
    )
  )


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 6
# ------------------------------------------------------------------------------
resultado_q6 <- pagamentos |>
  group_by(status_pagamento) |>
  summarise(
    total_transacoes = n(),
    media_mensalidade = mean(mensalidade, na.rm = TRUE),
    total_acumulado = sum(mensalidade, na.rm = TRUE),
    .groups = "drop"
  )


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 7
# ------------------------------------------------------------------------------
# 7.1. Divisão do código de transação financeira de forma literal (sem regex)
pagamentos_q7_1 <- pagamentos |>
  separate(codigo_transacao, into = c("temp_trx", "resto"), sep = "-", extra = "merge", remove = FALSE) |>
  separate(resto, into = c("data_e_metodo", "comprovante_id"), sep = "-") |>
  separate(data_e_metodo, into = c("data_pagamento_raw", "forma_pagamento"), sep = "_") |>
  mutate(
    data_pagamento = ymd(data_pagamento_raw),
    forma_pagamento = str_to_title(forma_pagamento)
  ) |>
  select(-temp_trx, -data_pagamento_raw)

# 7.2. Divisão do campo de parcelas de forma literal (sem regex)
pagamentos_q7_2 <- pagamentos |>
  separate(parcelamento, into = c("temp_prefixo", "resto_parcelas"), sep = "_") |>
  separate(resto_parcelas, into = c("parcela_atual", "total_parcelas"), sep = "/", convert = TRUE) |>
  select(-temp_prefixo)

# 7.3. Desdobramento de múltiplos idiomas por caractere literal
alunos_q7_3 <- alunos |>
  drop_na(idiomas) |>
  separate_rows(idiomas, sep = ";")


# ------------------------------------------------------------------------------
# RESOLUÇÃO: QUESTÃO 8
# ------------------------------------------------------------------------------
# Pipeline unificado para auditoria de faturamento atrasado (sem regex)
resultado_q8 <- alunos |>
  # 1. Mantém apenas alunos ativos
  filter(situacao == "Ativo") |>
  
  # 2. Junção com as tabelas de suporte
  left_join(desempenho, by = c("id_aluno", "curso_id")) |>
  left_join(pagamentos, by = "id_aluno") |>
  
  # 3. Tratamento de notas e cálculo da média individual
  mutate(
    across(c(prova_1, prova_2, trabalho, projeto), ~ round(replace_na(.x, 0), 1)),
    media_final = (prova_1 + prova_2 + trabalho + projeto) / 4
  ) |>
  
  # 4. Decodificação do código de faturamento (divisões literais sem regex)
  separate(codigo_transacao, into = c("temp_trx", "resto"), sep = "-", extra = "merge", remove = FALSE) |>
  separate(resto, into = c("data_e_metodo", "comprovante_id"), sep = "-") |>
  separate(data_e_metodo, into = c("data_pagamento_raw", "forma_pagamento"), sep = "_") |>
  mutate(
    data_pagamento = ymd(data_pagamento_raw),
    forma_pagamento = str_to_title(forma_pagamento)
  ) |>
  select(-temp_trx, -data_pagamento_raw, -comprovante_id) |>
  
  # 5. Filtragem de alunos com notas altas e parcelas atrasadas
  filter(media_final > 7.0, status_pagamento == "Atrasado") |>
  
  # 6. Seleção de campos para exibição final
  select(nome, curso_id, media_final, codigo_transacao)
