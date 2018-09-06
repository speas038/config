import gdb


def offsetof( mytype, myfield ):
    v = gdb.parse_and_eval( "(int) &((%s *)0)->%s" % (mytype, myfield) )
    return int(v)


class DrawbridgeDumpMem( gdb.Command ):
    "Show the memory user tracked by the drawbridge driver."

    def __init__( self ):
        super (DrawbridgeDumpMem, self).__init__ ("dbmemdump",
                         gdb.COMMAND_SUPPORT,
                         gdb.COMPLETE_NONE, True)

    def invoke( self, *args ):
        domstate = gdb.parse_and_eval( "g_mwsocket_state" ) 
        pp_head = domstate["sockinst_list"]
        pp_curr = pp_head["next"]
        dirty_ct = 0

        print( "sockinst_list = ", domstate["sockinst_list"] )
        print( "pp_head = ", pp_head )
        print( "pp_cur = ", pp_curr )
        
        print( "sockinst_count:", domstate["sockinst_count"]["counter"])   

        while pp_curr != pp_head.address:

            offset = offsetof( "mwsocket_instance_t", "list_all" )
            pp_basea = int(pp_curr) - offset

#      print( "0xffff88003cb270b8 - 0xffff88003cb270b7 = {0:x}".format( 0xffff88003cb270b8 - 0xffff88003cb270b7 ) )

#      print( int( hex( offset ), 16 ) )
#      print( pp_curr, " - ", offset , " = ", pp_basea )
#      print( int( pp_curr ), " - ", offset, " = ", int( pp_basea ) )

        pp_struct = gdb.parse_and_eval( "(mwsocket_instance_t *) %s" % pp_basea )

        print( "remote_fd: {:x}".format( int( pp_struct["remote_fd"] ) ), 
            " local_fd: ", pp_struct["local_fd"] )

        pp_curr = pp_curr['next'] 
#      print( "Total dirty: 0x{0:x} ({0})".format( dirty_ct ) )

DrawbridgeDumpMem()


class ListPrintCommand(gdb.Command):
    """Iterate and print a list.

list-print <EXPR> [MAX]

Given a list EXPR, iterate though the list nodes' ->next pointers, printing
each node iterated. We will iterate thorugh MAX list nodes, to prevent
infinite loops with corrupt lists. If MAX is zero, we will iterate the
entire list.

List nodes types are expected to have a member named "next". List types
may be the same as node types, or a separate type with an explicit
head node, called "head"."""

    MAX_ITER = 20

    def __init__(self):
        super(ListPrintCommand, self).__init__("list-print",
                gdb.COMMAND_DATA, gdb.COMPLETE_SYMBOL)

    def invoke(self, argument, from_tty):
        args = gdb.string_to_argv(argument)
        if len(args) == 0:
            print( "Argument required (list to iterate)" )
            return

        expr = args[0]

        if len(args) == 2:
            max_iter = int(args[1])
        else:
            max_iter = self.MAX_ITER

        list = gdb.parse_and_eval(expr)

        fnames = [ f.name for f in list.type.fields() ]

        # handle lists with a separate list type....
        if 'head' in fnames:
            head = list['head']

        # ...and those with the head as a regular node
        elif 'next' in fnames:
            head = list

        else:
            print( "Unknown list head type" )
            return

        # if the type has a 'prev' member, we check for validity as we walk
        # the list
        check_prev = 'prev' in [ f.name for f in head.type.fields() ]

        print( "list@%s: %s" % (head.address, head) )
        node = head['next']
        prev = head.address
        i = 1

        while node != head.address:
            print( "node@%s: %s #%d" % (node, node.dereference(), i) )

            if check_prev and prev != node['prev']:
                    print( " - invalid prev pointer!" )

            if i == max_iter:
                print( " ... (max iterations reached)" )
                break

            prev = node
            node = node['next']
            i += 1

        if check_prev and i != max_iter and head['prev'] != prev:
            print( "list has invalid prev pointer!" )

ListPrintCommand()
