TRUNCATE TABLE SNP_ID;

INSERT
  INTO snp_id
       (
	   id_seq
	 , id_tbl
	 , id_next
	   )
SELECT id_seq
     , id_tbl
	 , id_next
  FROM odisvn_teardwn_bkup_snp_id
/

COMMIT
/