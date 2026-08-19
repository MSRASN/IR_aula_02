# ==============================================================================
# EXERCÍCIOS DE FIXAÇÃO
# CONTEXTO: BANCO DE DADOS DE ALUNOS
# ==============================================================================

# ------------------------------------------------------------------------------
# Exercício 1
# ------------------------------------------------------------------------------
# Filtre a base de alunos para obter apenas os estudantes que estão matriculados
# na modalidade "EAD" e residem nos estados de Pernambuco ("PE") ou Rio Grande
# do Norte ("RN"). Após a filtragem, exiba apenas as colunas: id_aluno, nome,
# email, estado e situacao.



# ------------------------------------------------------------------------------
# Exercício 2
# ------------------------------------------------------------------------------
# Utilizando a base de desempenho, crie uma coluna chamada nota_ponderada
# calculando: (prova_1 * 0.3) + (prova_2 * 0.3) + (trabalho * 0.2) + (projeto * 0.2).
#
# Em seguida, crie uma coluna chamada perfil_desempenho que classifique o aluno
# como "Alto Rendimento" caso sua nota_ponderada seja maior ou igual a 8.0, e
# como "Rendimento Regular" para valores abaixo de 8.0. Ao final, exiba apenas
# as colunas id_aluno, nota_ponderada e perfil_desempenho.



# ------------------------------------------------------------------------------
# Exercício 3
# ------------------------------------------------------------------------------
# Utilizando a base de desempenho, agrupe os dados por curso e calcule as
# seguintes métricas para cada um:
# 1. O total de alunos matriculados;
# 2. A média de horas de estudo semanal, tratando possíveis valores ausentes;
# 3. A nota máxima obtida no projeto.
#
# Ordene a tabela resultante de forma decrescente pela média de horas de estudo
# obtida.



# ------------------------------------------------------------------------------
# Exercício 4
# ------------------------------------------------------------------------------
# Realize a junção das informações da tabela de alunos com as informações da
# tabela de pagamentos. Com a base integrada, retorne apenas os registros de
# alunos que estão com o status de pagamento igual a "Pendente", exibindo na
# tabela final apenas o nome do aluno, o e-mail, o estado e o valor da mensalidade.



# ------------------------------------------------------------------------------
# Exercício 5
# ------------------------------------------------------------------------------
# Junte as três tabelas de dados (alunos, desempenho e pagamentos) em uma base
# unificada utilizando a chave identificadora do aluno.
#
# Filtre para manter apenas os alunos que estão com a situação "Ativo" na
# modalidade "Presencial". Crie uma nova coluna chamada soma_notas que
# represente a soma simples de todas as avaliações (prova_1, prova_2, trabalho
# e projeto), tratando eventuais valores ausentes como zero.
#
# Agrupe os dados por turno para calcular o total de alunos ativos e presenciais,
# além da média da soma de notas em cada turno. Ordene o relatório final de
# forma decrescente pela média obtida.

