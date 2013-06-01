#!/usr/bin/env python
#! -*- coding: utf-8 -*-

###
# Copyright (c) Rice University 2012-13
# This software is subject to
# the provisions of the GNU Affero General
# Public License version 3 (AGPLv3).
# See LICENCE.txt for details.
###


'''Configuration services to be used commonly across Rhaptos2
----------------------------------------------------------

This has been pared down to the simplest possible solution.
an ini file -> a dict.

It is simplified to this extent as nosetest.test_config will generate such a
dict, and it is by far simpler to have the same dict passed around in live and
test than to do any trickery or fixes.



::

  from rhaptos2.repo import conf
  confd = conf.get_config("/ini/file/path")

We now have a python dict, named confd, holding all the namesapced
configuration variables available in the "environment"

it would look like ::

  {
   'bamboo':
       {'www_host_name':"www.cnx.org",},
   'rhaptos2repo':
       {'flag': "RedWhiteBlue"}
  }



>>> x = """[test]
... foo=1
...
... [test2]
... bar=1
... """
>>> open("/tmp/foo.ini", "w").write(x)
>>> d = get_config(ini_file_path="/tmp/foo.ini")
>>> expected = {'test': {'foo': '1'}, 'test2': {'bar': '1'}}
>>> assert d == expected

'''


import os
import ConfigParser
import types

class ConfigError(Exception):
    pass

def get_config(ini_file_path=None):
    """
    Expect a .ini file at path location, parse and return dict

    """
    confd = {}
    if not os.path.isfile(ini_file_path):
        raise ConfigError("%s is not found" % ini_file_path)
    try:
        d = read_ini(ini_file_path)
        confd.update(d)
    except ConfigError, e:
        pass
    return confd


def read_ini(filepath):

    d = {}
    parser = ConfigParser.SafeConfigParser()
    parser.optionxform = str  # case sensitive
    try:
        parser.read(filepath)
    except Exception, e:
        raise ConfigError(
            'Could not find or could not process: %s - %s' % (filepath, e))

    ## convert ini file to a dict of dicts
    for sect in parser.sections():
        d[sect] = dict(parser.items(sect))

    return d


if __name__ == '__main__':
    import doctest
    doctest.testmod(verbose=False)
