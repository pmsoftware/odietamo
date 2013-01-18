TRUNCATE TABLE SNP_ENT_ID;

INSERT
  INTO snp_ent_id
       (
	   id_seq
	 , id_tbl
	 , id_next
	   )
SELECT id_seq
     , id_tbl
	 , id_next
  FROM odisvn_teardwn_bkup_snp_ent_id
/

COMMIT
/