Notes on documenting the project
================================

I am using the Python based project `Sphinx <http://sphinx.pococo.org>`_ for creating
decent documentation from text files.  This way we can store the docs, as plain text
in the repo alongside the code it refers to, keeping the docs more uptodate than expected.

We are aiming for simple useage here.

Quick version
-------------

* Install Python
* run `pip install sphinx`

::

   $ cd c:\src\odietamo\docs
   $ make.bat html
   $ start _build\html

Thats it.

Installation
------------

Let us assume we are on a clean Windows box.
We shall install the standard Python Windows distribution - download from
`Activestate <http://www.activestate.com/activepython/downloads>`_

Once that is installed we need to install the `Sphinx <http://sphinx.pococo.org>`_
code ::

    $ pip install sphinx

If you do not have pip on your box, errr, call me its a bit like open the box using the
crowbar inside the box.

If you have to negotiate a web proxy server to download the Sphinx package, try this version of the command ::

    $ pip install sphinx --proxy=[<user>:<pass>@]<server>:<port>

Note that the user name and password are only required when using authenticated proxy servers.

Using easy_install
~~~~~~~~~~~~~~~~~~

An alternate way of install Sphinx can be found on this web page ::

    http://sphinx-doc.org/latest/install.html#windows-install-python-and-sphinx

First use
---------

We now should be able to do ::

   $ mkdir c:/src/foo
   $ mkdir c:/src/foo/docs
   $ cd c:/src/foo/docs
   $ sphinx-quickstart

At this point we are running the sphinx startup program.  This will initialise any folder,
with the right layout for sphinx.  It asks you some simple questions, and you will only need to answer
default, or really obvious stuff like your name.

::
   C:\Users\pbrian\foo\docs>sphinx-quickstart
   Welcome to the Sphinx 1.2b1 quickstart utility.

   Please enter values for the following settings (just press Enter to
   accept a default value, if one is given in brackets).

   Enter the root path for documentation.
   > Root path for the documentation [.]:

   You have two options for placing the build directory for Sphinx output.
   Either, you use a directory "_build" within the root path, or you separate
   "source" and "build" directories within the root path.
   > Separate source and build directories (y/N) [n]:

   Inside the root directory, two more directories will be created; "_templates"
   for custom HTML templates and "_static" for custom stylesheets and other static
   files. You can enter another prefix (such as ".") to replace the underscore.
   > Name prefix for templates and static dir [_]:

   The project name will occur in several places in the built documentation.
   > Project name: Foo
   > Author name(s): Paul Brian

   Sphinx has the notion of a "version" and a "release" for the
   software. Each version can have multiple releases. For example, for
   Python the version is something like 2.5 or 3.0, while the release is
   something like 2.5.1 or 3.0a1.  If you don't need this dual structure,
   just set both to the same value.
   > Project version: 0.0.1
   > Project release [0.0.1]:

   The file name suffix for source files. Commonly, this is either ".txt"
   or ".rst".  Only files with this suffix are considered documents.
   > Source file suffix [.rst]:

   One document is special in that it is considered the top node of the
   "contents tree", that is, it is the root of the hierarchical structure
   of the documents. Normally, this is "index", but if your "index"
   document is a custom template, you can also set this to another filename.
   > Name of your master document (without suffix) [index]:

   Sphinx can also add configuration for epub output:
   > Do you want to use the epub builder (y/N) [n]:

   Please indicate if you want to use one of the following Sphinx extensions:
   > autodoc: automatically insert docstrings from modules (y/N) [n]:
   > doctest: automatically test code snippets in doctest blocks (y/N) [n]:
   > intersphinx: link between Sphinx documentation of different projects (y/N) [n]
   :
   > todo: write "todo" entries that can be shown or hidden on build (y/N) [n]:
   > coverage: checks for documentation coverage (y/N) [n]:
   > pngmath: include math, rendered as PNG images (y/N) [n]:
   > mathjax: include math, rendered in the browser by MathJax (y/N) [n]:
   > ifconfig: conditional inclusion of content based on config values (y/N) [n]:
   > viewcode: include links to the source code of documented Python objects (y/N)
   [n]:

   A Makefile and a Windows command file can be generated for you so that you
   only have to run e.g. `make html' instead of invoking sphinx-build
   directly.
   > Create Makefile? (Y/n) [y]:
   > Create Windows command file? (Y/n) [y]:

   Creating file .\conf.py.
   Creating file .\index.rst.
   Creating file .\Makefile.
   Creating file .\make.bat.

   Finished: An initial directory structure has been created.

   You should now populate your master file .\index.rst and create other documentat
   ion
   source files. Use the Makefile to build the docs, like so:
      make builder
   where "builder" is one of the supported builders, e.g. html, latex or linkcheck.

OK, we now have a directory structure like::

   C:\Users\pbrian\foo\docs>ls
   Makefile    _static     conf.py     make.bat
   _build      _templates  index.rst

We only need to worry about two things:

1. index.rst
2. make.bat

Here is the layout of index.rst, with some crud at the top and bottom removed.::

   Welcome to Foo's documentation!
   ===============================

   Contents:

   .. toctree::
      :maxdepth: 2

We shall expand this a little bit::

   $ mkdir foobar
   $ notepad foobar/whatIdidlastsummer.rst

It is convenient to have the index.rst file as the only thing in docs/ and to put all the real docs in
foobar, for convenience.

We now write some docs in ``foobar/whatIdidlastsummer.rst``::

   Last Summer
   ===========

   Underlineing the above will make it an H1. This paragrpah will be quite normal
   and then these will be bullet points

   * Sunbathed
   * Wrote code
   * Slept

   Another paragraph here.

Now we need to tell the index about the page we have just written::
   
   Welcome to Foo's documentation!
   ===============================

   Contents:

   .. toctree::
      :maxdepth: 2

      foobar/whatIdidlastsummer

Making HTML
-----------

We are nearly there::

   $ make.bat html
   ... lots of messages
   $ start _build\html

And then click on index.html

Hey - we have documentation.

How to run this for odietamo::

   $ cd c:\OdiScm\odietamo\docs
   $ make.bat html
   $ start _build\html

Thats it.