--
-- Make a brand new combined master+work repository from a clone (e.g. Oracle export)
-- of another repository.
-- Note this cannot, generally, be used to change the IDs to values that have previously
-- been used in another repository.
--

--
-- Clear out any tables that contain data that we don't need to update. 
--
DELETE
  FROM snp_host_mod
;

DELETE
  FROM snp_host
;

--
-- Update the Master Repository ID.
--
UPDATE snp_loc_rep
   SET rep_short_id = <new_master_rep_id>
;

--
-- Update the Work Repository ID.
--
UPDATE snp_loc_repw
   SET rep_short_id = <new_work_rep_id>
;

--
-- Update the Master repository record of the attached Work Repository.
-- We assume only one work repository per master repository.
--
UPDATE snp_rem_rep
   SET rep_id = <new_work_rep_id>
;

--
-- We assume we're creating a brand new master/work repository from a cloned
-- master/work repository NOT changing the ID of an existing master/work repository.
-- To do THAT we'd need to set the correct IDs in SNP_ID for every sequence/table.
--
DELETE
  FROM snp_id
;

COMMIT;