-- BACKUP
pg_dump -U postgres -d hospital_dba -F c -f hospital_backup.dump

-- RESTORE
pg_restore -U postgres -d hospital_dba hospital_backup.dump