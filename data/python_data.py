import psycopg
from faker import Faker
import random

fake = Faker()


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "hospital_dba",
    "user": "postgres",
    "password": "your_password_here"
}

def populate_database():
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            print("Clearing old data (if any)...")
            cur.execute("DELETE FROM prescriptions;")
            cur.execute("DELETE FROM medical_records;")
            cur.execute("DELETE FROM payments;")
            cur.execute("DELETE FROM exams;")
            cur.execute("DELETE FROM appointments;")
            cur.execute("DELETE FROM doctors;")
            cur.execute("DELETE FROM patients;")

            # ==========================================
            # MEDICAL DATA LISTS 
            # ==========================================
            reasons_for_visit = [
                "Severe headache and dizziness", "Routine annual physical checkup", 
                "Chest pain and shortness of breath", "Persistent cough for 2 weeks", 
                "High fever and body aches", "Lower back pain", "Allergic reaction", 
                "Fractured wrist", "Stomach ache and nausea", "Post-surgery follow-up"
            ]
            
            exam_types = ['Blood Test', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound', 'ECG']
            
            exam_results = [
                "No abnormalities detected. Patient is healthy.", 
                "Evidence of acute inflammation in the affected area.",
                "Mild chronic changes observed. Recommend follow-up in 6 months.",
                "Results within normal limits.",
                "Suspicious mass detected. Requires immediate MRI for further evaluation.",
                "Complete recovery noted. No further treatment required."
            ]
            
            diagnoses = [
                "Influenza (Flu)", "Migraine", "Hypertension", "Type 2 Diabetes", 
                "Acute Bronchitis", "Sprained Ankle", "Gastritis", "Asthma", 
                "Anxiety Disorder", "Common Cold"
            ]
            
            medications = [
                "Amoxicillin 500mg", "Ibuprofen 600mg", "Lisinopril 10mg", 
                "Metformin 850mg", "Atorvastatin 20mg", "Omeprazole 20mg", 
                "Salbutamol Inhaler", "Dipyrone 500mg", "Loratadine 10mg"
            ]
            
            dosages = ["1 tablet daily", "1 tablet every 8 hours", "2 tablets at bedtime", "1 tablet as needed", "10 drops every 6 hours"]

            # ==========================================
            # 1. INSERT PATIENTS
            # ==========================================
            print("Generating Patients...")
            patient_ids = []
            blood_types = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
            
            for _ in range(50): # Generate 50 patients
                cur.execute("""
                    INSERT INTO patients (
                        first_name, last_name, date_of_birth, gender, phone_number, 
                        email, address, city, state, zip_code, blood_type, 
                        emergency_contact_name, emergency_contact_phone
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING patient_id;
                """, (
                    fake.first_name(),
                    fake.last_name(),
                    fake.date_of_birth(minimum_age=0, maximum_age=90),
                    random.choice(['Male', 'Female', 'Other']),
                    fake.phone_number()[:20], 
                    fake.email(),
                    fake.address()[:255],
                    fake.city(),
                    fake.state_abbr(),
                    fake.zipcode(),
                    random.choice(blood_types),
                    fake.name(),
                    fake.phone_number()[:20]
                ))
                patient_ids.append(cur.fetchone()[0])

            # ==========================================
            # 2. INSERT DOCTORS
            # ==========================================
            print("Generating Doctors...")
            doctor_ids = []
            specialties = ['Cardiology', 'Neurology', 'Pediatrics', 'Orthopedics', 'General Surgery', 'Oncology', 'Dermatology']
            
            for _ in range(10): # Generate 10 doctors
                cur.execute("""
                    INSERT INTO doctors (
                        first_name, last_name, specialty, license_number, 
                        phone_number, email, hire_date
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    RETURNING doctor_id;
                """, (
                    fake.first_name(),
                    fake.last_name(),
                    random.choice(specialties),
                    fake.bothify(text='MD-#####-??'),
                    fake.phone_number()[:20],
                    fake.email(),
                    fake.date_between(start_date='-10y', end_date='today')
                ))
                doctor_ids.append(cur.fetchone()[0])

            # ==========================================
            # 3. INSERT APPOINTMENTS
            # ==========================================
            print("Generating Appointments...")
            appointment_data = [] # Will store tuples: (appointment_id, patient_id, doctor_id)
            statuses = ['Scheduled', 'Completed', 'Canceled', 'No-Show']
            
            for _ in range(150): # Generate 150 appointments
                p_id = random.choice(patient_ids)
                d_id = random.choice(doctor_ids)
                
                cur.execute("""
                    INSERT INTO appointments (
                        patient_id, doctor_id, appointment_date, status, reason_for_visit
                    ) 
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING appointment_id;
                """, (
                    p_id,
                    d_id,
                    fake.date_time_between(start_date='-1y', end_date='+1m'),
                    random.choice(statuses),
                    random.choice(reasons_for_visit) # Fixed: Medical reason
                ))
                a_id = cur.fetchone()[0]
                appointment_data.append((a_id, p_id, d_id))

            # ==========================================
            # 4. INSERT EXAMS
            # ==========================================
            print("Generating Exams...")
            exam_statuses = ['Pending', 'Completed', 'Canceled']
            
            for _ in range(80): # Generate 80 exams
                a_id, p_id, d_id = random.choice(appointment_data)
                exam_status = random.choice(exam_statuses)
                
                # Only add a result if the exam is completed
                result_text = random.choice(exam_results) if exam_status == 'Completed' else None
                
                cur.execute("""
                    INSERT INTO exams (
                        appointment_id, patient_id, doctor_id, exam_type, 
                        exam_date, result, status
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    a_id,
                    p_id,
                    d_id,
                    random.choice(exam_types),
                    fake.date_time_between(start_date='-30d', end_date='now'),
                    result_text, 
                    exam_status
                ))

            # ==========================================
            # 5. INSERT MEDICAL RECORDS (NEW)
            # ==========================================
            print("Generating Medical Records...")
            for _ in range(120): # Generate 120 medical records
                a_id, p_id, d_id = random.choice(appointment_data)
                
                cur.execute("""
                    INSERT INTO medical_records (
                        patient_id, doctor_id, appointment_id, diagnosis, notes, record_date
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s);
                """, (
                    p_id,
                    d_id,
                    a_id,
                    random.choice(diagnoses), 
                    fake.paragraph(nb_sentences=3), # General clinical notes
                    fake.date_time_between(start_date='-30d', end_date='now')
                ))

            # ==========================================
            # 6. INSERT PRESCRIPTIONS (NEW)
            # ==========================================
            print("Generating Prescriptions...")
            for _ in range(100): # Generate 100 prescriptions
                a_id, p_id, d_id = random.choice(appointment_data)
                
                cur.execute("""
                    INSERT INTO prescriptions (
                        patient_id, doctor_id, appointment_id, medication_name, 
                        dosage, frequency, prescribed_date
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    p_id,
                    d_id,
                    a_id,
                    random.choice(medications), 
                    random.choice(dosages),     
                    "for 7 days",               
                    fake.date_time_between(start_date='-30d', end_date='now')
                ))

            # ==========================================
            # 7. INSERT PAYMENTS
            # ==========================================
            print("Generating Payments...")
            payment_methods = ['Credit Card', 'Debit Card', 'Cash', 'Insurance', 'Pix']
            payment_statuses = ['Pending', 'Paid', 'Failed', 'Refunded']
            
            for _ in range(120): # Generate 120 payments
                a_id, p_id, _ = random.choice(appointment_data)
                
                cur.execute("""
                    INSERT INTO payments (
                        patient_id, appointment_id, amount, payment_date, 
                        payment_method, status
                    ) 
                    VALUES (%s, %s, %s, %s, %s, %s);
                """, (
                    p_id,
                    a_id,
                    round(random.uniform(50.00, 1500.00), 2),
                    fake.date_time_between(start_date='-30d', end_date='now'),
                    random.choice(payment_methods),
                    random.choice(payment_statuses)
                ))

        conn.commit()
        print("Database successfully populated with realistic medical data!")

if __name__ == "__main__":
    populate_database()