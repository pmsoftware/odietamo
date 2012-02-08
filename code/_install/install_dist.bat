REM Install the ODI-SVN components
REM this is primarily a placeholder for a future improved version

set destfolder=$1

unzip odietamo.0.9.0.zip %destfolder%
cd %destfolder%\install
python setup.py install

