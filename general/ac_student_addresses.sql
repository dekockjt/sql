with addr as (
    select 
        spraddr_pidm as pidm, 
        spraddr_atyp_code as atyp, 
        spraddr_street_line1 as street1,
        spraddr_street_line2 as street2,
        spraddr_city as city,
        spraddr_stat_code as state,
        nvl(spraddr_natn_code, 'US') as nation,
        spraddr_zip as zip,
        row_number() over (
            partition by spraddr_pidm
            order by
                case spraddr_atyp_code when 'BI' then 1 when 'MA' then 2 end,
                spraddr_seqno desc
        ) as rn
    from spraddr
    join sgbstdn a on a.sgbstdn_pidm = spraddr_pidm
        and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
        and a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.sgbstdn_pidm
        )
    where spraddr_atyp_code in ('BI', 'MA')
    and spraddr_status_ind is null
)
select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    atyp, street1, street2, city, state, zip, nation
from addr
join spriden on spriden_pidm = pidm and spriden_change_ind is null
where rn = 1
;

-- further qualifiers from haley
with addr as (
    select 
        spraddr_pidm as pidm, 
        spraddr_atyp_code as atyp, 
        spraddr_street_line1 as street1,
        spraddr_street_line2 as street2,
        spraddr_city as city,
        spraddr_stat_code as state,
        nvl(spraddr_natn_code, 'US') as nation,
        spraddr_zip as zip,
        row_number() over (
            partition by spraddr_pidm
            order by
                case spraddr_atyp_code when 'BI' then 1 when 'MA' then 2 end,
                spraddr_seqno desc
        ) as rn
    from spraddr
    join sgbstdn a on a.sgbstdn_pidm = spraddr_pidm
        and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
        and a.sgbstdn_coll_code_1 not in ('AI', 'AC')
        and a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.sgbstdn_pidm
        )
    where spraddr_atyp_code in ('BI', 'MA')
    and spraddr_status_ind is null
)
select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    atyp, street1, street2, city, state, zip, nation
from addr a
join spriden on spriden_pidm = pidm and spriden_change_ind is null
where rn = 1
and not exists (
    select 1
    from sgrsatt s
    where s.sgrsatt_pidm = a.pidm
    and s.sgrsatt_term_code_eff <= :term
    and s.sgrsatt_atts_code in ('SGR', 'SPNT', 'SPNU', 'SPNS', 'SPSY')
)
and not exists (
    select 1
    from tbbacct
    where tbbacct_pidm = a.pidm
    and (
        tbbacct_bill_code in ('CP', 'CA', 'EC', 'EN', 'EF', 'PF', 'RC', 'RF', 'RN')
        or tbbacct_deli_code in ('PP', 'PI')
    )
)
;
desc sgrsatt;
select * from stvdegc;

desc tbbacct;