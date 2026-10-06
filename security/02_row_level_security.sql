-- habilitar Row Level Security na tabela medical_records
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;

-- Criar uma política: Médicos só podem ver registros onde eles são o doctor_id responsável
CREATE POLICY doctor_isolation_policy ON medical_records
    FOR SELECT
    TO doctor_role
    USING (doctor_id::text = current_setting('app.current_doctor_id', true));

-- Como testar (Simulando um médico fazendo login):
-- SET ROLE doctor_role;
-- SET app.current_doctor_id = 'put-a-real-doctor-uuid-here';
-- SELECT * FROM medical_records; -- Eles só verão seus próprios registros!