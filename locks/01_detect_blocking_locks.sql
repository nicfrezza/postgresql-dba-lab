-- encontrar bloqueios de transações no banco de dados
SELECT 
    blocked.pid              AS blocked_pid,
    blocked.usename          AS blocked_user,
    blocked.query            AS blocked_query,
    blocking.pid             AS blocking_pid,
    blocking.usename         AS blocking_user,
    blocking.query           AS blocking_query,
    blocked_locks.mode       AS blocked_mode,
    blocking_locks.mode      AS blocking_mode,
    NOW() - blocked.query_start AS blocked_duration
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking 
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
LEFT JOIN pg_locks blocked_locks 
    ON blocked_locks.pid = blocked.pid 
   AND NOT blocked_locks.granted
LEFT JOIN pg_locks blocking_locks 
    ON blocking_locks.pid = blocking.pid 
   AND blocking_locks.granted 
   AND blocked_locks.relation IS NOT DISTINCT FROM blocking_locks.relation;