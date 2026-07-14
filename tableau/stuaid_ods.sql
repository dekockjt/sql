with today as (
    select 
        to_number(to_char(sysdate, 'YY')) as yr, 
        to_number(to_char(sysdate, 'MM')) as mn
    from dual
), aidy as (
    select 
        (to_char(t.yr-1)) || (to_char(t.yr)) as pastyr,
        (to_char(t.yr)) || (to_char(t.yr+1)) as crntyr,
        (to_char(t.yr+1)) || (to_char(t.yr+2)) as futryr
    from today t
), in_yr as (
    select pastyr from aidy join today on mn < 8
    union all
    select crntyr from aidy
    union all
    select futryr from aidy join today on mn >= 12
), acstudy as (
    select
        cast(person_uid as int) as person_uid,
        id,
        name,
        aid_year,
        primary_program_ind,
        degree,
        degree_desc,
        major,
        major_desc,
        program_classification,
        program_classification_desc,
        program_number,
        current_time_status,
        current_time_status_desc,
        college,
        college_desc,
        student_level,
        registered_ind,
        academic_period
    from odsmgr.academic_study
    where aid_year in (select * from in_yr)
), admapp as (
    select
        cast(person_uid as int) as person_uid,
        id,
        name,
        aid_year,
        primary_program_ind,
        degree,
        degree_desc,
        major,
        major_desc,
        program_classification,
        program_classification_desc,
        NULL as program_number,
        NULL as current_time_status,
        NULL as current_time_status_desc,
        college,
        college_desc,
        student_level,
        NULL as registered_ind,
        academic_period
    from odsmgr.admissions_application
    where aid_year in (select * from in_yr)
    and appl_accept_current_ind = 'Y'
)
select
	a.*,
    b.sar_efc
from acstudy a
left join odsmgr.need_analysis b 
    on b.person_uid = a.person_uid
    and b.aid_year = a.aid_year
		and b.current_record_ind = 'Y'
where a.primary_program_ind = 'Y'

union all

select
	a.*,
    b.sar_efc
from admapp a
left join odsmgr.need_analysis b 
    on b.person_uid = a.person_uid
    and b.aid_year = a.aid_year
		and b.current_record_ind = 'Y'
where a.primary_program_ind = 'Y'
and not exists (
    select 1 from acstudy s
    where s.person_uid = a.person_uid
    and s.aid_year = a.aid_year
)

;

desc admissions_application;