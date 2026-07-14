-- variance, EAS fund(s) paid in spring, not in fall
with awards as (
    select 
        rpratrm_pidm as pidm,
        rpratrm_term_code as term,
        rpratrm_fund_code as fund,
        rpratrm_awst_code as awst,
        rpratrm_accept_amt as acpt,
        rpratrm_paid_amt as paid
    from rpratrm
    join rfrbase on rfrbase_fund_code = rpratrm_fund_code
        and rfrbase_fsrc_code = 'EAS'
    where rpratrm_paid_amt > 0
)
select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    rorstat_pgrp_code as pgrp,
    rorstat_tgrp_code as tgrp,
    robnyud_value_38 as nyud_38,
    sp.fund as spr_award,
    fl.fund as fall_award
from rorstat a
join spriden on spriden_pidm = a.rorstat_pidm and spriden_change_ind is null
join robnyud on robnyud_pidm = a.rorstat_pidm
join robinst on robinst_aidy_code = a.rorstat_aidy_code and robinst_status_ind = 'A'
join awards sp on sp.pidm = a.rorstat_pidm and sp.term = robinst_aidy_end_year || '20'
left join awards fl on fl.pidm = a.rorstat_pidm and fl.term = robinst_aidy_end_year || '10'
where a.rorstat_aidy_code = '2526'
and regexp_like(rorstat_pgrp_code, '^UG-CON?$')
and fl.pidm is null

;

with awards as (
    select 
        rpratrm_pidm as pidm,
        rpratrm_term_code as term,
        rpratrm_fund_code as fund,
        rpratrm_awst_code as awst,
        rpratrm_accept_amt as acpt,
        rpratrm_paid_amt as paid
    from rpratrm
    join rfrbase on rfrbase_fund_code = rpratrm_fund_code
        and rfrbase_fsrc_code = 'EAS'
    where rpratrm_paid_amt > 0
)
select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    rorstat_pgrp_code as pgrp,
    rorstat_tgrp_code as tgrp,
    robnyud_value_38 as nyud_38,
    fl.fund as fall_award,
    sp.fund as spr_award
from rorstat a
join spriden on spriden_pidm = a.rorstat_pidm and spriden_change_ind is null
join robnyud on robnyud_pidm = a.rorstat_pidm
join robinst on robinst_aidy_code = a.rorstat_aidy_code and robinst_status_ind = 'A'
join awards fl on fl.pidm = a.rorstat_pidm and fl.term = robinst_aidy_end_year || '10'
left join awards sp on sp.pidm = a.rorstat_pidm and sp.term = robinst_aidy_end_year || '20'
where a.rorstat_aidy_code = '2526'
and regexp_like(rorstat_pgrp_code, '^UG-CON?$')
and sp.pidm is null
;
select * from rorstat where rorstat_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001176630');
