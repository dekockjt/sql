with enrl as (
    select sfrstcr_pidm from sfrstcr
    where sfrstcr_term_code = :term
    and sfrstcr_bill_hr > 0
), stu as (
    select a.sgbstdn_pidm as pidm, a.sgbstdn_program_1 as program
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL')
    and a.sgbstdn_styp_code <> '4' -- exclude 1818
    and a.sgbstdn_program_1 not in ('NODE04', 'NODE19', 'NODEAI')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_term_code_eff <= :term
        and z.sgbstdn_pidm = a.sgbstdn_pidm
    )
    and exists ( select 1 from enrl where sfrstcr_pidm = a.sgbstdn_pidm )
), awards as (
    select r.rpratrm_pidm
    from rpratrm r
    inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
    where r.rpratrm_term_code = :term
    and b.rfrbase_fsrc_code = 'FEDR'
    and b.rfrbase_ftyp_code = 'LOAN'
    and r.rpratrm_awst_code in ('OFRD', 'ACPT')
), reqs as (
    select rrrareq_pidm, rrrareq_aidy_code
    from rrrareq
    where rrrareq_treq_code in ('LENT', 'PENT', 'CLACTN')
    and rrrareq_trst_code = 'M'
), mpn_req as (
    select rlrdlor_pidm, rlrdlor_aidy_code 
    from rlrdlor
    where rlrdlor_mpn_linked_ind = 'N'
    and rlrdlor_lnst_code <> 'CANC'
    and rlrdlor_loan_amt > 0
), emails as (
    select 
        goremal_pidm, email_slu, email_pers 
    from (
        select goremal_pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
    ) 
    pivot (
        max(goremal_email_address)
        for goremal_emal_code in ('SLU' as email_slu, 'PERS' as email_pers)
    )
), dataset as (
    select 
        spriden_id as bid, 
        spriden_last_name || ', ' || spriden_first_name as name,
        a.*, b.email_slu, b.email_pers
    from stu a
    join emails b on b.goremal_pidm = a.pidm
    join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
)
select bid, name, program, email_slu, email_pers
from dataset a
where exists (
    select 1 from awards where rpratrm_pidm = a.pidm
)
and exists (
    select 1 from reqs where rrrareq_pidm = a.pidm and rrrareq_aidy_code = :aidy
    union all
    select 1 from mpn_req where rlrdlor_pidm = a.pidm and rlrdlor_aidy_code = :aidy
)
order by name
;


select rlrdlor_status, rlrdlor_lnst_code, rlrdlor_fund_code
from rlrdlor
where rlrdlor_aidy_code = '2526'
and rlrdlor_fund_code in ('DLGL', 'DLPL', 'DLUL')
group by rlrdlor_status, rlrdlor_lnst_code, rlrdlor_fund_code;

select * from rtvlnst;

-- Search all RTV tables for a known status code value (e.g. 'A')
SELECT table_name, column_name
FROM   all_tab_columns
WHERE  table_name LIKE 'RTV%'
AND    column_name LIKE '%CODE%'
AND    owner = 'FAISMGR'  -- adjust schema as needed
ORDER BY table_name;