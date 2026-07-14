-- SGBSTDN_ANTICIPATED_GRAD_DATE
-- RCVEDEA_PARENT_ATTEND_COLLEGE (1 or 2)
-- CLASSIFICATION - BASED ON HOURS IN SHRLGPA

-- student class level
select 
    shrlgpa_pidm, shrlgpa_levl_code, shrlgpa_hours_earned,
    case
        when shrlgpa_levl_code = 'UG' then case 
            when shrlgpa_hours_earned <= 29 then 'FR'
            when shrlgpa_hours_earned between 30 and 59 then 'SO'
            when shrlgpa_hours_earned between 60 and 89 then 'JR'
            when shrlgpa_hours_earned >= 90 then 'SR'
        end
        else shrlgpa_levl_code
    end as classif
from shrlgpa
where shrlgpa_gpa_type_ind = 'O';

-- self reported first gen
select rcvedea_pidm
from rcvedea
where rcvedea_curr_rec_ind = 'Y'
and rcvedea_infc_code = 'EDE'
and rcvedsea_aidy_code = '2627'
and rcvedea_parent_attend_college in (1, 2);

-- anticipated grad dates
select a.sgbstdn_pidm, a.sgbstdn_levl_code, a.sgbstdn_exp_grad_date
from sgbstdn a
where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_stst_code in ('AS', 'IL', 'P1')
)
;

with aidy as (
    select '2627' as aidy from dual
), stu as (
    select a.sgbstdn_pidm as pidm, a.sgbstdn_levl_code as levl, a.sgbstdn_exp_grad_date as grad_date
    from sgbstdn a
    join robinst on robinst_aidy_code = (select aidy from aidy) and robinst_status_ind = 'A'
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_stst_code in ('AS', 'IL', 'P1')
        and z.sgbstdn_term_code_eff < robinst_aidy_end_year || '00'
    )
), firstgen as (
    select rcvedea_pidm as pidm
    from rcvedea
    where rcvedea_curr_rec_ind = 'Y'
    and rcvedea_infc_code = 'EDE'
    and rcvedea_aidy_code = (select aidy from aidy)
    and rcvedea_parent_attend_college in (1, 2)
), class as (
    select 
        shrlgpa_pidm as pidm, shrlgpa_levl_code as levl, shrlgpa_hours_earned as hrs,
        case
            when shrlgpa_levl_code = 'UG' then case 
                when shrlgpa_hours_earned <= 29 then 'FR'
                when shrlgpa_hours_earned between 30 and 59 then 'SO'
                when shrlgpa_hours_earned between 60 and 89 then 'JR'
                when shrlgpa_hours_earned >= 90 then 'SR'
            end
            else shrlgpa_levl_code
        end as classif
    from shrlgpa
    where shrlgpa_gpa_type_ind = 'O'
)
select spriden_id as bid, a.grad_date, b.hrs, b.classif, case when c.pidm is not null then 'Y' else 'N' end as firstgen
from stu a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
join class b on b.pidm = a.pidm and b.levl = a.levl
left join firstgen c on c.pidm = a.pidm
;

SELECT lpad(column_value, 9, '0') AS bid
    FROM TABLE(sys.odcivarchar2list(
    '1365254','1097395','1228114','1440598','1272892','1145383','1280972','1371023',
    '1343080','1264535','1201637','1332654','1155702','1431640','1224034','1362598',
    '1269750','1271066','1380278','1444628','1401729','1362108','1248340','1215628',
    '1426946','1416075','1457647','1367057','1440612','1162424','1362992','1156947',
    '1342257','1364234'
));

SELECT lpad(column_value, 9, '0') AS bid
    FROM TABLE(sys.odcivarchar2list(
    '1365254','1097395','1228114','1440598','1272892','1145383','1280972','1371023',
    '1343080','1264535','1201637','1332654','1155702','1431640','1224034','1362598',
    '1269750','1271066','1380278','1444628','1401729','1362108','1248340','1215628',
    '1426946','1416075','1457647','1367057','1440612','1162424','1362992','1156947',
    '1342257','1364234'
));

desc robinst;