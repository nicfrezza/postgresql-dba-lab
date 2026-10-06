-- Rodar isso na Sessão 1:
BEGIN;
UPDATE patients SET city = 'Session 1' WHERE patient_id = 'uuid-1';
-- Esperar um momento, depois execute a primeira linha da Sessão 2

-- Agora execute a segunda linha da Sessão 1:
UPDATE patients SET city = 'Session 1' WHERE patient_id = 'uuid-2';
COMMIT;

-- Rodar isso na Sessão 2:
BEGIN;
UPDATE patients SET city = 'Session 2' WHERE patient_id = 'uuid-2';
-- Esperar um momento, depois execute a segunda linha da Sessão 1

-- Agora execute a segunda linha da Sessão 2:
UPDATE patients SET city = 'Session 2' WHERE patient_id = 'uuid-1';
COMMIT;


-- Uma dessas sessões falhará com:
-- ERRO: deadlock detected  
