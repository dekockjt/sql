select 
    a.gcraact_gcbactm_id as "aip_id",
    d.gcbactm_name as "aip",
    a.gcraact_pidm as "pidm",
    b.spriden_id as "banner_id",
    b.spriden_last_name || ', ' || b.spriden_first_name as "name",
    a.gcraact_gcvasts_id as "status_id",
    c.gcvasts_status_rule_name as "status",
    e.sgbstdn_levl_code as "level",
    e.sgbstdn_coll_code_1 as "college_code",
    f.stvcoll_desc as "college",
    e.sgbstdn_program_1 as "program",
    g.smrprle_program_desc as "program_desc",
    a.gcraact_display_start_date as "date_assigned",
    a.gcraact_user_response_date as "date_completed",
    to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as "lastrun"
from general.gcraact a
inner join saturn.spriden b on b.spriden_pidm = a.gcraact_pidm
inner join general.gcvasts c on c.gcvasts_surrogate_id = a.gcraact_gcvasts_id 
inner join general.gcbactm d on d.gcbactm_surrogate_id = a.gcraact_gcbactm_id
inner join saturn.sgbstdn e on e.sgbstdn_pidm = a.gcraact_pidm
inner join saturn.stvcoll f on f.stvcoll_code = e.sgbstdn_coll_code_1
inner join saturn.smrprle g on g.smrprle_program = e.sgbstdn_program_1
where b.spriden_change_ind is null
and e.sgbstdn_term_code_eff = (
    select max(sgbstdn_term_code_eff)
    from saturn.sgbstdn
    where sgbstdn_pidm = a.gcraact_pidm
);

select * from gcraact;