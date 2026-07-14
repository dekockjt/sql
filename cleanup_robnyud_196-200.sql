merge into robnyud r 
using (
    select robnyud_pidm as pidm from robnyud where robnyud_value_197 = 'Y'
) a on (a.pidm = r.robnyud_pidm)
when matched then 
update set
    r.robnyud_value_196 = null,
    r.robnyud_value_197 = null,
    r.robnyud_value_198 = null,
    r.robnyud_value_199 = null,
    r.robnyud_value_200 = null
;