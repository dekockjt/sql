-- 05/04/2026
-- grad + law students with < 6 hrs, total awarded amount of unsub and grad plus

with student as (
    select
        a.sgbstdn_pidm as pidm, 
        a.sgbstdn_levl_code as levl,
        stvcoll_desc as college,
        smrprle_program_desc as program
    from sgbstdn a
    inner join stvcoll on stvcoll_code = a.sgbstdn_coll_code_1
    inner join smrprle on smrprle_program = a.sgbstdn_program_1
    where a.sgbstdn_stst_code in ('AS', 'IL')
    and a.sgbstdn_levl_code in ('GR', 'PL')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202620'
    )
), time_status as (
    select 
        sfrthst_pidm as pidm, 
        sfrthst_term_code as period, 
        sfrthst_tmst_code as tmst,
        rokmisc.F_CALC_STUD_BILL_HRS(sfrthst_term_code, sfrthst_pidm, 'N') as hrs_bill,
        rokmisc.F_CALC_STUD_CREDIT_HRS(sfrthst_term_code, sfrthst_pidm, 'N') as hrs_current,
        rokmisc.F_CALC_STUD_ADJ_HRS(sfrthst_term_code, sfrthst_pidm, 'N') as hrs_adj
    from (
        select 
            sfrthst_pidm, 
            sfrthst_term_code, 
            sfrthst_tmst_code,
            sfrthst_tmst_date,
            row_number() over (
                partition by sfrthst_pidm, sfrthst_term_code 
                order by sfrthst_tmst_date desc
            ) as rn
        from sfrthst 
    )
    where rn = 1
), awards as (
    select 
        rpratrm_pidm as pidm,
        rpratrm_term_code as period,
        rpratrm_fund_code as fund,
        rpratrm_accept_amt as amt
    from rpratrm
    where rpratrm_paid_amt > 0
    and rpratrm_fund_code in ('DLUL', 'DLGL')
    and rpratrm_aidy_code = '2526'
)
select 
    spriden_id as id,
    b.period,
    a.levl,
    c.hrs_bill,
    c.hrs_current,
    c.hrs_adj,
    c.tmst,
    a.college,
    a.program,
    max(case when b.fund = 'DLUL' then b.amt end) as dlul_amt,
    max(case when b.fund = 'DLGL' then b.amt end) as dlgl_amt
from student a
join awards b on b.pidm = a.pidm
join time_status c on c.pidm = a.pidm and c.period = b.period
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
group by 
    spriden_id,
    b.period,
    a.levl,
    c.hrs_bill,
    c.hrs_current,
    c.hrs_adj,
    c.tmst,
    a.college,
    a.program
order by spriden_id, b.period
;