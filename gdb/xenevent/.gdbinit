
source ~/gdb/xenevent/pretty_printers.py


define do_finish
  finish
end


define do_break

  del br

  br networking.c:721
  commands
    p peer_poll_fds
    c
  end

end



do_break


define p_req_info
  python print(gdb.selected_frame().name())
  print "Test"
  print /x Request->base.sockfd
end

define sockopt_recon
  br xe_net_sock_attrib
  commands    
    p Request->attrib
    c
  end
end

# Is the thread in the given list?
define rumpthread_in_list
  set $_list = $arg0
  set $_needle = $arg1
  set $_found  = 0
  set $_tl1 = $_list.tqh_first
  while ( ($_found == 0) && ($_tl1 != *($_list.tqh_last)) )
    if ( $_needle == $_tl1 )
      set $_found = 1
    end
    set $_tl1 = $_tl1.bt_schedq.tqe_next
  end
end

# Figures out which lists the given thread is in
define rumpthread_which_lists
  set $_needle = $arg0
  set $_lists  = "---"
  rumpthread_in_list runq $_needle
  if ( $_found > 0 )
    set $_lists[0] = 'R'
  end
  rumpthread_in_list blockq $_needle
  if ( $_found > 0 )
    set $_lists[1] = 'B'
  end
  rumpthread_in_list timeq $_needle
  if ( $_found > 0 )
    set $_lists[2] = 'T'
  end
  set $arg1 = $_lists
end

define _rumpthread_print
  rumpthread_which_lists $arg0 $lists
  set $_running = ' '
  if ( $arg0.bt_flags & 8 )
    set $_running = '*'
  end
  printf "%p: time %08x fl %x sp %08x lists %s name %s %c\n", \
      $arg0, $arg0.bt_wakeup_time, $arg0.bt_flags, $arg0.bt_tcb.btcb_sp, \
      $lists, $arg0.bt_name, $_running
end

define rumpthread_list
  set $_list = $arg0
  set $_t = $_list.tqh_first
  set $_idx = 0
  printf "Contents of list\n"
  printf "---------------------------\n"
  while ( $_t != *($_list.tqh_last) )
    printf "%02x: ", $_idx
    set $_idx = $_idx + 1
    _rumpthread_print $_t
    set $_t = $_t.bt_schedq.tqe_next
  end
  printf "---------------------------\n"
end

document rumpthread_list
   Syntax: rumpthread_list [runq|blockq|timeq]
end

define rumpthreads
  print "Contents of master thread list 'threadq'"
  set $_t = threadq.tqh_first
  while ( $_t != *(threadq.tqh_last) )
    _rumpthread_print $_t
    set $_t = $_t.bt_threadq.tqe_next
  end
end

document rumpthreads
   Syntax: rumpthreads
   | Shows all Rump threads. Run within context of scheduler's module
end

