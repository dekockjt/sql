select 
    a.sgbstdn_pidm, s.spriden_id, p.spbpers_ssn, a.sgbstdn_term_code_eff,
    a.sgbstdn_levl_code, a.sgbstdn_stst_code, t.stvstst_desc, a.sgbstdn_coll_code_1,
    c.stvcoll_desc, a.sgbstdn_program_1, r.smrprle_program_desc
from sgbstdn a
inner join spriden s on s.spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
inner join spbpers p on p.spbpers_pidm = a.sgbstdn_pidm
inner join stvstst t on t.stvstst_code = a.sgbstdn_stst_code
inner join stvcoll c on c.stvcoll_code = a.sgbstdn_coll_code_1
inner join smrprle r on r.smrprle_program = a.sgbstdn_program_1 and r.smrprle_curr_ind = 'Y'
where a.sgbstdn_term_code_eff = (
    select max(sgbstdn_term_code_eff)
    from sgbstdn
    where sgbstdn_pidm = a.sgbstdn_pidm
    and sgbstdn_term_code_eff between '202020' and '202520'
);

desc sgbstdn;
desc stvstst;
desc stvcoll;
desc stvprga;
desc stvprog;
desc stvptyp;
select * from smrprle;
