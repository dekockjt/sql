-- med or 
SELECT 'MEDFS', RORSTAT_PIDM
  FROM RORSTAT
WHERE (EXISTS
(SELECT 'X'
  FROM SARAPPD A, STVAPDC
WHERE A.SARAPPD_PIDM = RORSTAT_PIDM
   AND A.SARAPPD_APDC_CODE = STVAPDC_CODE
   AND STVAPDC_INST_ACC_IND = 'Y'   
   AND STVAPDC_SIGNF_IND = 'Y'
   AND A.SARAPPD_TERM_CODE_ENTRY = 
    (SELECT MAX(B.SARAPPD_TERM_CODE_ENTRY) 
       FROM SARAPPD B
      WHERE B.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND SUBSTR(B.SARAPPD_TERM_CODE_ENTRY,0,4) <= '20' || SUBSTR(RORSTAT_AIDY_CODE,3,2))
   AND A.SARAPPD_APPL_NO = 
    (SELECT MAX(C.SARAPPD_APPL_NO) 
       FROM SARAPPD C
      WHERE C.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND C.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY)
   AND A.SARAPPD_SEQ_NO = 
    (SELECT MAX(D.SARAPPD_SEQ_NO) 
       FROM SARAPPD D
      WHERE D.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND D.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
	    AND D.SARAPPD_APPL_NO = A.SARAPPD_APPL_NO)
   AND EXISTS 
    (SELECT 'X'
	   FROM SARADAP
      WHERE SARADAP_LEVL_CODE = 'PM'
            AND SARADAP_MAJR_CODE_1 = 'MED21'
            AND SARADAP_DEGC_CODE_1 = 'MD'
	    AND SARADAP_PIDM = A.SARAPPD_PIDM
		AND SARADAP_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
		AND SARADAP_APPL_NO = A.SARAPPD_APPL_NO))
	OR (EXISTS
(SELECT 'X'
   FROM SATURN.SGBSTDN E
  WHERE E.SGBSTDN_PIDM = RORSTAT_PIDM
    AND E.SGBSTDN_LEVL_CODE = 'PM'
    AND E.SGBSTDN_MAJR_CODE_1 = 'MED21'
    AND E.SGBSTDN_DEGC_CODE_1 = 'MD'
    AND E.SGBSTDN_STST_CODE IN ('AS','PI')
    AND E.SGBSTDN_TERM_CODE_EFF =
     (SELECT MAX(F.SGBSTDN_TERM_CODE_EFF)
        FROM SGBSTDN F 
	WHERE SUBSTR(F.SGBSTDN_TERM_CODE_EFF,0,4) <= '20' || SUBSTR(RORSTAT_AIDY_CODE,3,2)
         AND F.SGBSTDN_PIDM = E.SGBSTDN_PIDM))
AND NOT EXISTS (SELECT 'X'
  FROM SARAPPD A, STVAPDC
WHERE A.SARAPPD_PIDM = RORSTAT_PIDM
   AND A.SARAPPD_APDC_CODE = STVAPDC_CODE
   AND STVAPDC_INST_ACC_IND = 'Y' 
   AND STVAPDC_SIGNF_IND = 'Y'
   AND A.SARAPPD_TERM_CODE_ENTRY = 
    (SELECT MAX(B.SARAPPD_TERM_CODE_ENTRY) 
       FROM SARAPPD B
      WHERE B.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND SUBSTR(B.SARAPPD_TERM_CODE_ENTRY,0,4) <= '20' || SUBSTR(RORSTAT_AIDY_CODE,3,2))
   AND A.SARAPPD_APPL_NO = 
    (SELECT MAX(C.SARAPPD_APPL_NO) 
       FROM SARAPPD C
      WHERE C.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND C.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY)
   AND A.SARAPPD_SEQ_NO = 
    (SELECT MAX(D.SARAPPD_SEQ_NO) 
       FROM SARAPPD D
      WHERE D.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND D.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
	    AND D.SARAPPD_APPL_NO = A.SARAPPD_APPL_NO))))
AND RORSTAT_APRD_CODE <> 'MEDFS'
AND RORSTAT_AIDY_CODE            = :AIDY                    
-- AND RORSTAT_PIDM    =:PIDM


;

select 'MEDFS', a.rorstat_pidm
from rorstat a
inner join robinst b on b.robinst_aidy_code = :aidy
where a.rorstat_aidy_code = :aidy
and (
    exists (
        select 1
        from sgbstdn z
        where z.sgbstdn_pidm = a.rorstat_pidm
        and z.sgbstdn_levl_code = 'PM'
        and z.sgbstdn_stst_code in ('AS', 'IL')
        and z.sgbstdn_term_code_eff <= b.robinst_aidy_end_year || '20'
    ) or exists ( 
        select 1
        from saradap z
        inner join sarappd y on y.sarappd_pidm = z.saradap_pidm
            and y.sarappd_term_code_entry = z.saradap_term_code_entry
            and y.sarappd_appl_no = z.saradap_appl_no
        inner join stvapdc x on x.stvapdc_code = y.sarappd_apdc_code
            and x.stvapdc_inst_acc_ind = 'Y'
            and x.stvapdc_signf_ind = 'Y'
        where z.saradap_pidm = a.rorstat_aidy_code
        and z.saradap_levl_code = 'PM'
        and z.saradap_term_code_entry = (
            select max(w.saradap_term_code_entry)
            from saradap w
            where w.saradap_pidm = z.saradap_pidm
            and w.saradap_term_code_entry <= b.robinst_aidy_end_year || '20'
        )
        and y.sarappd_seq_no = (
            select max(v.sarappd_seq_no)
            from sarappd v
            where v.sarappd_pidm = y.sarappd_pidm
            and v.sarappd_term_code_entry = y.sarappd_term_code_entry
            and v.sarappd_appl_no = y.sarappd_appl_no
        )
    )
);
-- anD a.RORSTAT_PIDM = :PIDM

-- RCRLBS4_LN_LIMIT_EXCEPT_FLAG
desc RCRLDS4;

select rcrlds4_ln_limit_except_flg, count(*)
from rcrlds4
where rcrlds4_curr_rec_ind = 'Y'
and rcrlds4_aidy_code = '2627'
and rcrlds4_infc_code = 'EDE'
group by rcrlds4_ln_limit_except_flg;


SELECT DISTINCT(RORSTAT_PIDM)
FROM RORSTAT,ROBINST
WHERE ROBINST_STATUS_IND = 'A'
AND ROBINST_AIDY_CODE = RORSTAT_AIDY_CODE
AND EXISTS (
    SELECT 'X' 
    FROM SGBSTDN C
    WHERE C.SGBSTDN_PIDM = RORSTAT_PIDM
    AND C.SGBSTDN_DEGC_CODE_1  = 'NO-DEG'
    AND C.SGBSTDN_TERM_CODE_EFF = (
        SELECT MAX(D.SGBSTDN_TERM_CODE_EFF)
        FROM SGBSTDN D 
        WHERE D.SGBSTDN_PIDM = C.SGBSTDN_PIDM
        AND SUBSTR(D.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
    )
) AND NOT EXISTS (
    SELECT 'X'
    FROM SARADAP C
    WHERE SARADAP_PIDM = RORSTAT_PIDM
    AND SARADAP_DEGC_CODE_1 <> 'NO-DEG'
    AND SUBSTR(C.SARADAP_TERM_CODE_ENTRY,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4))
AND RORSTAT_AIDY_CODE = :AIDY         
AND RORSTAT_PIDM = (select spriden_pidm from spriden where spriden_id = '001114627' and spriden_change_ind is null)

;