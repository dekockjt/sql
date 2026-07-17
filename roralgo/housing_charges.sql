select tbraccd_pidm
from tbraccd
join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
    and tbbdetc_type_ind = 'C'
    and tbbdetc_dcat_code = 'HOU'
join rorprst on rorprst_pidm = tbraccd_pidm 
    and rorprst_period = tbraccd_term_code
    and rorprst_xhs <> '2'
where tbraccd_term_code = '202710'
and tbraccd_pidm = :pidm
group by tbraccd_pidm, tbraccd_term_code
having sum(tbraccd_amount) > 0
;
