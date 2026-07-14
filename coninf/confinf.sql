with dt as (
    select to_char(sysdate, 'MM/DD/YYYY HH:MI:SSAM') as t from dual
), aidy as (
    select to_char(sysdate - 365, 'YY') || to_char(sysdate, 'YY') as aidy
    from dual
    where to_char(sysdate, 'MM') <= '08'
    union all
    select to_char(sysdate, 'YY') || to_char(sysdate + 365, 'YY')
    from dual
    where to_char(sysdate, 'MM') >= '07'
), need_based as (
    select rprawrd_pidm as pidm, rprawrd_aidy_code as aidy
    from rprawrd
    where rprawrd_fund_code in ('PELL', 'DLSL', 'SEOG', 'FWS')
    and rprawrd_aidy_code in (select aidy from aidy)
    group by rprawrd_pidm, rprawrd_aidy_code
), grant_scholarships as (
    select 
        rprawrd_pidm as pidm,
        rprawrd_aidy_code as aidy,
        sum(rprawrd_accept_amt) as acpt,
        sum(rprawrd_paid_amt) as paid
    from rprawrd
    join rfrbase on rfrbase_fund_code = rprawrd_fund_code
    where rfrbase_ftyp_code in ('TU-G', 'TU-S')
    and rprawrd_aidy_code in (select aidy from aidy)
    group by rprawrd_pidm, rprawrd_aidy_code
), fti as (
    select 
        rcvedea_pidm,
        rcvedea_aidy_code as aidy,
        rcvedea_psp_us_inc,
        rcvedea_fti_par_agi,
        rcvedea_fti_psp_agi,
        rcvedea_sps_us_inc,
        rcvedea_fti_agi,
        rcvedea_fti_sps_agi,
        rcvedea_filed_fed_tax_rtn,
        rcvedea_fti_irs_response_code,
        rcvedea_par_filed_fed_tax_rtn,
        rcvedea_fti_par_irs_resp_code,
        rcvedea_psp_filed_fed_tax_rtn,
        rcvedea_fti_psp_irs_resp_code,
        rcvedea_sps_filed_fed_tax_rtn,
        rcvedea_fti_sps_irs_resp_code
    from rcvedea
    where rcvedea_curr_rec_ind = 'Y'
    and rcvedea_infc_code = 'EDE'
    and rcvedea_aidy_code in (select aidy from aidy)
), fafsa as (
    select 
        a.rcrapp1_pidm as pidm,
        a.rcrapp1_aidy_code as aidy,
        rorstat_aprd_code as aprd,
        rorstat_tgrp_code as tgrp,
        nvl(rorstat_bgrp_code, pbgp) as bgrp,
        rorstat_pgrp_code as pgrp,
        b.rcrapp3_par_grant_scholar_aid,
        a.rcrapp1_par_us_inc,
        b.rcrapp3_grant_scholar_aid,
        a.rcrapp1_us_inc,
        rcresar_comm_code_01,
        rcresar_comm_code_02,
        rcresar_comm_code_03,
        rcresar_comm_code_04,
        rcresar_comm_code_05,
        rcresar_comm_code_06,
        rcresar_comm_code_07,
        rcresar_comm_code_08,
        rcresar_comm_code_09,
        rcresar_comm_code_10,
        rcresar_comm_code_11,
        rcresar_comm_code_12,
        rcresar_comm_code_13,
        rcresar_comm_code_14,
        rcresar_comm_code_15,
        rcresar_comm_code_16,
        rcresar_comm_code_17,
        rcresar_comm_code_18,
        rcresar_comm_code_19,
        rcresar_comm_code_20
    from rcrapp1 a
    join rcrapp3 b on b.rcrapp3_pidm = a.rcrapp1_pidm 
        and b.rcrapp3_aidy_code = a.rcrapp1_aidy_code
        and b.rcrapp3_infc_code = a.rcrapp1_infc_code
        and b.rcrapp3_seq_no = a.rcrapp1_seq_no
    join rcresar on rcresar_pidm = a.rcrapp1_pidm 
        and rcresar_aidy_code = a.rcrapp1_aidy_code 
        and rcresar_infc_code = a.rcrapp1_infc_code 
        and rcresar_seq_no = a.rcrapp1_seq_no 
    left join rorstat on rorstat_pidm = a.rcrapp1_pidm 
        and rorstat_aidy_code = a.rcrapp1_aidy_code
    left join ( -- period budget group
        select * from (
            select
                rbrapbg_pidm as pidm,
                rbrapbg_aidy_code as aidy,
                rbrapbg_pbgp_code as pbgp,
                row_number() over (
                    partition by rbrapbg_pidm, rbrapbg_aidy_code
                    order by rbrapbg_activity_date desc
                ) as rn
            from rbrapbg
            where rbrapbg_run_name = 'ACTUAL'
        ) where rn = 1
    ) p on p.pidm = a.rcrapp1_pidm and p.aidy = a.rcrapp1_aidy_code
    where a.rcrapp1_curr_rec_ind = 'Y'
    and a.rcrapp1_infc_code = 'EDE'
    and a.rcrapp1_aidy_code in (select aidy from aidy)
), comm_flags as (
    select 
        pidm, aidy,
        max(case when comm_code = '40' then 1 else 0 end) as c40,
        max(case when comm_code = '76' then 1 else 0 end) as c76,
        max(case when comm_code = '96' then 1 else 0 end) as c96,
        max(case when comm_code = '127' then 1 else 0 end) as c127
    from fafsa
    unpivot (
        comm_code for col_num in (
            rcresar_comm_code_01, rcresar_comm_code_02, rcresar_comm_code_03, rcresar_comm_code_04,
            rcresar_comm_code_05, rcresar_comm_code_06, rcresar_comm_code_07, rcresar_comm_code_08,
            rcresar_comm_code_09, rcresar_comm_code_10, rcresar_comm_code_11, rcresar_comm_code_12,
            rcresar_comm_code_13, rcresar_comm_code_14, rcresar_comm_code_15, rcresar_comm_code_16,
            rcresar_comm_code_17, rcresar_comm_code_18, rcresar_comm_code_19, rcresar_comm_code_20
        )
    )
    group by pidm, aidy
), base_data as (
    select 
        a.aidy,
        spriden_id as id, 
        d.c40, 
        d.c76, 
        d.c96, 
        d.c127,
        a.aprd,
        a.tgrp,
        a.bgrp,
        a.pgrp,
        a.rcrapp3_par_grant_scholar_aid,
        a.rcrapp1_par_us_inc,
        a.rcrapp3_grant_scholar_aid,
        a.rcrapp1_us_inc,
        fti.rcvedea_psp_us_inc,
        fti.rcvedea_fti_par_agi,
        fti.rcvedea_fti_psp_agi,
        fti.rcvedea_sps_us_inc,
        fti.rcvedea_fti_agi,
        fti.rcvedea_fti_sps_agi,
        fti.rcvedea_filed_fed_tax_rtn,
        fti.rcvedea_fti_irs_response_code,
        fti.rcvedea_par_filed_fed_tax_rtn,
        fti.rcvedea_fti_par_irs_resp_code,
        fti.rcvedea_psp_filed_fed_tax_rtn,
        fti.rcvedea_fti_psp_irs_resp_code,
        fti.rcvedea_sps_filed_fed_tax_rtn,
        fti.rcvedea_fti_sps_irs_resp_code
    from fafsa a
    join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
    join fti on fti.rcvedea_pidm = a.pidm and fti.aidy = a.aidy
    left join grant_scholarships b on b.pidm = a.pidm and b.aidy = a.aidy
    left join need_based c on c.pidm = a.pidm and c.aidy = a.aidy
    left join comm_flags d on d.pidm = a.pidm and d.aidy = a.aidy
), dataset as (
    select
        (select t from dt) as last_update,
        a.aidy,
        id,
        aprd,
        tgrp,
        bgrp,
        pgrp,
        case 
            when (c40 > 0 or c76 > 0 or c96 > 0 or c127 > 0) then 68
            when (
                (rcvedea_sps_filed_fed_tax_rtn = 2 and rcvedea_fti_sps_irs_resp_code in ('200', '206'))
                or (rcvedea_sps_filed_fed_tax_rtn = 1 and rcvedea_fti_sps_irs_resp_code in ('200', '214'))
            ) then 66
            when (
                (rcvedea_psp_filed_fed_tax_rtn = 2 and rcvedea_fti_psp_irs_resp_code in ('200', '206'))
                or (rcvedea_psp_filed_fed_tax_rtn = 1 and rcvedea_fti_psp_irs_resp_code in ('200', '214'))
            ) then 65
            when (
                (rcvedea_filed_fed_tax_rtn = 2 and rcvedea_fti_irs_response_code in ('200', '206'))
                or (rcvedea_filed_fed_tax_rtn = 1 and rcvedea_fti_irs_response_code in ('200', '214'))
            ) then 64
            when (
                (rcvedea_par_filed_fed_tax_rtn = 2 and rcvedea_fti_par_irs_resp_code in ('200', '206'))
                or (rcvedea_par_filed_fed_tax_rtn = 1 and rcvedea_fti_par_irs_resp_code in ('200', '214'))
            ) then 63
            when (
                (rcrapp3_grant_scholar_aid >= (rcrapp1_us_inc + rcvedea_sps_us_inc))
                or (rcrapp3_grant_scholar_aid >= (rcvedea_fti_agi + rcvedea_fti_sps_agi))
            ) then 62
            when (
                (rcrapp3_par_grant_scholar_aid >= (rcrapp1_par_us_inc + rcvedea_psp_us_inc))
                or (rcrapp3_par_grant_scholar_aid >= (rcvedea_fti_par_agi + rcvedea_fti_psp_agi))
            ) then 61
        end as roausdf_field,
        rcvedea_fti_agi as agi_stu_fti,
        rcvedea_fti_sps_agi as agi_stu_sps_fti,
        case 
            when (rcvedea_fti_agi is not null or rcvedea_fti_sps_agi is not null)
            then (nvl(rcvedea_fti_agi, 0) + nvl(rcvedea_fti_sps_agi, 0))
        end as agi_sum_fti,
        rcrapp1_us_inc as agi_stu_manual,
        rcvedea_sps_us_inc as agi_stu_sps_manual,
        case 
            when (rcrapp1_us_inc is not null or rcvedea_sps_us_inc is not null)
            then (nvl(rcrapp1_us_inc, 0) + nvl(rcvedea_sps_us_inc, 0))
        end as agi_sum_manual,
        rcrapp3_grant_scholar_aid as gs_manual,
        rcvedea_fti_par_agi as agi_par_fti,
        rcvedea_fti_psp_agi as agi_par_sps_fti,
        case 
            when (rcvedea_fti_par_agi is not null or rcvedea_fti_psp_agi is not null)
            then (nvl(rcvedea_fti_par_agi, 0) + nvl(rcvedea_fti_psp_agi, 0))
        end as agi_par_sum_fti,
        rcrapp1_par_us_inc as agi_par_manual,
        rcvedea_psp_us_inc as agi_par_sps_manual,
        case 
            when (rcrapp1_par_us_inc is not null or rcvedea_psp_us_inc is not null)
            then (nvl(rcrapp1_par_us_inc, 0) + nvl(rcvedea_psp_us_inc, 0))
        end as agi_par_sum_manual,
        rcrapp3_par_grant_scholar_aid as gs_par_manual,
        rcvedea_par_filed_fed_tax_rtn,
        rcvedea_fti_par_irs_resp_code,
        rcvedea_filed_fed_tax_rtn,
        rcvedea_fti_irs_response_code,
        rcvedea_psp_filed_fed_tax_rtn,
        rcvedea_fti_psp_irs_resp_code,
        rcvedea_sps_filed_fed_tax_rtn,
        rcvedea_fti_sps_irs_resp_code,
        c40,
        c76,
        c96,
        c127
    from base_data a
)
select *
from dataset
;
