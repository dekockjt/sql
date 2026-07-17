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
), ftht as (
    select pidm, term, tmst from (
        select 
            sfrthst_pidm as pidm,
            sfrthst_term_code as term,
            sfrthst_tmst_code as tmst,
            row_number() over (
                partition by sfrthst_pidm, sfrthst_term_code
                order by sfrthst_tmst_date desc
            ) as rn
        from sfrthst
        where sfrthst_term_code = (select t from term)
    )
), stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as levl,
        a.sgbstdn_program_1 as prog,
        a.sgbstdn_degc_code_1 as degc,
        a.sgbstdn_exp_grad_date as exp_grad
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
    ssn, 
    nvl(term, (select t from term)) as term,
    tmst,
    levl, 
    degc,
    prog,
    exp_grad
from ids a
join stu c on c.pidm = a.pidm
left join ftht d on d.pidm = a.pidm

;

select distinct stvterm_code as term
from stvterm
where substr(stvterm_code, 0, 4) 
    between to_char(extract(year from sysdate) - 2) 
    and to_char(extract(year from sysdate) + 1)
and substr(stvterm_code, 5, 2) in ('00', '10', '20')
order by stvterm_code desc;