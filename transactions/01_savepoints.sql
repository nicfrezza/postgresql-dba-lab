BEGIN;

-- Passo 1: Inserir Registro Médico (Sucesso)
INSERT INTO medical_records (patient_id, doctor_id, appointment_id, diagnosis, notes)
VALUES ('patient-uuid', 'doctor-uuid', 'appointment-uuid', 'Hypertension', 'Patient advised on diet.');

-- Criar um savepoint antes de tentar inserir a prescrição 
SAVEPOINT sp_prescription;

-- Passo 2: Inserir Prescrição (Falha intencionalmente devido a dados inválidos ou erro)
-- Imagine que essa linha lança um erro:
-- INSERT INTO prescriptions (medication_name, dosage) VALUES (NULL, NULL);

-- Rollback para o savepoint, descartando a prescrição falha, mas mantendo o registro médico
ROLLBACK TO SAVEPOINT sp_prescription;


-- Commit a transaction 
COMMIT;