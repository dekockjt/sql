with awards as (
    select
        a.rpratrm_pidm as pidm,
        b.sgbstdn_levl_code as levl,
        a.rpratrm_term_code as term,
        a.rpratrm_fund_code as fund,
        a.rpratrm_accept_amt as acpt,
        a.rpratrm_paid_amt as paid,
        a.rpratrm_accept_amt - a.rpratrm_paid_amt as fee
    from rpratrm a
    join sgbstdn b on b.sgbstdn_pidm = a.rpratrm_pidm
    where b.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and b.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.rpratrm_pidm
        and z.sgbstdn_term_code_eff <= '202620'
    )
    and a.rpratrm_term_code in ('202610', '202620')
    and a.rpratrm_fund_code like 'DL%L'
    and a.rpratrm_accept_amt > 0
    and a.rpratrm_paid_amt > 0
), grouped as (
    select
        pidm, levl, term, fund, acpt, paid, fee,
        case
            when fund in ('DLUL', 'DLAL') then 'DLUL/DLAL'
            else fund
        end as fund_grp
    from awards
)
select
    levl,
    term,
    fund_grp,
    round(avg(fee), 2) as avg_fee
from grouped
group by levl, term, fund_grp
order by levl, term, fund_grp

-- select (select spriden_id from spriden where spriden_pidm = pidm and spriden_change_ind is null) from awards where fund = 'DLGL' and levl = 'UG'
;