-- select pebempl_pidm, spriden_id, spriden_last_name, spriden_first_name, goremal_email_address
select goremal_email_address
from pebempl 
join spriden on spriden_pidm = pebempl_pidm and spriden_change_ind is null
join goremal on goremal_pidm = pebempl_pidm
where pebempl_orgn_code_home = 'D004'
and pebempl_empl_status = 'A' -- active employees 
and pebempl_term_date is null -- no termination date
and pebempl_ecls_code = 30 -- FT staff salaried (excludes student workers)
and goremal_emal_code = 'SLU'
and goremal_status_ind = 'A'
;

desc pebempl;

-- SELECT table_name, comments
select *
FROM all_tab_comments
WHERE table_name LIKE '%ECLS%'
ORDER BY table_name;

select * from ptrecls;

select * from goremal;