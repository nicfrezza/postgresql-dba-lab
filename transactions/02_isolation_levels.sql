-- TESTE: Execute isso em duas sessões de banco de dados separadas (abas) simultaneamente.

-- SESSION 1 (Doutor lendo dados):
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT phone_number FROM patients WHERE patient_id = 'uuid';
-- Wait 5 seconds...
SELECT phone_number FROM patients WHERE patient_id = 'uuid';
COMMIT;
-- Resultado: Ambos os SELECTs retornam o MESMO número de telefone antigo, garantindo consistência.

-- SESSION 2 (Receptionista atualizando dados):
BEGIN;
UPDATE patients SET phone_number = '999-999-9999' WHERE patient_id = 'uuid';
COMMIT;