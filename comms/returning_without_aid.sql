with emails as (
    select * from (
        select goremal_pidm as pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
        and goremal_emal_code in ('SLU', 'PERS')
    )
    pivot (min(goremal_email_address) for goremal_emal_code in ('SLU' as slu, 'PERS' as pers))
)
select 
    spriden_id,
    spriden_last_name || ', ' || spriden_first_name as name,
    slu,
    pers,
    s.program
from emails e
join spriden on spriden_pidm = e.pidm and spriden_change_ind is null
join (
    select a.sgbstdn_pidm as pidm, a.sgbstdn_program_1 as program
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_styp_code <> '4'
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202710'
    )
) s on s.pidm = e.pidm
where exists (
    select 1
    from sfrstcr
    where sfrstcr_pidm = e.pidm
    and sfrstcr_term_code = '202620'
    and sfrstcr_bill_hr > 0
)
and not exists (
    select 1
    from shrdgmr
    where shrdgmr_pidm = e.pidm
    and shrdgmr_degc_code = (
        select a.sgbstdn_degc_code_1
        from sgbstdn a
        where a.sgbstdn_pidm = shrdgmr_pidm
        and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
        and a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.sgbstdn_pidm
            and z.sgbstdn_term_code_eff <= '202710'
        )
    )
    and shrdgmr_grad_date <= to_date('08/01/2026', 'MM/DD/YYYY')
)
and not exists (
    select 1
    from sgrsatt s
    where s.sgrsatt_pidm = e.pidm
    and s.sgrsatt_term_code_eff <= '202620'
    and s.sgrsatt_atts_code in ('SGR', 'SPNT', 'SPNU', 'SPNS', 'SPSY')
)
;

select *
from sfrstcr
where sfrstcr_term_code = '202620';

select * from shrdgmr;

select sgbstdn_coll_code_1, count(*) from sgbstdn where sgbstdn_styp_code = '4' group by sgbstdn_coll_code_1 ;