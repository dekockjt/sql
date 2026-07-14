select case
    when a.sgbstdn_levl_code = 'UG' then '2.0'
    when a.sgbstdn_levl_code = 'GR' then '3.0'
    when a.sgbstdn_levl_code = 'PL' then '2.1'
end 
from sgbstdn a
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_stst_code in ('AS', 'IL')
)
and a.sgbstdn_levl_code in ('UG', 'GR', 'PL', 'PM')
and a.sgbstdn_stst_code in ('AS', 'IL')
and a.sgbstdn_pidm = :PIDM

;

select * 
from rovsapr
join spriden on spriden_pidm = rovsapr_pidm and spriden_change_ind is null
where spriden_id = '001077701';