Background to the ODI-SCM project
=================================

A living hell of multiple, unsynchronised development repositories, manual code versioning, manual (attempts at) merging between repositories, manual conflict detection, and long lost source code for Scenarios in execution-only repositories. 

That's where we started.

We were working in an Enterprise legacy situation, in a Data Warehousing team. We had issues and no existing solutions could be found.

So, we built.

We built a tool to recover our source code base for each production Scenario that we had executing: a tool to scour the landscape of repositories and identify the correct source (where it still existed).

We built tools to export source objects at the *right* level of granularity, for check in our source code control systems.

And, we established.

We established practices for isolating developers' work in order that they can control what gets exported to the SCM system.

We established tools and practices to automate integrating developers' work through the source code control system hub.

And, we tested our applications.

We've used and enhanced existing open source database test automation tools to build our test automation.

We were using ODI 10g, on Windows workstations, with Oracle repositories so that's what the solution was built for. 

It now supports ODI 11g.

It aint always pretty.

It is always pretty effective.