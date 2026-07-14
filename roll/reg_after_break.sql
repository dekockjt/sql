-- ug students who were paid at some point, took one or more term off, then registered again

with awards as (
    select a.*
    from rpratrm a
    join rfrbase b on b.rfrbase_fund_code = a.rpratrm_fund_code
    where b.rfrbase_fsrc_code = 'EAS'
    and a.rpratrm_paid_amt > 0
), max_term as (
    select case 
        when substr(a.term_code, 5, 2) = '00' then substr(a.term_code, 0, 4) || '10' 
        when substr(a.term_code, 5, 2) = '18' then substr(a.term_code, 0, 4) || '20' 
        else a.term_code
    end as term_code
    from (
        select max(t.stvterm_code) as term_code
        from stvterm t
        where t.stvterm_start_date <= sysdate
        and to_number(substr(t.stvterm_code, 1, 1) default null on conversion error) is not null
    ) a
)
select spriden_id, a.*
from sgbstdn a
join awards b on b.rpratrm_pidm = a.sgbstdn_pidm
    and b.rpratrm_term_code between a.sgbstdn_term_code_eff and (select term_code from max_term)
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_levl_code = 'UG'
and a.sgbstdn_term_code_eff = (
    select min(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_levl_code = a.sgbstdn_levl_code
    and z.sgbstdn_stst_code in ('AS', 'IL', 'P1')
)
and rokmisc.f_calc_stud_bill_hrs((select term_code from max_term), a.sgbstdn_pidm) > 0
;
desc rokmisc;

select * from rfrbase where rfrbase_fsrc_code = 'EAS';

select case 
    when substr(max(t.stvterm_code), 5, 2) = '00' then substr(max(t.stvterm_code), 0, 4) || '10' 
    when substr(max(t.stvterm_code), 5, 2) = '18' then substr(max(t.stvterm_code), 0, 4) || '20' 
    else max(t.stvterm_code) end as term_code
from stvterm t
where t.stvterm_start_date <= sysdate
and to_number(substr(t.stvterm_code, 1, 1) default null on conversion error) is not null
;

select * from stvterm where stvterm_code = 'ZPRK99';