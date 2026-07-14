select * from guaconf;
desc GCBGSND;
select * from GCBGSND;

select gcbcrec_current_state from gcbcrec where gcbcrec_job_name = 'fra_reminder_recurring';

SELECT table_name, comments
FROM all_tab_comments
WHERE table_name LIKE 'GCB%'
ORDER BY table_name;

select * from GCBEMTL;

select spriden_id
from goremal
join spriden on spriden_pidm = goremal_pidm and spriden_change_ind is null
where goremal_email_address = 'emily.offenbacker@slu.edu';

SELECT owner, table_name
FROM all_tables
WHERE table_name = 'SGBSTDN';

select gcbcrec_current_state from gcbcrec where gcbcrec_job_name = 'fra_reminder_recurring';

update gcbcrec set gcbcrec_current_state = 'Stopped' where gcbcrec_job_name = 'fra_reminder_recurring';