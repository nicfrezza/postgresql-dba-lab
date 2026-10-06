CREATE INDEX idx_patients_name ON patients (last_name, first_name);
CREATE INDEX idx_doctors_specialty ON doctors (specialty);
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_exams_patient ON exams(patient_id);
CREATE INDEX idx_exams_appointment ON exams(appointment_id);
CREATE INDEX idx_payments_patient ON payments(patient_id);
CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);


