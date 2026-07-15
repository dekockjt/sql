select spbpers_ssn
from spbpers;

select * from spbpers fetch first 100 rows only;
desc spbpers;


with term as (
    select '202710' as t from dual
), ids as (
    select pidm, spriden_id as bid, ssn 
    from (
        select 
            spbpers_pidm as pidm,
            spbpers_ssn as ssn,
            row_number() over(
                partition by spbpers_pidm, spbpers_ssn
                order by spbpers_version desc
            ) as rn
        from spbpers
    ) a
    join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
    where rn = 1
), enrl as (
    select pidm, term, rokmisc.F_CALC_STUD_BILL_HRS(term, pidm, 'N') as hrs
    from (
        select distinct sfrstcr_pidm as pidm, sfrstcr_term_code as term
        from sfrstcr 
        where sfrstcr_term_code = (select t from term)
        and sfrstcr_bill_hr > 0
    ) a
), stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as levl,
        a.sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= (select t from term)
    )
    and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
)
select 
    bid, 
    ssn, nvl(term, (select t from term)) as term, 
    hrs,
    levl, 
    prog
from ids a
left join enrl b on b.pidm = a.pidm
left join stu c on c.pidm = a.pidm
;