/*
CREATE
 TABLE odisvn_dbgit_generator_outputs
(
  session_id        INTEGER
, part_number       INTEGER
, part_text         VARCHAR2(4000)
, PRIMARY
      KEY (
          session_id
        , part_number
          )
)
;
*/
   CREATE
       OR
  REPLACE
PROCEDURE generate_tests
    (
      ip_interface_id       snp_table.i_table%TYPE
    )
IS
    l_session_id            PLS_INTEGER;                                -- The session ID to use for this session.
    l_part_number           PLS_INTEGER := 0;                           -- The next part number to use.
    l_output_buffer         VARCHAR(4000);                              -- Used to construct a block of output.
    lc_new_line             CHAR(2) := CHR(13) || CHR(10);              -- New line string
    
    lc_im                   VARCHAR2(6) := 'INFO: ';
    lc_em                   VARCHAR2(7) := 'ERROR: ';    
    l_count                 PLS_INTEGER := 0;
    l_src_set_idx           PLS_INTEGER := 0;
    l_tab_idx               PLS_INTEGER := 0; 
    l_tgt_tab_col_idx       PLS_INTEGER := 0; 
    l_col_idx               PLS_INTEGER := 0;    
    l_key_idx               PLS_INTEGER := 0;
    l_key_col_idx           PLS_INTEGER := 0;
    l_col_idx2              PLS_INTEGER := 0;
    l_ind                   BOOLEAN :=FALSE;
    l_nullable_col_ind      CHAR(1);
    l_written_null_ind      CHAR(1);    
    l_col_cnt               PLS_INTEGER :=0;
    l_key_col_cnt           PLS_INTEGER :=0;
    
    l_chr_key_val           VARCHAR2(3);                                    -- Use to hold the next generated value for a key column with char data type.

    -- Constant base value for generated values for date/time type key colums.
    lc_datetime_key_baseval CONSTANT DATE := TO_DATE('2012-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
    lc_num_col_val          CONSTANT PLS_INTEGER := 1;                      -- Constant for non key number columns.
    lc_str_col_val          CONSTANT VARCHAR2(3) := 'A';                    -- constant for non key char columns.
    lc_datetime_col_val     CONSTANT VARCHAR(19) := '2012-01-01 00:00:00';  -- constant for non key date/time columns.
    
    l_key_count             PLS_INTEGER := 0;
    lc_max_num_str          CONSTANT VARCHAR2(50) := '99999999999999999999999999999999999999999999999999';
    lc_min_num_str          CONSTANT VARCHAR2(50) := '-9999999999999999999999999999999999999999999999999';
    
    TYPE col_rec_type IS RECORD
    (
        id                  snp_col.i_col%TYPE
      , name                snp_col.col_name%TYPE
      , type_name           snp_col.source_dt%TYPE
      , not_null_ind        snp_col.col_mandatory%TYPE
      , length              snp_col.longc%TYPE
      , precision           snp_col.scalec%TYPE
      , last_val            PLS_INTEGER                                     -- Sequence used to track the last test value written to the output.
    );
    
    TYPE col_rec_tab_type IS TABLE OF col_rec_type
        INDEX BY BINARY_INTEGER; 
    
    TYPE key_col_rec_type IS RECORD
    (
        idx                  PLS_INTEGER
    --, lastval              VARCHAR(1000)
    )
    ;
    
    TYPE key_col_rec_tab_type IS TABLE OF key_col_rec_type
        INDEX BY BINARY_INTEGER;
    
    TYPE key_rec_type IS RECORD
    (
        id                  snp_key.i_key%TYPE
      , name                snp_key.key_name%TYPE
      , type_name           snp_key.cons_type%TYPE
      , col_idx             key_col_rec_tab_type
      , pos                 snp_key_col.pos%TYPE
    )
    ;
    
    TYPE key_rec_tab_type IS TABLE OF key_rec_type
        INDEX BY BINARY_INTEGER;
           
    TYPE tab_rec_type IS RECORD
    (
        id                  snp_table.i_table%TYPE
      , name                snp_table.res_name%TYPE
      , model_id            snp_table.i_mod%TYPE
      , mod_name            snp_model.mod_name%TYPE
      , lschema_name        snp_model.lschema_name%TYPE
      , tech_name           snp_model.tech_int_name%TYPE
      , cols                col_rec_tab_type
      , keys                key_rec_tab_type
    )
    ;
    
    TYPE tab_rec_tab_type IS TABLE OF tab_rec_type
            INDEX BY BINARY_INTEGER; 
            
    TYPE source_set_rec_type IS RECORD
    (
        id                  snp_src_set.i_src_set%TYPE
      , tabs                tab_rec_tab_type
    )
    ;
    
    TYPE source_set_tab_type IS TABLE OF source_set_rec_type
        INDEX BY BINARY_INTEGER; 
    
    --
    -- Source and target tables.
    --
    l_src_set               source_set_tab_type;
    l_tgt_tab               tab_rec_type;
    
    ------------------------------------------------------------------------------------------------
    -- Internal procedures.
    ------------------------------------------------------------------------------------------------
    --
    -- Load the specified table into iop_tab.
    --
    PROCEDURE load_tab
        (
          iop_tab             IN OUT tab_rec_type
        )
    IS
    BEGIN
        dbms_output.put_line(lc_im || 'Entering procedure load_tab with input id <' || iop_tab.id || '>');
        SELECT t.i_table
             , t.res_name
             , t.i_mod
             , m.mod_name
             , m.tech_int_name
             , m.lschema_name
          INTO iop_tab.id
             , iop_tab.name
             , iop_tab.model_id
             , iop_tab.mod_name
             , iop_tab.tech_name             
             , iop_tab.lschema_name
          FROM snp_table t
         INNER
          JOIN snp_model m
            ON t.i_mod = m.i_mod
         WHERE t.i_table = iop_tab.id
        ;
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure load_tab with input id <' || iop_tab.id || '> with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END load_tab;
    
    --
    -- Load the columns of the specified table into iop_tab_cols.
    --
    PROCEDURE load_tab_cols
        (
          iop_tab               IN OUT tab_rec_type
        )
    IS
        l_col_idx               PLS_INTEGER := 1;    
    BEGIN
        dbms_output.put_line(lc_im || 'Entering procedure load_tab_cols with input id <' || iop_tab.id || '>');
        
        FOR r_tab_col 
         IN (
            SELECT i_col
                 , col_name
                 , source_dt
                 , col_mandatory
                 , longc
                 , scalec
              FROM snp_col
             WHERE i_table = iop_tab.id
            )
        LOOP
            --dbms_output.put_line(l_col_idx);
            iop_tab.cols(l_col_idx).id := r_tab_col.i_col;
            iop_tab.cols(l_col_idx).name := r_tab_col.col_name;
            iop_tab.cols(l_col_idx).type_name := r_tab_col.source_dt;
            iop_tab.cols(l_col_idx).not_null_ind := r_tab_col.col_mandatory;
            iop_tab.cols(l_col_idx).length := r_tab_col.longc;
            iop_tab.cols(l_col_idx).precision := r_tab_col.scalec;
            l_col_idx := l_col_idx + 1;   -- For the next column.
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure load_tab_cols with input id <' || iop_tab.id || '> with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END load_tab_cols;
    
    --
    -- Load the keys of the specified table into iop_tab_cols.
    --    
    PROCEDURE load_tab_keys
        (
          iop_tab               IN OUT tab_rec_type
        ) 
    IS
        l_key_idx               PLS_INTEGER := 1;
        l_key_col_idx           PLS_INTEGER;
    BEGIN
        dbms_output.put_line(lc_im || 'Entering procedure load_tab_keys with input id <' || iop_tab.id || '>');
        
        FOR r_key
         IN (
            SELECT i_key
                 , key_name
                 , cons_type
              FROM snp_key 
             WHERE i_table = iop_tab.id
               AND cons_type IN ('PK','AK')
            )
        LOOP
            iop_tab.keys(l_key_idx).id := r_key.i_key;
            iop_tab.keys(l_key_idx).name := r_key.key_name;
            iop_tab.keys(l_key_idx).type_name := r_key.cons_type;
            
            l_key_col_idx := 1;

            FOR r_key_col
             IN (
                SELECT i_col
                     , pos
                  FROM snp_key_col
                 WHERE snp_key_col.i_key = r_key.i_key
                 ORDER
                    BY pos
                )
            LOOP
                FOR l_col_idx in 1..iop_tab.cols.LAST
                LOOP
                    IF iop_tab.cols(l_col_idx).id = r_key_col.i_col
                    THEN 
                        iop_tab.keys(l_key_idx).col_idx(l_key_col_idx).idx := l_col_idx;
                        iop_tab.cols(l_col_idx).last_val := 0;
                        l_key_col_idx := l_key_col_idx + 1; 
                    END IF;
                END LOOP;
            END LOOP;
            l_key_idx := l_key_idx + 1;   -- For the next key.
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure load_tab_keys with input id <' || iop_tab.id || '> with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END load_tab_keys;
    
    FUNCTION string_of_length
        (
          ip_length             PLS_INTEGER
        , ip_char               CHAR
        )
        RETURN VARCHAR2
    IS
        l_string                VARCHAR2(32767) := '';      -- Initialised to empty string (not NULL).
        l_count                 PLS_INTEGER;
    BEGIN
        FOR l_count IN 1..ip_length
        LOOP
            l_string := l_string || ip_char;
        END LOOP;
        RETURN l_string;
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in function string_of_length with input length <' || ip_length || '> and char <' || ip_char || '>  with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END string_of_length;
    
    PROCEDURE write_buffer
    IS
    BEGIN
        IF LENGTH(l_output_buffer) = 0
        THEN
            RETURN;
        END IF;
        
        l_part_number := l_part_number + 1;
        dbms_output.put_line(lc_im || 'Writing session <' || l_session_id || '> part number <' || l_part_number || '>');
        
        INSERT
          INTO odisvn_dbgit_generator_outputs
               (
               session_id
             , part_number
             , part_text
               )
        VALUES (
               l_session_id
             , l_part_number
             , l_output_buffer
               )
        ;
        l_output_buffer := '';
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure write_buffer with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END write_buffer;
    
    PROCEDURE output_part
        (
          ip_part_text          VARCHAR
        )
    IS
        l_part_remainder        VARCHAR(32767);
        l_chunk                 VARCHAR(4000);
        l_buffer_remainder      VARCHAR(4000);
        l_buffer_used           PLS_INTEGER;
    BEGIN
        l_part_remainder := ip_part_text;
        
        WHILE LENGTH(l_part_remainder) > 0
        LOOP
            -- Remove the next chunk from the start of the part remainder.
            l_chunk := SUBSTR(l_part_remainder, 1, 4000);                   -- Note that the chunk size can be < 4000.
            l_part_remainder := SUBSTR(l_part_remainder, 4001);
            
            l_buffer_used := LENGTH(l_output_buffer);
            IF l_buffer_used + LENGTH(l_chunk) > 4000
            THEN
                -- The output buffer cannot accomodate the chunk so fill up the buffer and write it.
                l_output_buffer := l_output_buffer || SUBSTR(l_chunk, 1, (4000 - LENGTH(l_output_buffer)));
                l_chunk := SUBSTR(l_chunk, (4000 - l_buffer_used));
                write_buffer();
                l_buffer_used := 0;
            END IF;
            
            -- Add the remainder of the chunk to the buffer.
            l_output_buffer := l_output_buffer || l_chunk;
        END LOOP;

    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure output_part with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END output_part;
    
    PROCEDURE output_part_line
        (
          ip_part_text          VARCHAR
        )
    IS
    BEGIN
        output_part(ip_part_text || lc_new_line);
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(lc_em || 'Caught exception in procedure output_part_line with code <' || SQLCODE || '> and message <' || SQLERRM || '>');
    END output_part_line;
    
BEGIN
    -- Initialise the message output system.
    dbms_output.enable(1000000);
    
    ----------------------------------------------------------------------------
    -- Get the next output session number.
    ----------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO l_count
      FROM odisvn_dbgit_generator_outputs
    ;
    
    IF l_count = 0
    THEN
        l_session_id := 0;
    ELSE
        SELECT MAX(session_id) + 1
          INTO l_session_id
          FROM odisvn_dbgit_generator_outputs
         ;
    END IF;
    
    dbms_output.put_line(lc_im || 'next session ID <' || l_session_id || '>');
    
    ----------------------------------------------------------------------------
    -- Load the source and target table metadata.
    ----------------------------------------------------------------------------
    
    --
    -- Ensure interface has zero or one source set (current supported limits of this code).
    --
    SELECT COUNT(*)
      INTO l_count
      FROM snp_src_set
     WHERE i_pop = ip_interface_id
    ;
    dbms_output.put_line(lc_im || 'interface has <' || l_count || '> source sets');
    
    IF l_count = 0
    THEN
        l_src_set(1).id := -1;
        
        SELECT i_table
          INTO l_src_set(1).tabs(1).id
          FROM snp_source_tab
         WHERE i_pop = ip_interface_id
        ;
        dbms_output.put_line(lc_im || 'single source table <' || l_src_set(1).tabs(1).id || '>');
    ELSE
        l_src_set_idx := 1;
        FOR r_src_set
         IN (
            SELECT i_src_set
              FROM snp_src_set
             WHERE i_pop = ip_interface_id
            )
        LOOP
            l_src_set(l_src_set_idx).id := r_src_set.i_src_set;
            l_tab_idx := 1;
            FOR r_src_set_tab
             IN (
                SELECT i_table
                  FROM snp_source_tab
                 WHERE i_src_set = r_src_set.i_src_set
                )
            LOOP
                l_src_set(l_src_set_idx).tabs(l_tab_idx).id := r_src_set_tab.i_table;
                dbms_output.put_line(lc_im || 'source set <' || r_src_set.i_src_set || '> source table <' || r_src_set_tab.i_table || '>');
            END LOOP;
        END LOOP;
    END IF;
    
    --
    -- Load the source table columns and table keys.
    --
    FOR l_src_set_idx IN 1..l_src_set.LAST
    LOOP
        FOR l_tab_idx IN 1..l_src_set(l_src_set_idx).tabs.LAST
        LOOP
            load_tab(l_src_set(l_src_set_idx).tabs(l_tab_idx));
            load_tab_cols(l_src_set(l_src_set_idx).tabs(l_tab_idx));
            load_tab_keys(l_src_set(l_src_set_idx).tabs(l_tab_idx));
        END LOOP;
    END LOOP;
    
    --
    -- Load target table details.
    --
    SELECT i_table
      INTO l_tgt_tab.id
      FROM snp_pop
     WHERE i_pop = ip_interface_id
    ;
    dbms_output.put_line(lc_im || 'target table <' || l_tgt_tab.id || '>');
    
    load_tab(l_tgt_tab);
    load_tab_cols(l_tgt_tab);
    load_tab_keys(l_tgt_tab);
     
    ----------------------------------------------------------------------------
    -- Output the tests.
    ----------------------------------------------------------------------------
    
    -- Write the page header.
    output_part_line('!3 Change History');
    output_part_line('![:');
    output_part_line('Date|Name:Version|Change Ref No|Change Description');
    output_part_line(TO_CHAR(SYSDATE,'YYYY-MM-DD') || '|Retro Generator|0.1|No PBI:Retro Generated');
    output_part_line(':]!');
    output_part_line('');
    
    -- Set up the Java libraries.
    output_part_line('!path lib/*.jar');
    output_part_line('!path lib/ojdbc5.zip');
    output_part_line('');
    output_part_line('|Import Fixture|');
    output_part_line('|dbfit.fixture|');
    output_part_line('');
    
    -- Clean source tables.
    output_part_line('Clean Source and Target tables');
    output_part_line('');
    output_part_line('Clean Source Tables');
    
    dbms_output.put_line(lc_im || 'l_src_set.LAST <' || l_src_set.LAST || '>');
    FOR l_src_set_idx IN 1..l_src_set.LAST
    LOOP
        dbms_output.put_line(lc_im || 'writing Clean for source set number <' || l_src_set_idx || '>');
        dbms_output.put_line(lc_im || 'source set number <' || l_src_set_idx || '> has <' || l_src_set(l_src_set_idx).tabs.LAST || '> tables');
        
        output_part_line('!|DatabaseEnvironment|' || INITCAP(l_src_set(l_src_set_idx).tabs(1).tech_name) || '|');
        -- We take a guess here. We have no concept of 'system' for MOI logical schemas so this will need to be overridden to 'MOI' for MOI connections.
        output_part_line('|Connect Using File|DATASERVER_' || l_src_set(l_src_set_idx).tabs(1).lschema_name || '_JDBC.properties|');    
        output_part_line('');
        output_part_line('|Clean|');
        output_part_line('|table|clean?|');        
        
        FOR l_tab_idx IN 1..l_src_set(l_src_set_idx).tabs.LAST
        LOOP
            output_part_line('|${' || l_src_set(l_src_set_idx).tabs(l_tab_idx).lschema_name || '}.' || l_src_set(l_src_set_idx).tabs(l_tab_idx).name || '|True|');
        END LOOP;
        
        output_part_line('');  
        output_part_line('!|DatabaseEnvironment|');
        output_part_line('|Commit|');
        output_part_line('|Close|');
        output_part_line('');
    END LOOP;

    -- Clean target tables.
    output_part_line('Clean Target Tables');
    output_part_line('!|DatabaseEnvironment|' || UPPER(l_tgt_tab.tech_name) || '|');
    output_part_line('|Connect Using File|DATASERVER_' || l_tgt_tab.lschema_name || '_JDBC.properties|');
    output_part_line('');
    output_part_line('|Clean|');
    output_part_line('|table|clean?|');
    output_part_line('|${' || l_tgt_tab.lschema_name || '}.' || l_tgt_tab.name || '|True|');
    output_part_line('');
    output_part_line('!|DatabaseEnvironment|');
    output_part_line('|Commit|');
    output_part_line('|Close|');
    output_part_line('');
          
    -- Output boundary testing NULL test inputs.
    dbms_output.put_line(lc_im || 'starting generation of NULL boundary values');
    output_part_line('Set up boundary testing NULL inputs');
    
    -- Process each source set.
    FOR l_src_set_idx in 1..l_src_set.LAST
    LOOP
        dbms_output.put_line(lc_im || 'processing source set <' || l_src_set(l_src_set_idx).id || '>');
        -- Process each source table.
        FOR l_tab_idx in 1..l_src_set(l_src_set_idx).tabs.LAST
        LOOP
            dbms_output.put_line(lc_im || 'processing source set <' || l_src_set(l_src_set_idx).id || '> table <' || l_src_set(l_src_set_idx).tabs(l_tab_idx).id || '>');
            output_part_line('|Insert|${' || l_src_set(l_src_set_idx).tabs(l_tab_idx).lschema_name || '}.' || l_src_set(l_src_set_idx).tabs(l_tab_idx).name ||'|');
            
            -- Output column names.
            dbms_output.put_line(lc_im || 'table has <' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST || '> columns');
            FOR l_col_idx2 IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
            LOOP
                output_part('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).name);
            END LOOP;
            output_part_line('|');
            
            -- Output one row per nullable column.
            L_COUNT:=l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST;
            FOR l_col_idx2 IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
            LOOP
                dbms_output.put_line(lc_im || 'doing column number <' || l_col_idx2 || '> with not_null_ind of <'
                                  || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).not_null_ind || '>');
                                  
                IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).not_null_ind = 0       -- The column is nullable.
                THEN
                    dbms_output.put_line(lc_im || 'column number <' || l_col_idx2 || '> is nullable');
                    
                    -- Output a full row for this (nullable) column.
                    FOR l_col_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
                    LOOP
                        l_key_count := 0;
                        -- Search the keys only if there are some keys defined (we get a PL/SQL error if we access the LAST property of an empty table).
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).keys.COUNT > 0
                        THEN
                            FOR l_key_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).keys.LAST
                            LOOP
                                dbms_output.put_line(lc_im || 'checking key number <' || l_key_idx || '>');
                                FOR l_key_col_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).col_idx.LAST
                                LOOP
                                    IF l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).col_idx(l_key_col_idx).idx = l_col_idx
                                    THEN
                                        -- The current column is part of a key; update the count of key memberships.
                                        l_key_count := l_key_count + 1;
                                        dbms_output.put_line(lc_im || 'column is a member of key number <' || l_key_idx || '> in position <' || l_key_col_idx || '>');
                                    END IF;
                                END LOOP;
                            END LOOP;
                        END IF;
                        
                        --dbms_output.put_line(lc_im || 'column is a member of <' || l_key_count || '> keys');
                        
                        IF l_col_idx = l_col_idx2
                        THEN
                            -- Output the cell value for the column in focus (the nullable column).
                            output_part('|NULL');
                        ELSE
                            -- Output the cell value for another column.
                            IF l_key_count > 0
                            THEN
                                -- The column is part of a key. Ensure we write a unique value.
                                IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT'
                                                                                                        , 'INTEGER'
                                                                                                        , 'SHORTINTEGER'
                                                                                                        , 'DECIMAL'
                                                                                                        , 'LONGINTEGER,'
                                                                                                        , 'NUMBER'
                                                                                                         )
                                THEN
                                    -- The column type is numeric.
                                    -- Increment the next value.
                                    l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                    output_part('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val);
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('CHAR'
                                                                                                           , 'NCHAR'
                                                                                                           , 'VARCHAR'
                                                                                                           , 'VARCHAR2'                                                                                                           
                                                                                                           , 'NVARCHAR2'
                                                                                                           , 'LONG'
                                                                                                           , 'CLOB'
                                                                                                            )
                                THEN
                                    -- The column type is character string.
                                    -- Increment the next value.
                                    l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                    -- We use a set of 48 printable ASCII characters and we generate a string using this 'base 48' method.
                                    SELECT DECODE(
                                                 TRUNC(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val / 48)
                                               , 0                                                                              -- 0 <= last_val < 48
                                               , CHR(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 48)
                                               , CONCAT(
                                                       CHR(
                                                          TRUNC(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val / 48) + 48
                                                          )
                                                     , CHR(
                                                          MOD(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val, 48) + 48
                                                          )
                                                       )
                                                 )
                                      INTO l_chr_key_val
                                      FROM dual
                                    ;
                                    output_part('|' || l_chr_key_val);
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DATE'
                                                                                                           , 'TIMESTAMP'
                                                                                                            )
                                THEN
                                    -- Increment the next value.
                                    l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                    output_part('|' || TO_CHAR(lc_datetime_key_baseval + l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val, 'YYYY-MM-DD HH24:MI:SS'));
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('RAW'
                                                                                                           , 'LONG RAW'                                
                                                                                                           , 'BLOB'
                                                                                                            )
                                THEN
                                    raise_application_error(-20000, 'Cannot yet handle binary data types. I''ll get to it when I can!');
                                ELSE
                                    raise_application_error(-20000, 'Cannot yet handle data type ' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name || '. I''ll get to it when I can!');
                                END IF;
                            ELSE
                                -- The column is not part of a key.
                                IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('CHAR'
                                                                                                        , 'NCHAR'
                                                                                                        , 'VARCHAR'
                                                                                                        , 'VARCHAR2'
                                                                                                        , 'NVARCHAR2'
                                                                                                        , 'LONG'
                                                                                                        , 'CLOB'
                                                                                                         )
                                THEN
                                    -- Output the standard character string value.
                                    output_part('|' || lc_str_col_val);
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT'
                                                                                                           , 'INTEGER'
                                                                                                           , 'SHORTINTEGER'
                                                                                                           , 'DECIMAL'
                                                                                                           , 'LONGINTEGER,'
                                                                                                           , 'NUMBER'
                                                                                                            )
                                THEN
                                    -- Output the standard numeric value.
                                    output_part('|' || lc_num_col_val);
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DATE'
                                                                                                           , 'TIMESTAMP'
                                                                                                            )
                                THEN
                                    -- Output the standard date/time value.
                                    output_part('|' || lc_datetime_col_val);
                                ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('RAW'
                                                                                                           , 'LONG RAW'
                                                                                                           , 'BLOB'
                                                                                                            )
                                THEN
                                    raise_application_error(-20000, 'Cannot yet handle binary data types. I''ll get to it when I can!');
                                ELSE
                                    raise_application_error(-20000, 'Cannot yet handle data type ' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name || '. I''ll get to it when I can!');                                    
                                END IF;
                            END IF;
                        END IF;
                    END LOOP;
                    output_part_line('|');
                ELSE
                    dbms_output.put_line(lc_im || 'column number <' || l_col_idx2 || '> is not nullable');
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;
    
    -- Output boundary testing MAXIMUM test inputs.
    dbms_output.put_line(lc_im || 'starting generation of MAXIMA boundary values');
    output_part_line('');
    output_part_line('Set up boundary testing MAXIMA inputs');
    
    -- Process each source set.
    FOR l_src_set_idx in 1..l_src_set.LAST
    LOOP
        dbms_output.put_line(lc_im || 'processing source set <' || l_src_set(l_src_set_idx).id || '>');
        -- Process each source table.
        FOR l_tab_idx in 1..l_src_set(l_src_set_idx).tabs.LAST
        LOOP
            dbms_output.put_line(lc_im || 'processing source set <' || l_src_set(l_src_set_idx).id || '> table <' || l_src_set(l_src_set_idx).tabs(l_tab_idx).id || '>');
            output_part_line('|Insert|${' || l_src_set(l_src_set_idx).tabs(l_tab_idx).lschema_name || '}.' || l_src_set(l_src_set_idx).tabs(l_tab_idx).name ||'|');
            
            -- Output column names.
            dbms_output.put_line(lc_im || 'table has <' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST || '> columns');
            FOR l_col_idx2 IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
            LOOP
                output_part('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).name);
            END LOOP;
            output_part_line('|');
            
            -- Output one row per column.
            FOR l_col_idx2 in 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
            LOOP
                -- Output a full row for this column.
                FOR l_col_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).cols.LAST
                LOOP                      
                    l_key_count := 0;
                    -- Search the keys only if there are some keys defined (we get a PL/SQL error if we access the LAST property of an empty table).
                    IF l_src_set(l_src_set_idx).tabs(l_tab_idx).keys.COUNT > 0
                    THEN
                        FOR l_key_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).keys.LAST
                        LOOP
                            dbms_output.put_line(lc_im || 'checking key number <' || l_key_idx || '>');
                            FOR l_key_col_idx IN 1..l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).col_idx.LAST
                            LOOP
                                IF l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).col_idx(l_key_col_idx).idx = l_col_idx
                                THEN
                                    -- The current column is part of a key; update the count of key memberships.
                                    l_key_count := l_key_count + 1;
                                    dbms_output.put_line(lc_im || 'column is a member of key number <' || l_key_idx || '> in position <' || l_key_col_idx || '>');
                                END IF;
                            END LOOP;
                        END LOOP;
                    END IF;
                    
                    IF l_col_idx = l_col_idx2
                    THEN
                        -- Output the cell maximum value for the column in focus (even if this column is part of a key).
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('INTEGER'
                                                                                                , 'SHORTINTEGER'
                                                                                                , 'LONGINTEGER,'
                                                                                                 )
                        THEN
                            output_part('|' || SUBSTR(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length));
                        ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DECIMAL'
                                                                                                   , 'NUMBER'
                                                                                                    )
                        THEN
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision = 0 
                            THEN
                                output_part('|' || SUBSTR(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length));
                            ELSE
                                output_part('|' || SUBSTR(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length
                                                                               - l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision
                                                             )
                                                    || '.'
                                                    || SUBSTR(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision)
                                               );
                            END IF;
                        ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('CHAR'
                                                                                                   , 'NCHAR'
                                                                                                   , 'VARCHAR'
                                                                                                   , 'VARCHAR2'
                                                                                                   , 'NVARCHAR2'
                                                                                                   , 'LONG'
                                                                                                   , 'CLOB'
                                                                                                    )
                        THEN
                            output_part('|' || string_of_length(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length, lc_str_col_val));
                        ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DATE'
                                                                                                   , 'TIMESTAMP'
                                                                                                    )
                        THEN
                            output_part('|' || lc_datetime_col_val);
                        ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT'
                                                                                                    )
                        THEN
                            output_part('|' || SUBSTR(lc_max_num_str, 0, 38));
                        ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('RAW'
                                                                                                   , 'BLOB'
                                                                                                    )
                        THEN
                            raise_application_error(-20000, 'Cannot yet handle binary data types. I''ll get to it when I can!');
                        ELSE
                            raise_application_error(-20000, 'Cannot yet handle data type ' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name || '. I''ll get to it when I can!');                                    
                        END IF;
                    ELSE
                        -- Output the cell value for another column. We don't use the maximum values for these columns.
                        IF l_key_count > 0
                        THEN
                            -- The column is part of a key. Ensure we write a unique value.
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT'
                                                                                                    , 'INTEGER'
                                                                                                    , 'SHORTINTEGER'
                                                                                                    , 'DECIMAL'
                                                                                                    , 'LONGINTEGER,'
                                                                                                    , 'NUMBER'
                                                                                                     )
                            THEN
                                -- The column type is numeric.
                                -- Increment the next value.
                                l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                output_part('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val);
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('CHAR'
                                                                                                       , 'NCHAR'
                                                                                                       , 'VARCHAR'
                                                                                                       , 'VARCHAR2'
                                                                                                       , 'NVARCHAR2'
                                                                                                       , 'LONG'
                                                                                                       , 'CLOB'
                                                                                                        )
                            THEN
                                -- The column type is character string.
                                -- Increment the next value.
                                l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                -- We use a set of 48 printable ASCII characters and we generate a string using this 'base 48' method.
                                SELECT DECODE(
                                             TRUNC(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val / 48)
                                           , 0                                                                                          -- 0 <= last_val < 48
                                           , CHR(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 48)
                                           , CONCAT(
                                                   CHR(
                                                      TRUNC(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val / 48) + 48
                                                      )
                                                 , CHR(
                                                      MOD(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val, 48) + 48
                                                      )
                                                   )
                                             )
                                  INTO l_chr_key_val
                                  FROM dual
                                ;
                                output_part('|' || l_chr_key_val);
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DATE'
                                                                                                       , 'TIMESTAMP'
                                                                                                        )
                            THEN
                                -- Increment the next value.
                                l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                                output_part('|' || TO_CHAR(lc_datetime_key_baseval + l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val, 'YYYY-MM-DD HH24:MI:SS'));
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('RAW'
                                                                                                       , 'LONG RAW'                            
                                                                                                       , 'BLOB'
                                                                                                        )
                            THEN
                                raise_application_error(-20000, 'Cannot yet handle binary data types. I''ll get to it when I can!');
                            ELSE
                                raise_application_error(-20000, 'Cannot yet handle data type ' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name || '. I''ll get to it when I can!');
                            END IF;
                        ELSE
                            -- The column is not part of a key. Output standard constant values.
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('CHAR'
                                                                                                    , 'NCHAR'
                                                                                                    , 'VARCHAR'
                                                                                                    , 'VARCHAR2'
                                                                                                    , 'NVARCHAR2'
                                                                                                    , 'LONG'
                                                                                                    , 'CLOB'
                                                                                                     )
                            THEN
                                -- Output the standard character string value.
                                output_part('|' || lc_str_col_val);
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT'
                                                                                                       , 'INTEGER'
                                                                                                       , 'SHORTINTEGER'
                                                                                                       , 'DECIMAL'
                                                                                                       , 'LONGINTEGER,'
                                                                                                       , 'NUMBER'
                                                                                                        )
                            THEN
                                -- Output the standard numeric value.
                                output_part('|' || lc_num_col_val);
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DATE'
                                                                                                       , 'TIMESTAMP'
                                                                                                        )
                            THEN
                                -- Output the standard date/time value.
                                output_part('|' || lc_datetime_col_val);
                            ELSIF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('RAW'
                                                                                                       , 'LONG RAW'                            
                                                                                                       , 'BLOB'
                                                                                                        )
                            THEN
                                raise_application_error(-20000, 'Cannot yet handle binary data types. I''ll get to it when I can!');
                            ELSE
                                raise_application_error(-20000, 'Cannot yet handle data type ' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name || '. I''ll get to it when I can!');                                
                            END IF;
                        END IF;
                    END IF;
                END LOOP;
                output_part_line('|');
            END LOOP;
            output_part_line('');
        END LOOP;
    END LOOP;
--------------------------------Max Values data generation-------------------------------------------------------------
/***** POOJA'S CODE
    l_tab_idx:=0;
    dbms_output.put_line('|Insert|${'||l_src_set(l_src_set_idx).tabs(l_tab_idx).lschema_name||'}.' ||l_src_set(l_src_set_idx).tabs(l_tab_idx).name||'|');
    
    -- Write the column names.
    FOR l_col_idx2 IN 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST
    LOOP
        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).type_name IN ('DATE'
                                                                                 , 'FLOAT'
                                                                                 , 'INTEGER'
                                                                                 , 'SHORTINTEGER'
                                                                                 , 'DECIMAL'
                                                                                 , 'LONGINTEGER'
                                                                                 , 'NUMBER'
                                                                                 , 'CHAR'
                                                                                 , 'NCHAR'
                                                                                 , 'NVARCHAR2'
                                                                                 , 'VARCHAR2'
                                                                                 , 'LONG'
                                                                                  )
        THEN
            dbms_output.put('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).name);
        END IF;
    END LOOP;

    dbms_output.put('|');
    dbms_output.put_line('');
  
    FOR l_col_idx2 in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST     --outputs one row per each nullable column
    LOOP
        --dbms_output.put_line('|');
        --dbms_output.put_line(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).not_null_ind);
        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).type_name IN ('DATE'
                                                                                 , 'FLOAT'
                                                                                 , 'INTEGER'
                                                                                 , 'SHORTINTEGER'
                                                                                 , 'DECIMAL'
                                                                                 , 'LONGINTEGER'
                                                                                 , 'NUMBER'
                                                                                 , 'CHAR'
                                                                                 , 'NCHAR'
                                                                                 , 'NVARCHAR2'
                                                                                 , 'VARCHAR2'
                                                                                 , 'LONG'
                                                                                  )
        THEN
            FOR l_col_idx in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST -------------------outputs each column value for one row---------------
            LOOP
                l_key_count := 0;
                --IF 
                --(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name <> 'NUMBER') ---checks if col is nullable
                --THEN
                    ---------------checks if the column in question is a part of any key-----------
                    For l_key_col_idx in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).keys(l_key_idx).col_idx.LAST
                    LOOP
                        IF  (l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).col_idx(l_key_col_idx).idx = l_col_idx)
                        THEN
                            l_key_count:=l_key_count+1;
                        END IF;
                    END LOOP;
                    --dbms_output.put_line(l_key_count);

                    IF l_col_idx = l_col_idx2
                    THEN
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('INTEGER','SHORTINTEGER','LONGINTEGER,')
                        THEN
                            dbms_output.put('|' || substr(lc_max_num_str,1,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length));
                        END IF;
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DECIMAL','NUMBER')
                        THEN
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision = 0 
                            THEN
                                dbms_output.put('|' || substr(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length));
                            ELSE
                                dbms_output.put('|' || substr(lc_max_num_str, 1, l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length
                                                  - l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision)
                                                    || '.'
                                                    || substr(lc_max_num_str,1,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision)
                                               );
                            END IF;
                        END IF;
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')
                        THEN
                            dbms_output.put('|' || DBMS_RANDOM.STRING('U',l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length));
                        END IF;
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('DATE')
                        THEN
                            dbms_output.put('|9999-12-31 23:59:59');
                        END IF;
                        IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT')
                        THEN
                            dbms_output.put('|' || substr(lc_max_num_str,0,38));
                        END IF;
                    ELSE
                        IF (l_key_count > 0)
                        THEN
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER,','NUMBER')
                            THEN
                                dbms_output.put('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val);
                                l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val := l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val + 1;
                            END IF;
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')
                            THEN
                                select decode(trunc(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).last_val / 48) , 0, CHR(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval + 48),concat(chr(trunc(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval/48)+48),chr(mod(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval,48)+48)))
                                  into l_chr_key_val
                                  from dual
                                ;
                                dbms_output.put('|'||l_chr_key_val);
                                l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval:=l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval + 1;
                                --dbms_output.put('|');
                            END IF;
                        ELSE
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')
                            THEN
                                dbms_output.put('|'||lc_str_col_val);
                            END IF; 
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER,','NUMBER')
                            THEN
                                dbms_output.put('|'||lc_num_col_val);
                            END IF;
                            IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name = 'DATE'
                            THEN
                                dbms_output.put('|'||'2012-01-01 00:00:00');
                            END IF;
                        END IF;
                    END IF;
                --END IF;
            END LOOP;
            dbms_output.put('|');
            dbms_output.put_line('');
        END IF;
    END LOOP;
-------------------------------------------------------------------------------------------------------------------------

--------------------------------Min Values data generation-------------------------------------------------------------

   l_tab_idx:=0;
   dbms_output.put_line('|Insert|${'||l_src_set(l_src_set_idx).tabs(l_tab_idx).lschema_name||'}.' ||l_src_set(l_src_set_idx).tabs(l_tab_idx).name||'|');
   -- Write the column names.
    FOR l_col_idx2 IN 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST
    LOOP
        IF (l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).type_name IN ('DATE','FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER','NUMBER','CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG'))
        THEN   dbms_output.put('|' || l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).name);
        END IF;
    END LOOP;
    dbms_output.put('|');
    dbms_output.put_line('');
  
    FOR  l_col_idx2 in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST --outputs one row per each nullable column
    LOOP
		--dbms_output.put_line('|');
		--dbms_output.put_line(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).not_null_ind);
		IF 
			   ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx2).type_name IN ('DATE','FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER','NUMBER','CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')) 
		THEN
		
	   
			FOR  l_col_idx in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).cols.LAST -------------------outputs each column value for one row---------------
			LOOP
				l_key_count:=0;
				--IF 
					--(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name <> 'NUMBER') ---checks if col is nullable
				--THEN
						---------------checks if the column in question is a part of any key-----------
					For l_key_col_idx in 1..l_src_set(l_src_set_idx).TABS(l_tab_idx).keys(l_key_idx).colindex.LAST
					LOOP
						IF  (l_src_set(l_src_set_idx).tabs(l_tab_idx).keys(l_key_idx).colindex(l_key_col_idx).idx = l_col_idx)
						THEN
							l_key_count:=l_key_count+1;
						END IF;
					END LOOP;
					--dbms_output.put_line(l_key_count);
					
					IF (l_col_idx = l_col_idx2) 
					THEN
              IF 
                ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('INTEGER','SHORTINTEGER','LONGINTEGER,')) 
              THEN
                  dbms_output.put('|' || substr(lc_min_num_str,1,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length+1));
              END IF;
              IF 
                ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('DECIMAL','NUMBER')) 
              THEN
                  IF
                    l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision = 0 
                  THEN
                    dbms_output.put('|' || substr(lc_min_num_str,1,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length+1));
                  ELSE
                    dbms_output.put('|' || substr(lc_min_num_str,1,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).length-l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision+1)||'.'||substr(lc_min_num_str,2,l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).precision));
                  END IF;
                  
              END IF;
              IF 
                ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')) 
              THEN
                  dbms_output.put('|!' );
              END IF;
              IF 
                ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('DATE') )
              THEN
                  dbms_output.put('|0001-01-01 00:00:00');
              END IF;
              IF 
                ( l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name IN ('FLOAT')) 
              THEN
                  dbms_output.put('|' || substr(lc_min_num_str,0,39));
              END IF;
              
					ELSE
						IF (l_key_count > 0)
						THEN
							IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER,','NUMBER')
							THEN
								dbms_output.put('|'||l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval);
								l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval:=l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval+1;
							END IF;
							IF l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')
							THEN
								select  decode(trunc(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval/48),0,chr(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval + 48),concat(chr(trunc(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval/48)+48),chr(mod(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval,48)+48))) into l_chr_key_val from dual ;
								dbms_output.put('|'||l_chr_key_val);
								l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval:=l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).lastval+1;
								--dbms_output.put('|');
							END IF;
							
						ELSE
							IF 
									l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG')
							THEN
									dbms_output.put('|'||lc_str_col_val);
							END IF; 
							IF 
									l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name in ('FLOAT','INTEGER','SHORTINTEGER','DECIMAL','LONGINTEGER,','NUMBER')
							THEN
									dbms_output.put('|'||lc_num_col_val);
							END IF;
							IF 
									(l_src_set(l_src_set_idx).tabs(l_tab_idx).cols(l_col_idx).type_name = 'DATE')
							THEN
									dbms_output.put('|'||'2012-01-01 00:00:00');
							END IF;
					  
						END IF;
					END IF;
				--END IF;
			END LOOP;
			dbms_output.put('|');
			dbms_output.put_line('');
		END IF;
    END LOOP;
-----------------------------------------------------------------------------------------------------------------------

-----------------------------selecting data from target table----------------------------------------

  -- Connect to the target server and verify the results.
    --
    dbms_output.put_line(' ');
    dbms_output.put_line('!|DatabaseEnvironment|' || UPPER(l_tgt_tab.tech_name)||'|');
    dbms_output.put_line('|ConnectUsingFile|DATASERVER_' || l_tgt_tab.lschema_name || '_JDBC.properties|');
    dbms_output.put_line(' ');
    l_ind := FALSE;
    
dbms_output.put('|Query|SELECT ');    
FOR l_tgt_tab_col_idx IN 1..l_tgt_tab.cols.LAST 
    LOOP
        IF l_ind
        THEN
            dbms_output.put(',');
        ELSE
            -- Don't write a comma before the first column name.
            l_ind := TRUE;
        END IF;
        dbms_output.put(l_tgt_tab.cols(l_tgt_tab_col_idx).name);
    END LOOP;
    dbms_output.put(' FROM ${' || l_tgt_tab.lschema_name || '}.' || l_tgt_tab.name||'|');
dbms_output.put_line('');

dbms_output.put('|');
FOR l_tgt_tab_col_idx IN 1..l_tgt_tab.cols.LAST 
    LOOP
        dbms_output.put(l_tgt_tab.cols(l_tgt_tab_col_idx).name||'|');
    END LOOP;
    
dbms_output.put_line('');
*****/    
    -- Commit the session output.
    dbms_output.put_line(lc_im || 'Committing output');
    COMMIT;
END generate_tests;