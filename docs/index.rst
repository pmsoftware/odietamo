Welcome to the ODI-SCM documentation!
=====================================

Welcome to ODI-SCM.

Oracle Data Integrator (ODI) is Oracle's premier data integration/ETL/ELT tool.

The source code is stored as data in the ODI repository and cannot be (easily) extracted out and stored in a modern source control tool.

As such the world of modern development processes and practices (DevOps) is closed to projects and developers using this tool - unless one can develop software that will extract the code and put it into source control.

We do that.

And we do more. 

In fact, using our tools, we do Continuous Integration.

And so can you!

Welcome to ODI-SCM.

Features At A Glance
--------------------
* Integrates with Continuous Integration servers. E.g. Hudson / Jenkins.
* Oracle Data Integrator Source Control & Build System

  * Automated export of ODI objects for check-in to the SCM system.
  * Support for Apache Subversion and Microsoft Team Foundation (TFS) SCM systems.
  * Automated import of ODI object source code from the SCM system to the ODI repository.
  * Full or Incremental ODI repository builds from the SCM system.
  * Full ODI repository builds from an existing working copy.
  * Automated generation of Scenarios.
  * Automated execution of FitNesse (e.g. DbFit) tests after building the ODI repository.
  * High performance object source code imports through object batching.
  
* Database Schema Build System

  * Automated database schema tear-down.
  * Automated database schema set-up from DDL scripts from the SCM system.
  * Automated database DML script execution of DML scripts from the SCM system.

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
   references
   
Internal Notes
--------------
.. toctree::
   :maxdepth: 1

   how-to-write-docs
