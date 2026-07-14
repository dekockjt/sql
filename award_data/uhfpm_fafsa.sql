--select A.SGBSTDN_PIDM 
select distinct a.sgbstdn_pidm
from saturn.sgbstdn A
where A.SGBSTDN_TERM_CODE_EFF = 
	(
	select Max(B.SGBSTDN_TERM_CODE_EFF) 
	from saturn.sgbstdn B 
	where B.SGBSTDN_PIDM = A.SGBSTDN_PIDM 
	)
and A.sgbstdn_stst_code in ('AS','IL')
and A.sgbstdn_levl_code not in ('AC')
;


--select *
select a.sgbstdn_pidm
from sgbstdn a
left join (
    select sgrsatt_pidm, sgrsatt_atts_code
    from (
        select z.*,
            row_number() over (
                partition by z.sgrsatt_pidm
                order by z.sgrsatt_term_code_eff desc
            ) rn
        from sgrsatt z
    )
    where rn = 1 
) b on b.sgrsatt_pidm = a.sgbstdn_pidm
where a.sgbstdn_term_code_eff = (
	select max(sgbstdn_term_code_eff) 
	from saturn.sgbstdn
	where sgbstdn_pidm = a.sgbstdn_pidm
)
and a.sgbstdn_stst_code in ('AS','IL')
and a.sgbstdn_levl_code not in ('AC')
and (
    b.sgrsatt_atts_code is null 
    or b.sgrsatt_atts_code not in ('SGI', 'SPNT', 'SPNU', 'SPNS', 'SPSY')
)
;
desc sgrsatt;


select distinct a.sgbstdn_pidm
from saturn.sgbstdn a
left join saturn.sgrsatt b
    on b.sgrsatt_pidm = a.sgbstdn_pidm
   and b.sgrsatt_term_code_eff = (
        select max(sgrsatt_term_code_eff)
        from saturn.sgrsatt 
        where sgrsatt_pidm = a.sgbstdn_pidm
   )
where a.sgbstdn_term_code_eff = (
    select max(sgbstdn_term_code_eff)
    from saturn.sgbstdn
    where sgbstdn_pidm = a.sgbstdn_pidm
)
and a.sgbstdn_stst_code in ('AS','IL')
and a.sgbstdn_levl_code not in ('AC')
and (
    b.sgrsatt_atts_code is null
    or b.sgrsatt_atts_code not in ('SGI','SPNT','SPNU','SPNS','SPSY')
);

select 
    a.rorstat_pidm,
    s.spriden_id,
    a.rorstat_pgrp_code,
    c.rcvedea_fti_par_agi,
    c.rcvedea_fti_psp_agi,
    c.rcvedea_psp_us_inc,
    b.rcrapp1_par_us_inc
from rorstat a
join rcrapp1 b on b.rcrapp1_pidm = a.rorstat_pidm
    and b.rcrapp1_aidy_code = a.rorstat_aidy_code
    and b.rcrapp1_curr_rec_ind = 'Y'
    and b.rcrapp1_infc_code = 'EDE'
join rcvedea c on c.rcvedea_pidm = a.rorstat_pidm
    and c.rcvedea_aidy_code = a.rorstat_aidy_code
    and c.rcvedea_curr_rec_ind = b.rcrapp1_curr_rec_ind
    and c.rcvedea_infc_code = b.rcrapp1_infc_code
join spriden s on s.spriden_pidm = a.rorstat_pidm and s.spriden_change_ind is null
where a.rorstat_aidy_code = '2627'
and a.rorstat_pgrp_code = 'UFHPM'

;

desc rcvedea;

select distinct robnyud_value_120, count(robnyud_pidm) from robnyud group by robnyud_value_120;
select distinct robnyud_value_120, count(robnyud_pidm) from robnyud 
where robnyud_value_27 = '202710' group by robnyud_value_120;

