Welcome to the ODI-SCM documentation!
=====================================

Welcome to ODI-SCM.

Oracle Data Integrator (ODI) is Oracle's premier data integration/ETL/ELT tool.

The source code is stored as data in the ODI repository and cannot be (easily) extracted out and stored in a modern source control tool.

As such the world of modern development processes and practises (DevOps) is closed to projects and developers using this tool - unless one can develop software that 
will extract the code and put it into source control.

We do just that.

Welcome to ODI-SCM.

Features At A Glance
--------------------

* Automated export of ODI object for check-in to the SCM system.
* Support for Apache Subversion and Microsoft Team Foundation (TFS) SCM systems.
* Automated import of ODI object source code from the SCM system to the ODI repository.
* Full or Incremental ODI repository builds from the SCM system.
* Full ODI repository builds from an existing working copy.
* Automated generation of Scenarios.
* High performance object source code imports through object batching.
* Integrates with Continuous Integration servers. E.g. Hudson / Jenkins.

Contents
--------
.. toctree::
   :maxdepth: 1
   :numbered:
   
   project-background
   odiscm-installation
   odiscm-demonstrations
   odiscm-working-practices
   odiscm-technical-manual
   bugs-enhancement-suggestions
   contributing
   roadmap
   
Internal Notes
--------------
.. toctree::
   :maxdepth: 1

   how-to-write-docs
