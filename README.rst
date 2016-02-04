:desc: source control for Oracle's ETL tool

ODI-SCM
=======

`Oracle Data Integrator (ODI) <http://www.oracle.com/technetwork/middleware/data-integrator/overview/index.html>`_
is a ETL tool used in many enterprises to help manage data warehouses and similar large data sets.

We discovered that a fundamental difficulty in working with ODI amongst multiple development teams was
that the source code for one ETL transaction is not stored as text in a IDE, but as chunks of text in different database tables.

This meant that every assumption about Agile development methodologies working with ODI is......broken.

However we have developed a solution to bi-directionally output the entire source code of an ODI repository
in and out of a traditional SCM, and do so at a granualrity of a "script" - thus changes to a single script
in one teamn can be safely merged with others and only where teams truly are in conflict will a merge conflict be raised.

In short - Agile with ODI is now possible, source control with ODI is now possible

Further Reading
---------------

Read the docs at: -

	http://odietamo.readthedocs.org

