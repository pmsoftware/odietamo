--
-- Insert the list of object IDs and types for source object that are to be imported and
-- could have existing scenarios.
--
DELETE
  FROM odiscm_imports
/

<OdiScmInsertSrcObjIds>

COMMIT
/