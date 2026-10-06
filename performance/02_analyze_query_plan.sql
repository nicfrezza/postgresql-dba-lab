-- Use this to test if an index is being used.
-- use esse teste para verificar se um índice está sendo usado.
-- antes de criar um índice, execute este teste. Se você vir "Seq Scan", é lento.
-- depois de criar um índice, execute novamente. Você deve ver "Index Scan".
EXPLAIN ANALYZE 
SELECT * FROM appointments 
WHERE patient_id = '';


--teste real 
explain analyze 
select * from appointments where doctor_id = '3dfcb7ee-7cb1-4b82-82ce-1129a50d61ab';

--antes
Planning Time: 0.216 ms
Execution Time: 0.088 ms


create index idx_appointments_doctor2
on appointments(doctor_id);

--depois
Planning Time: 0.157 ms
Execution Time: 0.078 ms 