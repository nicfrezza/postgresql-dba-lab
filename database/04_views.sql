-- atualizar as estatísticas da tabela 
ANALYZE patients;

-- remove tuplas mortas e atualiza estatística 
VACUUM ANALYZE appointments; 

-- verificar informações sobre a manutenção das tabelas
SELECT
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;