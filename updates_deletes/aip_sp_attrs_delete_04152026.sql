select *
--delete
from gcraact 
where exists (
    select 1
    from sgrsatt z
    where z.sgrsatt_term_code_eff = (
        select max(sgrsatt_term_code_eff)
        from sgrsatt 
        where sgrsatt_pidm = z.sgrsatt_pidm
    )
    and gcraact_pidm = z.sgrsatt_pidm
    and gcraact_gcbactm_id = 3
    and z.sgrsatt_atts_code in ('SGI','SPNT','SPNU','SPNS','SPSY')
);