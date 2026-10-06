-- Cria uma view segura que oculta PII (Informações de Identificação Pessoal)
CREATE OR REPLACE VIEW v_patients_anonymized AS
SELECT 
    patient_id,
    first_name,
    last_name,
    date_of_birth,
    city,
    state,
    LEFT(email, 1) || '***@' || SPLIT_PART(email, '@', 2) AS masked_email,
    '***-***-' || RIGHT(phone_number, 4) AS masked_phone
FROM patients;

-- Conceder à equipe de análise acesso SOMENTE à view, não à tabela base
CREATE ROLE analytics_role LOGIN PASSWORD 'analytics_pass';
GRANT SELECT ON v_patients_anonymized TO analytics_role;