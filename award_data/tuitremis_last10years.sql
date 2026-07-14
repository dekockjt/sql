--explain plan for 
with award_data as (
    select 
        a.rprawrd_pidm,
        a.rprawrd_aidy_code,
        a.rprawrd_fund_code,
        a.rprawrd_awst_code,
        a.rprawrd_paid_amt
    from rprawrd a
    where a.rprawrd_fund_code in (
        'SSMFAC', 'SSMFCS', 'SSMSGR', 'TEN-CS', 'TEN-FS', 
        'FACHEX', 'EXCHNG', 'REM-ST', 'REM-VS'
    )
    and a.rprawrd_aidy_code between '1617' and '2526'
    and a.rprawrd_paid_amt is not null
), pivoted as (
    select * from award_data
    pivot (
        sum(rprawrd_paid_amt)
        for rprawrd_fund_code in (
            'SSMFAC', 'SSMFCS', 'SSMSGR', 'TEN-CS', 'TEN-FS', 
            'FACHEX', 'EXCHNG', 'REM-ST', 'REM-VS'
        )
    )
    order by rprawrd_aidy_code desc
)
select * from pivoted;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

with award_data as (
    select 
        a.rprawrd_pidm,
        a.rprawrd_aidy_code,
        a.rprawrd_fund_code,
        a.rprawrd_paid_amt
    from rprawrd a
    inner join spriden c on c.spriden_pidm = a.rprawrd_pidm
        and c.spriden_change_ind is null
    where a.rprawrd_fund_code in (
        'SSMFAC', 'SSMFCS', 'SSMSGR', 'TEN-CS', 'TEN-ST', 
        'FACHEX', 'EXCHNG', 'REM-ST', 'REM-VS', 'REM-CS'
    )
    and a.rprawrd_aidy_code between '1617' and '2526'
    and a.rprawrd_paid_amt is not null
)
select
    rprawrd_aidy_code                                                                   as aid_year,

    count(distinct case when rprawrd_fund_code = 'SSMFAC' then rprawrd_pidm end)       as ssmfac_cnt,
    sum(case when rprawrd_fund_code = 'SSMFAC' then rprawrd_paid_amt else 0 end)       as ssmfac_amt,

    count(distinct case when rprawrd_fund_code = 'SSMFCS' then rprawrd_pidm end)       as ssmfcs_cnt,
    sum(case when rprawrd_fund_code = 'SSMFCS' then rprawrd_paid_amt else 0 end)       as ssmfcs_amt,

    count(distinct case when rprawrd_fund_code = 'SSMSGR' then rprawrd_pidm end)       as ssmsgr_cnt,
    sum(case when rprawrd_fund_code = 'SSMSGR' then rprawrd_paid_amt else 0 end)       as ssmsgr_amt,

    count(distinct case when rprawrd_fund_code = 'TEN-CS' then rprawrd_pidm end)       as ten_cs_cnt,
    sum(case when rprawrd_fund_code = 'TEN-CS' then rprawrd_paid_amt else 0 end)       as ten_cs_amt,

    count(distinct case when rprawrd_fund_code = 'TEN-ST' then rprawrd_pidm end)       as ten_st_cnt,
    sum(case when rprawrd_fund_code = 'TEN-ST' then rprawrd_paid_amt else 0 end)       as ten_st_amt,

    count(distinct case when rprawrd_fund_code = 'FACHEX' then rprawrd_pidm end)       as fachex_cnt,
    sum(case when rprawrd_fund_code = 'FACHEX' then rprawrd_paid_amt else 0 end)       as fachex_amt,

    count(distinct case when rprawrd_fund_code = 'EXCHNG' then rprawrd_pidm end)       as exchng_cnt,
    sum(case when rprawrd_fund_code = 'EXCHNG' then rprawrd_paid_amt else 0 end)       as exchng_amt,

    count(distinct case when rprawrd_fund_code = 'REM-ST' then rprawrd_pidm end)       as rem_st_cnt,
    sum(case when rprawrd_fund_code = 'REM-ST' then rprawrd_paid_amt else 0 end)       as rem_st_amt,

    count(distinct case when rprawrd_fund_code = 'REM-VS' then rprawrd_pidm end)       as rem_vs_cnt,
    sum(case when rprawrd_fund_code = 'REM-VS' then rprawrd_paid_amt else 0 end)       as rem_vs_amt,
    
        count(distinct case when rprawrd_fund_code = 'REM-CS' then rprawrd_pidm end)       as rem_cs_cnt,
    sum(case when rprawrd_fund_code = 'REM-CS' then rprawrd_paid_amt else 0 end)       as rem_cs_amt

from award_data
group by rprawrd_aidy_code
order by rprawrd_aidy_code desc;