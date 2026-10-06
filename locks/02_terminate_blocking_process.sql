--  encerra uma transação que está bloqueando outra transação
SELECT pg_cancel_backend(12345);