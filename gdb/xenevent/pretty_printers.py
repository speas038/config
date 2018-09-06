class PollfdPrinter(object):
  """Print the peer poll array for debugging."""

  def __init__(self, val):
    self.val = val

  def to_string(self):
    return ( '\n'
             '\tfd: {:0d} e: 0x{:08x} r: 0x{:08x}'
                      .format( int( self.val['fd'] ), int( self.val['events'] ), int( self.val['revents'] ) ) )

def display_hint(self):
  return 'pollfd'

import gdb.printing

pp = gdb.printing.RegexpCollectionPrettyPrinter('pollfd')
pp.add_printer('pollfd', '^pollfd$', PollfdPrinter)
gdb.printing
gdb.printing.register_pretty_printer( gdb.current_objfile(), pp, replace=True )
