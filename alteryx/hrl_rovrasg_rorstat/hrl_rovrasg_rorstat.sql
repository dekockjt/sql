with awards as (
    select 
		z.rprawrd_pidm as pidm,
		z.rprawrd_aidy_code as aidy,
		sum(z.rprawrd_offer_amt) as offer,
		sum(z.rprawrd_accept_amt) as accept
	from faismgr.rprawrd z
	inner join faismgr.rfrbase y
		on y.rfrbase_fund_code = z.rprawrd_fund_code
		and y.rfrbase_ftyp_code in ('RM-S', 'RM-G', 'RB-S', 'BD-G', 'BD-S')
	group by z.rprawrd_pidm, z.rprawrd_aidy_code
), reg as (
    select distinct sfrstcr_pidm as pidm
    from sfrstcr
    where sfrstcr_term_code = :term
    and sfrstcr_bill_hr > 0
)
select 
	b.spriden_id as "Banner ID", 
	b.spriden_last_name || ', ' || b.spriden_first_name as "Name",
	a.rorstat_pidm as "pidm",
	a.rorstat_aidy_code as "Aid Year",
	:term as "TERM",
	a.rorstat_tgrp_code as "TGRP",
	a.rorstat_bgrp_code as "BGRP",
	a.rorstat_pgrp_code as "PGRP",
	c.rovrasg_term_code as "Term - HRL",
	c.rovrasg_ascd_code as "Status - HRL",
	c.rovrasg_bldg_code as "Building Code",
	d.offer as "HRL Aid",
	d.accept as "ACCEPT",
	e.rcrapp1_inst_hous_cde as "Inst. Hous. Code",
    case 
        when a.rorstat_tgrp_code in ('MADRID', 'DECEAS', 'NOAPLY', 'LWNA', 'AC1818', 'REVIEW', 'MADRNU', 'CLSDST', 'VISIT', 'NODEGR', 'NOTADM', 'OLDADM')
        then 'Bad Track Group'
        else null
    end as "Review",
    case when g.pidm is not null then 'Y' else 'N' end as "Registered",
    to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as "Update Time"
from faismgr.rorstat a
inner join saturn.spriden b on b.spriden_pidm = a.rorstat_pidm
left join baninst1.rovrasg c 
	on c.rovrasg_pidm = a.rorstat_pidm
	and c.rovrasg_ascd_code = 'A'
	and c.rovrasg_term_code = :term
left join awards d on d.pidm = a.rorstat_pidm and d.aidy = a.rorstat_aidy_code
left join reg g on g.pidm = a.rorstat_pidm
left join faismgr.rcrapp1 e
	on e.rcrapp1_pidm = a.rorstat_pidm
	and e.rcrapp1_aidy_code = a.rorstat_aidy_code
	and e.rcrapp1_curr_rec_ind = 'Y'
	and e.rcrapp1_infc_code = 'EDE'
where b.spriden_change_ind is null
and a.rorstat_aidy_code = :aidy

;

desc sfrstcr;