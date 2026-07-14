with today as (
    select 
        to_number(to_char(sysdate, 'yy')) as yr, 
        to_number(to_char(sysdate, 'mm')) as mn
    from dual
), aidy as (
    select 
        (to_char(t.yr-1)) || (to_char(t.yr)) as pastyr,
        (to_char(t.yr)) || (to_char(t.yr+1)) as crntyr,
        (to_char(t.yr+1)) || (to_char(t.yr+2)) as futryr
    from today t
), in_yr as (
    select pastyr from aidy join today on mn < 8
    union all
    select crntyr from aidy
    union all
    select futryr from aidy join today on mn >= 12
), rstat as (
    select 
        a.rorstat_pidm as pidm,
        b.spriden_id as stu_id,
        b.spriden_last_name || ', ' || b.spriden_first_name as name,
        a.rorstat_aidy_code as aid_year,
        a.rorstat_aprd_code as aid_prd,
        a.rorstat_bgrp_code as budg_grp,
        a.rorstat_pgrp_code as pack_grp,
        a.rorstat_tgrp_code as trck_grp
    from faismgr.rorstat a
    inner join saturn.spriden b on b.spriden_pidm = a.rorstat_pidm
    where b.spriden_change_ind is null
    and a.rorstat_aidy_code in (select * from in_yr)
), awards as (
    select a.rpratrm_aidy_code as aid_year,
        a.rpratrm_fund_code as fund,
        a.rpratrm_period as period,
        a.rpratrm_awst_code as status,
        a.rpratrm_offer_amt as ofrd_amt_prd,
        b.rprawrd_offer_amt as ofrd_amt_yr,
        a.rpratrm_pidm as pidm,
        a.rpratrm_accept_amt as acpt_amt_prd,
        b.rprawrd_accept_amt as acpt_amt_yr,
        a.rpratrm_orig_offer_amt as orig_ofrd_amt_prd,
        a.rpratrm_decline_amt as decl_amt_prd,
        b.rprawrd_decline_amt as decl_amt_yr,
        a.rpratrm_cancel_amt as cncl_amt_prd,
        b.rprawrd_cancel_amt as cncl_amt_yr,
        a.rpratrm_authorize_amt as auth_amt_prd,
        b.rprawrd_authorize_amt as auth_amt_yr,
        a.rpratrm_memo_amt as memo_amt_prd,
        b.rprawrd_memo_amt as memo_amt_yr,
        a.rpratrm_paid_amt as paid_amt_prd,
        b.rprawrd_paid_amt as paid_amt_yr,
        a.rpratrm_paid_date as paid_date_prd,
        a.rpratrm_orig_offer_date as orig_ofrd_date_prd,
        a.rpratrm_term_code as term_code,
        a.rpratrm_awst_date as status_date 
    from faismgr.rpratrm a
    inner join faismgr.rprawrd b
        on b.rprawrd_aidy_code = a.rpratrm_aidy_code
        and b.rprawrd_pidm = a.rpratrm_pidm
        and b.rprawrd_fund_code = a.rpratrm_fund_code
), acstudy as (
    select
        a.sgbstdn_pidm as pidm,
        robinst_aidy_code as aid_year,
        a.sgbstdn_degc_code_1 as degree,
        d.stvdegc_desc as degree_desc,
        a.sgbstdn_majr_code_1 as major,
        m.stvmajr_desc as major_desc,
        m.stvmajr_cipc_code as program_classification,
        i.stvcipc_desc as program_classification_desc,
        a.sgbstdn_coll_code_1 as college,
        c.stvcoll_code as college_desc,
        a.sgbstdn_levl_code as student_level
    from sgbstdn a
    join robinst on robinst_status_ind = 'A'
    join stvcoll c on c.stvcoll_code = a.sgbstdn_coll_code_1
    join stvdegc d on d.stvdegc_code = a.sgbstdn_degc_code_1
    join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
    join stvcipc i on i.stvcipc_code = m.stvmajr_cipc_code
    join smrprle p on p.smrprle_program = a.sgbstdn_program_1
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= robinst_aidy_end_year + 1 || '00'
    )
), efc as (
    select rcrapp1_pidm as pidm, rcrapp1_aidy_code as aidy, rcrapp4_sar_efc as efc
    from rcrapp1
    join rcrapp4 
        on rcrapp1_pidm = rcrapp4_pidm 
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_seq_no = rcrapp4_seq_no
        and rcrapp1_infc_code = rcrapp4_infc_code
    where rcrapp1_curr_rec_ind = 'Y'
    and rcrapp1_infc_code = 'EDE'
), admapp as (
    select
        a.saradap_pidm as pidm,
        robinst_aidy_code as aid_year,
        a.saradap_degc_code_1 as degree,
        d.stvdegc_desc as degree_desc,
        a.saradap_majr_code_1 as major,
        m.stvmajr_desc as major_desc,
        m.stvmajr_cipc_code as program_classification,
        i.stvcipc_desc as program_classification_desc,
        a.saradap_coll_code_1 as college,
        c.stvcoll_code as college_desc,
        a.saradap_levl_code as student_level
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm 
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc v on v.stvapdc_code = b.sarappd_apdc_code
        and v.stvapdc_signf_ind = 'Y'
        and v.stvapdc_inst_acc_ind = 'Y'
    join robinst on robinst_status_ind = 'A'
    join stvcoll c on c.stvcoll_code = a.saradap_coll_code_1
    join stvdegc d on d.stvdegc_code = a.saradap_degc_code_1
    join stvmajr m on m.stvmajr_code = a.saradap_majr_code_1
    join stvcipc i on i.stvcipc_code = m.stvmajr_cipc_code
    join smrprle p on p.smrprle_program = a.saradap_program_1
    where a.saradap_styp_code in ('F', '1', 'T')
    and a.saradap_term_code_entry = (
        select max(z.saradap_term_code_entry)
        from saradap z
        where z.saradap_pidm = a.saradap_pidm
        and z.saradap_term_code_entry <= robinst_aidy_end_year + 1 || '00'
    )
    and a.saradap_appl_no = (
        select max(z.saradap_appl_no)
        from saradap z
        where z.saradap_pidm = a.saradap_pidm
        and z.saradap_term_code_entry = a.saradap_term_code_entry
    )
    and b.sarappd_seq_no = (
        select max(z.sarappd_seq_no)
        from sarappd z
        where z.sarappd_pidm = b.sarappd_pidm
        and z.sarappd_appl_no = b.sarappd_appl_no
        and z.sarappd_term_code_entry = b.sarappd_term_code_entry
    )
), stu as (
    select * from acstudy
    union all
    select * from admapp
)
select a.*, sg.*, e.efc, r.*, 
    to_char(sysdate, 'MM/DD/YYYY HH12:MI:SS AM') as "LastUpdate"
from rstat a
join stu sg on sg.pidm = a.pidm and sg.aid_year = a.aid_year
-- join acstudy sg on sg.pidm = a.pidm and sg.aid_year = a.aid_year
left join efc e on e.pidm = a.pidm and e.aidy = a.aid_year
left join awards r on r.pidm = a.pidm and r.aid_year = a.aid_year
where a.aid_year in (select * from in_yr)
order by a.pidm
;

desc stvcipc;

desc rcrapp4;
-- select rcrapp4_sar_efc from rcrapp4;

