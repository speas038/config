#################################################
## Magic Wand support
#################################################
set architecture i386:x86-64
set substitute-path /home/alex/protvm /tmp/mwpvm/protvm
set history save on


define do_break
  
  del br

  br mwsocket_create_sockinst
  br mwcomms-socket.c:1072
  
end

do_break



define rmsym
  remove-symbol-file /tmp/mwpvm/protvm/kernel/mwcomms/mwcomms.ko
end


define addsym
  if $argc == 2
    set $_bss = $arg1
  else
    set $_bss = 0
  end
  add-symbol-file /tmp/mwpvm/protvm/kernel/mwcomms/mwcomms.ko $arg0 -s .bss $_bss
  do_break
end

document addsym
  Syntax: addsym <@text> [<@bss>]
  | adds symbol file for MagicWand PVM driver
end

# Is the thread in the given list?
define rumpthread_in_list
  set $_list = $arg0
  set $_needle = $arg1
  set $_found  = 0
  set $_thr_listpriv = $_list.tqh_first
  while ( ($_found == 0) && ($_thr_listpriv != *($_list.tqh_last)) )
    if ( $_needle == $_thr_listpriv )
      set $_found = 1
    end
    set $_thr_listpriv = $_thr_listpriv.bt_schedq.tqe_next
  end
end
define rumpthread_curr
  set $_found  = 0
  set $_thr = threadq.tqh_first
  while ( ($_found == 0) && ($_thr != *(threadq.tqh_last) ) )
    if ( ($_thr.bt_flags & 8) == 8 )
      set $_found = 1
      _rumpthread_print $_thr
    end
    set $_thr = $_thr.bt_threadq.tqe_next
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
  #printf "Contents of list\n"
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
  #print "Contents of master thread list 'threadq'"
  printf "---------------------------\n"
  set $_t = threadq.tqh_first
  while ( $_t != *(threadq.tqh_last) )
    _rumpthread_print $_t
    set $_t = $_t.bt_threadq.tqe_next
  end
  printf "---------------------------\n"
end
document rumpthreads
   Syntax: rumpthreads
   | Shows all Rump threads. Run within context of scheduler's module
end

define rumpthreads_all_lists
  printf "RunQ\n"
  rumpthread_list runq
  printf "TimeQ\n"
  rumpthread_list timeq
  printf "All threads\n"
  rumpthreads
end

define rumpsetbr
  break schedule
  commands
    rumpthreads_all_lists
  end
  break rump_schedule_cpu_interlock
  break rump_unschedule_cpu_interlock
  break rumpuser_clock_sleep
  #break xe_comms_heartbeat
  #break xe_comms_read_item
  break xenevent_semaphore_down
  # Right after context switch
  break sched.c:300
end

define rumpcpu_info
  set $_cv = rcpu_storage[0].rcpu_cv
  set $_waiters = $_cv.waiters
  set $_wh = $_waiters.tqh_first
  printf "CPU 0 CV waiters ------------\n" 
  while ( $_wh != *($_waiters.tqh_last) )
    _rumpthread_print $_wh.who
    set $_wh = $_wh.entries.tqe_next
  end
end
###############################################
#################################################
## Generic support
#################################################
define replacesym
  if $argc == 2
    set $_bss = $arg1
  else
    set $_bss = 0
  end
  rmsym
  addsym $arg0 $_bss
end

document replacesym
Syntax: replacesym <@text> [<@bss>]
  | Update symbol information for module. See addsym doc
end
##
## Assorted breakpoints for finding badness in kernel code
##
define kernbp
   break *0xc0472930
   #T force_sig_info
   break *0xc0472a00
   #T force_sig
   break *0xc0473380 
   #T force_sigsegv
   break *0xc095ba02 
   #t pgtable_bad
   break *0xc095c000 
   #t mm_fault_error
   break *0xc095bfc2
   #t bad_area
   break *0xc095bfa9 
   #t bad_area_nosemaphore
   break *0xc095be53 
   #t __bad_area_nosemaphore
end
