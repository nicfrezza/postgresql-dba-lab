# 🏥 PostgreSQL Hospital DBA Lab

Laboratório prático de **Database Administration (DBA)** utilizando PostgreSQL.
O projeto simula um ambiente hospitalar e aborda **administração, performance, segurança, manutenção, monitoramento e recuperação de bancos de dados**.

---

## 🛠️ Tecnologias

* **PostgreSQL 15+**
* **Python** — automação e população de dados
* **Faker** — geração de dados fictícios realistas
* **SQL** — DDL, DML e DCL
* **DBeaver** — administração e análise do banco de dados

---

## 🏥 Cenário

O projeto consiste em um banco de dados fictício para gerenciamento hospitalar, contendo informações sobre:

* Pacientes
* Médicos
* Consultas
* Exames
* Prontuários médicos
* Pagamentos

O banco foi populado com **mais de 150.000 registros** utilizando Python e a biblioteca Faker, simulando um ambiente de produção com volume de dados suficiente para realização de testes de **performance, manutenção e monitoramento**.

---

## 📚 DBA Topics

O projeto aborda diferentes áreas de responsabilidade de um DBA:

| Área                   | Conceitos praticados                                        |
| ---------------------- | ----------------------------------------------------------- |
| **Database Modeling**  | Modelagem e normalização das tabelas                        |
| **Constraints**        | Primary Keys, Foreign Keys, `CHECK`, `CASCADE` e `RESTRICT` |
| **Indexes**            | Índices B-Tree e otimização de consultas                    |
| **Query Optimization** | Análise e otimização de planos de execução                  |
| **EXPLAIN ANALYZE**    | Identificação de Sequential Scans e gargalos                |
| **Transactions**       | ACID, Savepoints e níveis de isolamento                     |
| **Locks**              | Identificação de bloqueios e simulação de Deadlocks         |
| **VACUUM / ANALYZE**   | Limpeza de dead tuples e atualização de estatísticas        |
| **Security**           | RBAC, Row-Level Security e Data Masking                     |
| **Backup & Restore**   | Backup lógico e estratégias de recuperação                  |
| **Monitoring**         | Sessões, armazenamento, tabelas e índices                   |

---

# 🚀 Performance Cases

## Case 01 — Slow Query

### 🔴 Problema

O sistema hospitalar apresentava lentidão ao gerar o relatório de consultas do dia.

A consulta levava aproximadamente **3 segundos** para retornar os resultados e realizava `JOIN` entre as tabelas `appointments`, `patients` e `doctors`.

### 🔎 Diagnóstico

Foi utilizado `EXPLAIN ANALYZE` para analisar o plano de execução:

```sql
EXPLAIN ANALYZE
SELECT
    p.first_name,
    d.first_name,
    a.appointment_date
FROM appointments a
JOIN patients p
    ON p.patient_id = a.patient_id
JOIN doctors d
    ON d.doctor_id = a.doctor_id
WHERE a.appointment_date >= CURRENT_DATE;
```

A análise revelou um **Sequential Scan** na tabela `appointments`, que possuía aproximadamente 60.000 registros.

Isso significava que o PostgreSQL estava percorrendo a tabela inteira para localizar os registros correspondentes ao filtro de data.

### 💡 Solução

Após verificar os índices existentes, foi identificado que não havia um índice para `appointment_date`.

Foi criado o seguinte índice:

```sql
CREATE INDEX idx_appointments_date
ON appointments(appointment_date);
```

### 📈 Resultado

| Métrica           |           Antes |     Depois |
| ----------------- | --------------: | ---------: |
| Tempo de execução |        ~3000 ms |     ~15 ms |
| Estratégia        | Sequential Scan | Index Scan |

A criação do índice reduziu significativamente o tempo de execução da consulta.

---

# Case 02 — Index Optimization & Maintenance

### 🔴 Problema

Após um grande volume de operações de `UPDATE` e `DELETE`, o banco começou a apresentar:

* Aumento do uso de disco
* Maior quantidade de dead tuples
* Degradação da performance de algumas consultas

### 🔎 Diagnóstico

Foram utilizadas estatísticas disponíveis em `pg_stat_user_tables` para identificar tabelas com grande quantidade de linhas mortas.

As tabelas `appointments` e `medical_records` apresentaram um número elevado de `n_dead_tup`.

Também foi analisada a necessidade de manutenção dos índices.

### 💡 Solução

Foi executado:

```sql
VACUUM ANALYZE appointments;
VACUUM ANALYZE medical_records;
```

O `VACUUM` permite recuperar espaço utilizado por tuplas que não estão mais visíveis, enquanto o `ANALYZE` atualiza as estatísticas utilizadas pelo query planner.

Quando necessário, índices também foram reconstruídos utilizando:

```sql
REINDEX INDEX idx_appointments_patient;
```

### 📈 Resultado

* Redução de dead tuples
* Atualização das estatísticas do planner
* Melhora na eficiência das consultas
* Recuperação de espaço reutilizável
* Manutenção dos índices

---

# 💾 Backup & Recovery

A pasta `backup/` contém scripts que simulam uma estratégia de **Disaster Recovery (DR)** utilizando `pg_dump` e `pg_restore`.

## 1. Full Backup

Backup contendo estrutura e dados:

```bash
pg_dump \
    -U postgres \
    -F c \
    -d hospital_db \
    -f backup/hospital_db_backup.dump
```

O formato **Custom (`-F c`)** permite recursos como restauração seletiva e paralela.

---

## 2. Restore

Em um cenário de disaster recovery:

```bash
pg_restore \
    -U postgres \
    -d hospital_db \
    -c \
    -j 4 \
    backup/hospital_db_backup.dump
```

### Principais parâmetros

| Parâmetro | Função                                         |
| --------- | ---------------------------------------------- |
| `-c`      | Remove objetos antes de recriá-los             |
| `-j 4`    | Utiliza 4 jobs paralelos durante a restauração |
| `-d`      | Define o banco de destino                      |
| `-F c`    | Utiliza o formato Custom                       |

---

# 📈 Monitoring

A pasta `monitoring/` contém scripts utilizados para acompanhar a saúde e utilização do banco.

## Active Connections

**Arquivo:** `01_active_connections.sql`

Monitora:

* Número de conexões
* Usuários conectados
* Estado das sessões
* Queries em execução
* Sessões `idle`
* Sessões `idle in transaction`
* Tempo de execução das queries

Sessões `idle in transaction` podem indicar transações abertas por períodos prolongados e potencialmente causar problemas de bloqueio e utilização de recursos.

---

## Table & Index Sizes

**Arquivo:** `02_table_and_index_sizes.sql`

Identifica:

* Tamanho das tabelas
* Tamanho dos índices
* Objetos que mais consomem armazenamento
* Crescimento do banco

Essas informações podem ser utilizadas para **Capacity Planning**, permitindo antecipar necessidades futuras de armazenamento.

---

# 🔐 Security

Devido à natureza sensível dos dados hospitalares, o projeto também aborda mecanismos de controle de acesso e proteção de dados.

## RBAC — Role-Based Access Control

Foram criadas roles específicas para diferentes funções:

* `doctor_role`
* `receptionist_role`
* `billing_role`

Cada role possui apenas as permissões necessárias para sua função.

Por exemplo, usuários da recepção não possuem acesso direto à tabela `medical_records`.

---

## Row-Level Security — RLS

Foi implementado **Row-Level Security** para restringir quais registros cada médico pode visualizar.

A política permite que médicos consultem apenas os registros relacionados aos pacientes sob sua responsabilidade.

Isso demonstra como o PostgreSQL pode aplicar controle de acesso em nível de **linha**, além do controle tradicional baseado em tabelas e schemas.

---

## Data Masking

Foram criadas views específicas para usuários que precisam consultar dados para análise sem acessar informações pessoais completas.

Exemplo de mascaramento de e-mail:

```text
j***@gmail.com
```

Também são mascarados dados como números de telefone.

Essa abordagem permite disponibilizar dados para Analytics reduzindo a exposição de informações sensíveis.

---

# 📁 Project Structure

```text
postgresql-hospital-dba-lab/
│
├── database/
│   ├── 01_create_tables.sql
│   ├── 02_constraints.sql
│   ├── 03_indexes.sql
│   └── 04_views.sql
│
├── data/
│   ├── generate_data.py
│   └── README.md
│
├── performance/
│   ├── 01_slow_queries.sql
│   ├── 02_explain_analyze.sql
│   └── 03_index_optimization.sql
│
├── transactions/
│   ├── 01_transactions.sql
│   ├── 02_isolation_levels.sql
│   └── 03_deadlocks.sql
│
├── maintenance/
│   ├── 01_vacuum_analyze.sql
│   └── 02_reindex.sql
│
├── backup/
│   ├── 01_backup.sh
│   └── 02_restore.sh
│
├── monitoring/
│   ├── 01_active_connections.sql
│   ├── 02_table_and_index_sizes.sql
│   └── 03_database_size.sql
│
├── security/
│   ├── 01_roles.sql
│   ├── 02_permissions.sql
│   ├── 03_row_level_security.sql
│   └── 04_data_masking.sql
│
└── README.md
```

---

# 🎯 Project Goals

Este laboratório foi desenvolvido para praticar conceitos fundamentais de **PostgreSQL Database Administration**, incluindo:

* Database Design
* Query Optimization
* Index Management
* Transaction Management
* Lock & Deadlock Analysis
* Database Maintenance
* Backup & Recovery
* Access Control
* Data Protection
* Database Monitoring

O objetivo é simular problemas encontrados em ambientes reais e documentar o processo de **diagnóstico → solução → validação**.

---

# 👩‍💻 Author

**Nicoli Thaís Frezza**

Database / DBA Projects
PostgreSQL • SQL • Python
