with term as (
    select :term as term from dual
), emails as (
    select * from (
        select goremal_pidm as pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
        and goremal_emal_code in ('SLU', 'PERS')
    )
    pivot (min(goremal_email_address) for goremal_emal_code in ('SLU' as slu, 'PERS' as pers))
), fafsa as (
    select rcrapp1_pidm as pidm, rcrapp1_aidy_code as aidy, rcrapp4_sar_efc as sai
    from rcrapp1
    join rcrapp4 on rcrapp4_pidm = rcrapp1_pidm
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_infc_code = rcrapp4_infc_code
        and rcrapp1_seq_no = rcrapp4_seq_no
    where rcrapp1_infc_code = 'EDE'
    and rcrapp1_curr_rec_ind = 'Y'
), awarded as (
    select
        rpratrm_pidm as pidm, rpratrm_term_code,
        sum(rpratrm_offer_amt) as ofrd,
        sum(rpratrm_accept_amt) as acpt,
        sum(rpratrm_paid_amt) as paid
    from rpratrm
    where rpratrm_offer_amt is not null
    and rpratrm_accept_amt is not null
    group by rpratrm_pidm, rpratrm_term_code
)
select 
    distinct spriden_id as id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    r.rorstat_aprd_code as aprd, 
    r.rorstat_tgrp_code as tgrp, 
    r.rorstat_bgrp_code as bgrp, 
    r.rorstat_pgrp_code as pgrp,
    r2.rorstat_pgrp_code as pgrp_nextyear,
    a.saradap_levl_code as levl, 
    a.saradap_coll_code_1 as college, 
    a.saradap_program_1 as program,
    e.slu, 
    e.pers, 
    f.sai, 
    nvl(rokmisc.f_calc_stud_bill_hrs(a.saradap_term_code_entry, a.saradap_pidm, 'N'), 0) as hrs,
    t.rrrareq_trst_code as sumapp_rrrareq, 
    s.ofrd as total_ofrd, 
    s.acpt as total_acpt,
    s.paid as total_paid,
    a.saradap_term_code_entry as period, 
    to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as last_update
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm 
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
join spriden on spriden_pidm = a.saradap_pidm and spriden_change_ind is null
join robinst on robinst_aidy_code = (
    select robinst_aidy_code - 101
    from robinst
    where robinst_aidy_end_year = substr(saradap_term_code_entry, 0, 4)
)
left join emails e on e.pidm = a.saradap_pidm
left join fafsa f on f.pidm = a.saradap_pidm and f.aidy = robinst_aidy_code
left join awarded s on s.pidm = a.saradap_pidm and s.rpratrm_term_code = a.saradap_term_code_entry
left join rorstat r on r.rorstat_pidm = a.saradap_pidm
    and r.rorstat_aidy_code = robinst_aidy_code
left join rorstat r2 on r2.rorstat_pidm = a.saradap_pidm
    and r2.rorstat_aidy_code = (robinst_aidy_code + 101)
left join rrrareq t on t.rrrareq_pidm = a.saradap_pidm
    and t.rrrareq_aidy_code = robinst_aidy_code
    and t.rrrareq_treq_code = 'SUMAPP'
where saradap_term_code_entry = (select term from term)
and stvapdc_signf_ind = 'Y'
and stvapdc_inst_acc_ind = 'Y'
and b.sarappd_seq_no = (
    select max(sarappd_seq_no)
    from sarappd 
    where sarappd_pidm = b.sarappd_pidm
    and sarappd_appl_no = b.sarappd_appl_no
    and sarappd_term_code_entry = b.sarappd_term_code_entry
);
