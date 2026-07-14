select gcraact_gcvasts_id, count(*) from gcraact group by gcraact_gcvasts_id;
select * from gcraact;

select * from gcvasts;

SELECT *
FROM all_tab_comments
WHERE table_name LIKE 'GCR%'
-- WHERE table_name LIKE 'GCBA%'
-- WHERE table_name LIKE 'GCBC%'
ORDER BY table_name;
-- GCBCJOB
-- GCBCREC
-- GCBACTM
-- GCBAGRP
-- GCBAJOB
-- GCBAPST
-- GCRPOPV
-- GCRPQID
-- GCRABLK
-- GCRACNT
-- GCRAFCT
-- GCRAFLU
-- GCRAGRA
-- GCRAIIM
-- GCRAISR
-- GCRAPST
-- GCRCFLD
-- GCRCITM
-- GCREITM
-- GCRFLDR
-- GCRFLPM
-- GCRFPRM
-- GCRFVAL
-- GCRGSIM
-- GCRITPE
-- GCRLENT
-- GCRLETM
-- GCRLMAP
-- GCRMBAC
-- GCRMINT
-- GCRMITM
-- GCRORAN
-- GCRPARM
-- GCRPOPC
-- GCRAACT
-- GCRPOPV
-- GCRPQID
-- GCRPRCU
-- GCRPVID
-- GCRQRYV
-- GCRRVSD
-- GCRRVST
-- GCRSETM
-- GCRSITM
-- GCRSLIS
-- GCRSTTM
-- GCRTITM
-- GCRTPFL