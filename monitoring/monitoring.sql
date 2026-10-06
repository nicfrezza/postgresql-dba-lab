-- consultar atividade do banco de dados
SELECT
    pid,
    usename,
    datname,
    client_addr,
    state,
    query_start,
    query
FROM pg_stat_activity
WHERE state <> 'idle';

-- consultar os processos que estão em estado de espera
SELECT
    pid,
    usename,
    state,
    wait_event_type,
    wait_event,
    query
FROM pg_stat_activity
WHERE wait_event IS NOT NULL;

--- consultar tamanho das tabelas 
SELECT
    schemaname,
    relname AS table_name,
    pg_size_pretty(
        pg_total_relation_size(relid)
    ) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;


-- consultar tamanho dos índices
SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;