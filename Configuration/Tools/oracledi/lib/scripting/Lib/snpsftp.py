####
## Module :	snpsftp.py
## Implements basic	ftp	client methods
## @author : Sunopsis
## @version : 0.2
####
import os
import ftplib

class AsciiFile:
	def	__init__(self, thefile):
		self.f = thefile
		
	def	asciiwrite(self, line):
		self.f.write(line + os.linesep)
	
class SnpsFTP:
	'''
	SnpsFTP class
	By : Sunopsis
	Basic FTP verbs implementation based on standard ftplib module
		- connect() : connects to a host
		- setmode()
		- login() : sets login information
		- get() and mget() : downloads files
		- put() and mput() : uploads files
        - rename() : rename a file
		- close() : closes the connection
		- delete() : delete a file
		
	- Examples :
	>>>import snpsftp
	>>>x = snpsftp.SnpsFTP(host, user, pass, account, port)
	>>>x.setmode( 'ASCII' | ' BINARY')
	>>>x.setpassive(0) # PUT INTO ACTIVE MODE
	>>>x.(m)get(...)
	>>>x.(m)put(...)
	>>>x.close()
	'''

	def	__init__(self, host='',	user='', passwd='',	acct='', port=0):
		''' **************************************************
		constructor
		@params : host, user, passwd, acct, port
		******************************************************'''
		self.ftp = ftplib.FTP()
		self.setpassive(1) # Default use = PASSIVE(1)
		self.defmode = 'ASCII'
		if host:
			self.connect(host, port)
			if user: self.login(user, passwd, acct)

	def	connect(self, host='', port=0):
		''' **************************************************
		connect : connects to ftp server
		@params : host, port (default = 21)
		******************************************************'''
		self.ftp.connect(host, port)

	def	setpassive(self, passive=1):
		''' **************************************************
		setpassive: Set PASSIVE or ACTIVE mode
		@params : passive (default = 1) # 0 = ACTIVE MODE
		******************************************************'''
		self.ftp.set_pasv(passive) # Default use = ACTIVE (1)

	def	delete(self,filename):
		''' **************************************************
		delete: Delete a file
		@params : filename  # BC Name of File
		******************************************************'''
		self.ftp.delete(filename)
	
	def	login(self,	user = '', passwd =	'',	acct = ''):
		''' **************************************************
		login : login to ftp server
		@params : user (def = ''), passwd (def = ''), acct (def = '')
		******************************************************'''
		self.ftp.login(user, passwd, acct)
		
	def	setmode(self, mode='ASCII'):
		''' **************************************************
		setmode : sets default mode
		@params : mode (def = 'ASCII'). 
		          Valid values 'ASCII' or 'BINARY'
		******************************************************'''
		if (mode ==	'ASCII') or	(mode == 'BINARY'):
			self.defmode = mode
	
	
	def	get(self, src, dest='', mode=''): 
		''' **************************************************
		get : downloads a remote file
		@params : 
		  src : source file on the server
		  dest : destination file or directory on local machine
		  mode : 'ASCII' or 'BINARY' (default mode if none)
		******************************************************'''
		
		s = src
		d = dest	
		filename = os.path.split(src)[1]
		
		if os.path.isdir(dest):
			if dest != '' and dest[-1:] != os.sep:
				dest	+= os.sep
			d = dest + filename
		if not dest:
			d = filename

		if mode:
			self.setmode(mode)
			
		if self.defmode	== "BINARY":
			# mode binary
			outfile	= open(d, 'wb')
			self.ftp.retrbinary("RETR "	+ s , outfile.write)
			outfile.close()
		else: 
			# mode text
			outfile	= open(d, 'wb')
			z = AsciiFile(outfile)
			self.ftp.retrlines("RETR " + s, z.asciiwrite)
			outfile.close()

	def	mget(self, srcdir='', pattern='*', destdir='', mode=''):
		''' **************************************************
		mget : downloads multiple remote files
		@params : 
		  srcdir : source directory on the server
		  pattern : pattern used to retrieve files
		  destdir : destination directory on local machine
		  mode : 'ASCII' or 'BINARY' (default mode if none)
		 @return : 
		   number of files transfered
		******************************************************'''
		nbget =	0
		if destdir != '' and destdir[-1:] != os.sep:
			destdir	+= os.sep
		
		if mode:
			self.setmode(mode)		
		# get remote list and cwd on srcdir			
		lst	= self.getremotepatternlist(srcdir, pattern)
		for	filename in	lst:
			nbget += 1
			dest = destdir + filename
			self.get(filename, dest, mode)
		return nbget


	def	put(self, src, dest, mode='', blocksize=8192): 
		''' **************************************************
		put : uploads a local file
		@params : 
		  src : source local file
		  dest : destination filename on server
		  mode : 'ASCII' or 'BINARY' (default mode if none)
		  blocksize : applies only if binary transfert (default 8192)
		******************************************************'''
		if mode:
			self.setmode(mode)
			
		if self.defmode	== "BINARY":
			# mode binary
			srcfile	= open(src, 'rb')
			self.ftp.storbinary("STOR " + dest , srcfile, blocksize)
			srcfile.close()
		else: 
			# mode text
			srcfile	= open(src, 'r')
			self.ftp.storlines("STOR " + dest, srcfile)
			srcfile.close()
		
	def	mput(self, srcdir='', pattern='*', destdir='', mode='', blocksize=8192):	
		''' **************************************************
		mput : uploads multiple local files
		@params : 
		  srcdir : source local directory
		  pattern : pattern used to retrieve files
		  destdir : destination directory on server
		  mode : 'ASCII' or 'BINARY' (default mode if none)
		  blocksize : applies only if binary transfert (default 8192)
		 @return : 
		   number of files transfered
		******************************************************'''
		nbput =	0
		if destdir != '' and destdir[-1:] != '/' and destdir[-1:] != '\\':
			destdir	+= '/'

		if srcdir != '' and srcdir[-1:] != '/' and srcdir[-1:] != '\\':
			srcdir	+= os.sep
		
		if mode:
			self.setmode(mode)		
		import glob
		lst	= glob.glob1(srcdir, pattern)
		for	filename in	lst:
			nbput += 1
			src = srcdir + filename
			dest = destdir + filename
			self.put(src, dest, mode, blocksize)
		return nbput
	

	def	close(self):
		''' **************************************************
		close : closes the FTP connection
		******************************************************'''
		self.ftp.close()

	def	rename (self, file1, file2):
		''' **************************************************
		rename : rename file1 to file2
		******************************************************'''
		self.ftp.rename(file1, file2)


	##
	## internal
	##
	def	getremotepatternlist(self, srcdir='',	pattern	= '*'):
		self.ftp.voidcmd('TYPE A')
		try:
			# switch directory
			if srcdir:
				self.ftp.cwd(srcdir)
			# get file list	pattern	
			FileListMatchingPattern	= self.ftp.nlst(pattern)
		except:
			FileListMatchingPattern	= []
		return FileListMatchingPattern



## Sample test
if __name__	== '__main__':
	x =	SnpsFTP('my_server', 'my_user', 'my_passwd')
	x.setmode('BINARY')
	x.setpassive(0) # Set to ACTIVE Mode
	# get some files
	x.get('/home/dummy/.profile', 'c:/temp')
	x.get('/home/dummy/.profile', 'c:/temp/.profile2')
	x.mget('/home/dummy', '*.log',	'c:/temp')
	
	# put some files
	x.put('c:/temp/drwatson.err', '/var/tmp/i_love_windows.txt')
	x.mput('c:/temp/',  'P*.xml', '/sunopsis')

	x.close()
