UPDATE odiscm_scm_actions
   SET system_type_name               = '<SCMSystemTypeName>'
     , add_file_command_text          = '<SCMAddFileCommand>'
     , basic_command_text             = '<SCMBasicCommand>'
     , chk_file_in_src_cntrl_cmd_text = '<SCMCheckFileInSourceControlCommand>'
     , check_out_command_text         = '<SCMCheckOutCommand>'
     , requires_check_out_ind         = '<SCMRequiresCheckOut>'
     , wc_config_delete_file_cmd_text = '<SCMWorkingCopyDeleteFileCommand>'
 WHERE odi_user_name = '<OdiScmOdiUserName>'
/

INSERT
  INTO odiscm_scm_actions
       (
       odi_user_name
     , system_type_name
     , add_file_command_text
     , basic_command_text
     , chk_file_in_src_cntrl_cmd_text
     , check_out_command_text
     , requires_check_out_ind
     , wc_config_delete_file_cmd_text
       )
SELECT '<OdiScmOdiUserName>'
     , '<SCMSystemTypeName>'
     , '<SCMAddFileCommand>'
     , '<SCMBasicCommand>'
     , '<SCMCheckFileInSourceControlCommand>'
     , '<SCMCheckOutCommand>'
     , '<SCMRequiresCheckOut>'
     , '<SCMWorkingCopyDeleteFileCommand>'
  FROM dual
 WHERE '<OdiScmOdiUserName>'
   NOT
    IN ( 
       SELECT odi_user_name
         FROM odiscm_scm_actions
       )
/

COMMIT
/