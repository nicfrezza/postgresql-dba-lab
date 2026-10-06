-- Criar Roles
CREATE ROLE receptionist_role LOGIN PASSWORD 'secure_pass_123';
CREATE ROLE doctor_role LOGIN PASSWORD 'secure_pass_456';
CREATE ROLE billing_role LOGIN PASSWORD 'secure_pass_789';

-- Recepcionista provilegios (pode gerenciar agendamentos e informações básicas do paciente)
GRANT SELECT, INSERT, UPDATE ON patients, appointments TO receptionist_role;
GRANT USAGE, SELECT ON SEQUENCE patients_patient_id_seq, appointments_appointment_id_seq TO receptionist_role;

-- Doutor privilegios (pode ver pacientes e atualizar dados médicos, sem acesso a pagamentos)
GRANT SELECT, UPDATE ON patients TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON appointments, exams, medical_records, prescriptions TO doctor_role;

-- Financeiro privilegios (pode ver pagamentos e nomes de pacientes, sem dados médicos)
GRANT SELECT ON patients, payments TO billing_role;

-- apagar provilegios padrão 
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO receptionist_role, doctor_role, billing_role;