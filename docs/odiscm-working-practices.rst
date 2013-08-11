Recommended Working Practices for using ODI-SCM
===============================================

More on this soon. But here are some highlights right now.

One developer, One ODI repository
---------------------------------

Each developer has their *own* copy of *all* of the ODI code.

Each developer controls imports, from the SCM system, into their *own* ODI environment.

Each developer controls exports of their *own* code, from their *own* ODI environemnt, to their *own* SCM system working copy.

Each developer checks their *own* code additions/changes into the SCM system.

Keep It Simple, Sunshine
------------------------

Keep code units small.

Small code units can be unit tested easily.

Small code units lead to less conflicts.

Integrate Code Early and Often
------------------------------

Let other developers build on finished code as soon as it's finished.

Don't surprise other developers with your breaking changes late in the day!