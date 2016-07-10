ODI-SCM
=======

`Oracle Data Integrator (ODI) <http://www.oracle.com/technetwork/middleware/data-integrator/overview/index.html>`_
is an ETL tool used in many enterprises to help manage data integration, data warehouses and similar large data sets.

We discovered that a fundamental difficulty in working with ODI, amongst multiple development teams, was
that the source code for ODI is not stored as text in a IDE, but as metadata distributed across a large number of ODI repository database tables.

This meant that every assumption about Agile development methodologies working with ODI is......broken.

However we have developed a solution to bi-directionally output the entire source code of an ODI repository
in and out of a traditional SCM, and do so at a granualrity of an object (ODI Interface, Procedure, Package, DataStore, Model, Variable, you name it...) - thus changes to a single object
in one team can be safely merged with others and only where teams truly are in conflict will a merge conflict be raised.

But we didn't just stop there. We added support for the following:-

* Database environment tear-down and set-up (DDL, stored code units, DML script execution - e.g. reference data set-up).
* Command-line integration with Continuous Integration tools (Hudon, Jenkins, etc).
* Utilisation of open source test automation tools (FitNesse/DbFit).

Further reading - read the docs at: - http://odietamo.readthedocs.org

In short, source control, Agile, and Continuous Integration with ODI is now possible!

But, wait, there's even more...

MSBI-CI
=======

Having seen great success in improving efficiency and quality in ODI-related projects we've taken our approach to the MSBI stack.

Support added so far:

* Automated execution of SSIS packages (during CI builds) or in dev/test/prod environments.
* Automated deployment of SSAS databases (dimensions and cubes) (during CI builds) or in dev/test/prod environments.
* Automated processing of SSAS databases (dimensions and cubes) (during CI builds) or in dev/test/prod environments.
* Automated deployment of SSIS packages (during CI builds) or to dev/test/prod environments.

Coming soon:

* Automated configuration of SSIS packages (during CI builds) or to dev/test/prod environments.
