-- •	How many students use the SLU Difference Award (Billiken Promise)?  How many students do not use it? 
-- •	Of all the tuition charged, how much is "paid" by SLU Difference Award (Billiken Promise)?
-- •	Are SLU Difference Award (Billiken Promise) funds applied to some courses more than others?
-- select * from (
with terms as (
    select '202600' as period, '202600' as sludif_term, '202600' as tui_term from dual
    union all
    select '202620' as period, '202620' as sludif_term, '202618' as tui_term from dual
), stus as (
    select 
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_term_code_eff,
        a.sgbstdn_levl_code as levl,
        stvcoll_desc as college,
        smrprle_program_desc as program,
        stvmajr_desc as major,
        t.period,
        t.sludif_term,
        t.tui_term
    from terms t
    join sgbstdn a
        on a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.sgbstdn_pidm
              and z.sgbstdn_term_code_eff <= t.period
        )
    join stvcoll on stvcoll_code = a.sgbstdn_coll_code_1
    join smrprle on smrprle_program = a.sgbstdn_program_1
    join stvmajr on stvmajr_code = a.sgbstdn_majr_code_1
    where nvl(rokmisc.F_CALC_STUD_BILL_HRS(t.period, a.sgbstdn_pidm, 'N'), 0) > 0
), sludif as (
    select 
        rpratrm_pidm as pidm,
        rpratrm_term_code as term,
        rpratrm_fund_code as fund,
        rpratrm_accept_amt as acpt,
        rpratrm_paid_amt as paid
    from rpratrm
    where rpratrm_fund_code = 'SLUDIF'
    and rpratrm_term_code in ('202600', '202620')
), tui as (
    select tbraccd_pidm as pidm, tbraccd_term_code as term, sum(tbraccd_amount) as tuition
    from tbraccd a
    join tbbdetc b on b.tbbdetc_detail_code = a.tbraccd_detail_code
    where tbbdetc_dcat_code = 'TUI'
    and tbraccd_term_code in ('202600', '202618')
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
select 
    spriden_id,
    a.levl,
    a.college,
    a.program,
    a.major,
    a.period,
    c.tuition,
    b.acpt,
    b.paid
from stus a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
join tui c on c.pidm = a.pidm and c.term = a.tui_term
left join sludif b on b.pidm = a.pidm and b.term = a.sludif_term
;
