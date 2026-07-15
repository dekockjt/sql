select 
    spriden_id as bid,
    rpratrm_aidy_code as aidy,
    robnyud_value_194 as start_term,
    robnyud_value_195 as end_term,
    rpratrm_term_code as award_term,
    rpratrm_fund_code as fund,
    rpratrm_accept_amt as acpt,
    rpratrm_paid_amt as paid
from rpratrm
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
left join robnyud on robnyud_pidm = rpratrm_pidm
where rpratrm_fund_code in ('DLPL', 'DLGL') 
and rpratrm_aidy_code = '2627'
and rpratrm_awst_code = 'ACPT'
and rpratrm_term_code > robnyud_value_195
;
    