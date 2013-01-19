#
# Jython Script: startscen_http.py
# Copyright (c) 1999 - 2003 Sunopsis
# Purpose: 
# Sample Jython script that illustrates how a Sunopsis Scenario can be started over an HTTP request.
# The script sends the HTTP request to Sunopsis Repository Explorer that sends the request to Sunopsis Agent.
# When the http request is valid, 2 cookies are set in the HTTP header:
# snps_exec_ok: 'true' or 'false' - true if the scenario was started successfully by the Sunopsis Agent
# snps_session_no: id of the Sunopsis Session started. -1 if the Agent was unable to start the session.
# The contents of the HTTP reply includes also this information as well as a potential error message.
#
# Note: A scenario started successfully doesn't mean that the scenario was executed successfully.
# You have to analyze Sunopsis Logs (given the session number) to have this information.
#
import sys
import httplib
import urllib
import os

repository_explorer_host = '195.10.10.23:8081'		# IP address and port of Sunopsis Repository Explorer
agent_name               = '198.2.4.8'				# Name or IP address of the Sunopsis Agent that will run the scenario
agent_port               = '20910'				# IP port of the Sunopsis Agent

# Master and Work Repository connection information (where the scenario is stored)
master_driver            = 'oracle.jdbc.driver.OracleDriver'
master_url               = 'jdbc:oracle:thin:@OracleServer:1521:Ora9'
master_user              = 'snps_master'
master_psw               = 'NENDKGNKMINNNCOGOINOKDGBGFDGGH' # Password must be encoded (use command: agent encode <pswd>)
work_repository          = 'WorkRep1'

# Sunopsis valid user account on the Master Repository
snps_user                = 'SUPERVISOR'
snps_psw                 = 'LELKIELGLJMDLKMGHEHJDBGBGFDGGH' # Password must be encoded (use command: agent encode <pswd>)

# Scenario Information
scen_name                = 'SCEN_TEST'			# Scenario Name
scen_version             = '1'					# Scenario Version		
context_code             = 'CTX_DEV'			# Code of the execution context
log_level                = '0' 					# Log level to keep in Sunopsis Log. Valid values are 0, 1, ..5
# List of Scenario Variables (PROJECT_CODE.VARIABLE_NAME)
scen_variables           = {
							'DEMOS.CODE_CLIENT':'1234', 
							'DEMOS.ORACLE_USER':'SCOTT'
						   }
# HTTP Reply type. Indicates how the server will reply to the HTTP client.
http_reply               = 'XML'				# Valid values are XML | HTML | TXT

error_msg                = ''
error_code               = 1

try:
	# Connect to the HTTP server (Sunopsis Repository Explorer)
	print 'Connecting to Sunopsis Repository Explorer on: ', repository_explorer_host
	h = httplib.HTTP(repository_explorer_host)
	if not h:
		error_msg = 'Unable to Connect to %s' % repository_explorer_host
		error_code = 1
		print error_msg
	print 'Connected.'

	# Prepare HTTP Request
	print 'Sending Request for Scenario (%s - %s) Executed by Agent (%s - %s)...' % (scen_name, scen_version, agent_name, agent_port)
	snpparamslist = {
		'agent_name': agent_name,
		'agent_port':agent_port, 
		'master_driver':master_driver, 
		'master_url':master_url, 
		'master_user':master_user, 
		'master_psw':master_psw, 
		'work_repository':work_repository, 
		'snps_user':snps_user, 
		'snps_psw':snps_psw, 
		'scen_name':scen_name, 
		'scen_version':scen_version, 
		'context_code':context_code, 
		'log_level':log_level, 
		'http_reply':http_reply
		}
	snpparamslist.update(scen_variables)
	snpparams = urllib.urlencode(snpparamslist)
	startscen_request = '/snpsrepexp/startscen.do?' + snpparams
	
	# Send HTTP Request
	try:
		h.putrequest('POST', startscen_request)
		h.putheader('Content-type', 'application/x-www-form-urlencoded')
		h.putheader('Accept', 'text/plain')
		h.putheader('Host', repository_explorer_host)
		h.endheaders()
	except:
		error_code = 2
		error_msg = '********* Error: Unable to Send Request to %s ************\n' % repository_explorer_host
		error_msg += 'Requested URL: %s\n' % startscen_request
		error_msg += '*********************************************************\n'
		print error_msg
		raise
	print 'Request Sent.'

	# Get the HTTP Reply
	print 'Receiving Reply...'
	try:
		reply, msg, hdrs = h.getreply()
		data = h.getfile().read()		# get the raw data of the reply
	except:
		error_code = 3
		error_msg = '********* Error: Unable to Receive Reply from %s ************\n' % repository_explorer_host
		error_msg += 'Requested URL: %s\n' % startscen_request
		error_msg += '*********************************************************\n'
		print error_msg
		raise
	print 'Reply Recieved.'
	
	# Anlyze error messages.
	# if the reply <> 200 then this is an HTTP failure
	# otherwise, we must analyze the snps_exec_ok cookie and
	# the snps_session_no cookie to see if the scenario was started
	# successfully.
	if reply != 200:
		error_code = 4
		error_msg = '********* Error: HTTP Request Failed ************\n'
		error_msg += 'Reply     : %s\n' % reply
		error_msg += 'Message   : %s\n'% msg
		error_msg += 'Headers   : %s\n'% hdrs
		error_msg += 'Data      : \n**** Start ****\n%s\n**** End ****\n' % data
		error_msg += '******************************************\n'
		print error_msg
	else:
		# Analyze header cookies to get the snps_exec_ok and the snps_session_no cookie
		strhdrs = str(hdrs)
		hdrlines = strhdrs.split(os.linesep)
		for ahdr in hdrlines:
			if ahdr.startswith('Set-Cookie:'):
				cookie = ahdr.split(':')[1].strip()
				if cookie.startswith('snps_exec_ok='):
					snps_exec_ok = cookie.split('=')[1].strip()
				elif cookie.startswith('snps_session_no='):
					snps_session_no = cookie.split('=')[1].strip()
		if snps_exec_ok != 'true':
			error_code = 5
			error_msg  = '********* Error: Scenario Not Started ************\n'
			error_msg += 'Reply     : %s\n' % reply
			error_msg += 'Message   : %s\n'% msg
			error_msg += 'Headers   : %s\n'% hdrs
			error_msg += 'Data      : \n**** Start ****\n%s\n**** End ****\n' % data
			error_msg += '**************************************************\n'
			print error_msg
		else:
			error_code = 0
			error_msg  = '========================================\n'
			error_msg += 'Scenario %s - %s Successfully Started.\n' % (scen_name, scen_version)
			error_msg += 'Session %s is Running.\n' % (snps_session_no)
			error_msg += '========================================\n'
			print error_msg
finally:
	if h:	h.close()
	sys.exit(error_code)