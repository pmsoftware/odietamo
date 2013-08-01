SET serveroutput on size 1000000
 
DECLARE
    i_type_name       VARCHAR2(100);
    l_is_pack_step    INTEGER;
    l_is_proc_cmd     INTEGER;
    l_is_int_map      INTEGER;
    l_object          VARCHAR2(500);
    l_txt             VARCHAR2(32767);
    l_txt1            VARCHAR2(50);
    l_idx             PLS_INTEGER;
    l_idx2            PLS_INTEGER;  
    l_idx3            PLS_INTEGER := 0;
    l_txt_part        snp_txt.txt%TYPE;
    l_count           PLS_INTEGER;
  
    TYPE tab_txt_chunks IS TABLE OF snp_txt.txt%TYPE
          INDEX BY BINARY_INTEGER; 
    l_txt_chunks  tab_txt_chunks;   
    TYPE tab_search_string IS TABLE OF VARCHAR2(50) -- array to hold all the strings to search for
          INDEX BY BINARY_INTEGER; 
    l_search_string   tab_search_string;
   
BEGIN
    l_search_string(0) := 'example search term, add others to the PL/SQL table';  
    
    dbms_output.put_line('Starts');

    FOR c_i_txt
     IN (
        SELECT i_txt
             , origine_name
             , MAX(txt_ord)
                   AS max_txt_ord
          FROM snp_txt 
         INNER 
          JOIN snp_orig_txt
            ON snp_txt.i_txt_orig = snp_orig_txt.i_txt_orig
         group by i_txt, origine_name
         ORDER
            BY i_txt
        )
    LOOP
        l_txt_chunks.DELETE;
        
        FOR l_idx IN 0..c_i_txt.max_txt_ord
        LOOP
            SELECT txt
              INTO l_txt_part
              FROM snp_txt
             WHERE i_txt = c_i_txt.i_txt
               AND txt_ord = l_idx
            ;
           l_txt_chunks(l_idx) := NVL(l_txt_part,'');
        END LOOP;
       
        IF c_i_txt.max_txt_ord = 0
        THEN
           l_txt := UPPER(l_txt_chunks(0));
        ELSE
           FOR l_idx2 IN 0..(c_i_txt.max_txt_ord - 1)
           LOOP
              l_txt := UPPER(l_txt_chunks(l_idx2) || l_txt_chunks(l_idx2 + 1));
           END LOOP;
        END IF;
        
        FOR l_idx3 IN 0..l_search_string.LAST
        LOOP
            l_txt1:= UPPER(l_search_string(l_idx3));
            
            IF INSTRC(UPPER(l_txt), l_txt1) > 0
            THEN
                --
                -- The current text contains the current search string.
                --
                l_is_pack_step := 0;
                l_is_proc_cmd := 0;
                l_is_int_map := 0;
                
                SELECT COUNT(*)
                  INTO l_is_pack_step
                  FROM snp_step
                 WHERE i_txt_action = c_i_txt.i_txt
                ;
                
                IF l_is_pack_step > 0
                THEN  
                    SELECT '-Package-'  || p.project_name || '/' || f.folder_name || '/' || b.pack_name || '(' || b.i_package || '.' || a.i_step || ')' 
                      INTO l_object
                      FROM snp_step a
                     INNER
                      JOIN snp_package b
                        ON a.i_package = b.i_package
                     INNER
                      JOIN snp_folder f
                        ON b.i_folder = f.i_folder
                     INNER
                      JOIN snp_project p
                        ON f.i_project = p.i_project
                     WHERE a.i_txt_action = c_i_txt.i_txt
                    ;
                END IF;
                
                SELECT COUNT(*)
                  INTO l_is_proc_cmd
                  FROM snp_line_trt
                 WHERE def_i_txt = c_i_txt.i_txt
                ;
                
                IF l_is_proc_cmd > 0
                THEN  
                    SELECT '-Procedure Command-' || p.project_name || '/' || f.folder_name || '/' || b.trt_name || '(' || b.i_trt || '.' || a.ord_trt || ')' 
                      INTO l_object
                      FROM snp_line_trt a
                     INNER
                      JOIN snp_trt b
                        ON a.i_trt = b.i_trt
                     INNER
                      JOIN snp_folder f
                        ON b.i_folder = f.i_folder
                     INNER
                      JOIN snp_project p
                        ON f.i_project = p.i_project
                     WHERE a.def_i_txt = c_i_txt.i_txt
                    ;
                END IF;
                
                SELECT COUNT(*)
                  INTO l_is_int_map
                  FROM snp_pop_col
                 WHERE i_txt_map = c_i_txt.i_txt
                ;
                
                IF l_is_int_map > 0
                THEN  
                    SELECT '-Interface Mapping Expression-' || p.project_name || '/' || f.folder_name || '/' || b.pop_name || '(' || b.i_pop || '.' || a.i_pop_col || ')'
                      INTO l_object
                      FROM snp_pop_col a
                     INNER
                      JOIN snp_pop b
                        ON a.i_pop = b.i_pop
                     INNER
                      JOIN snp_folder f
                        ON b.i_folder = f.i_folder
                     INNER
                      JOIN snp_project p
                        ON f.i_project = p.i_project
                     WHERE a.i_txt_map = c_i_txt.i_txt
                    ;
                END IF;
                
                IF l_is_pack_step > 0 OR
                   l_is_proc_cmd > 0 OR
                   l_is_int_map > 0
                THEN
                    dbms_output.put_line ('Search string <' || l_txt1 || '> found in I_TXT <' 
                                      || c_i_txt.i_txt || '> is of type <' || l_object ||'>');
                END IF;
            END IF;
        END LOOP;          
    END LOOP;

    dbms_output.put_line('Ends');
END;
