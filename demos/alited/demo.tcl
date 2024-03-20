#! /usr/bin/env tclsh
###########################################################
# Name:    demo.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/07/2021
# Brief:   Handles demo's data.
# License: MIT.
###########################################################

# ________________________ Demo procedure _________________________ #

proc Transpops_Make_Empty_File {args} {
  # Makes an empty file
  #   args - the file name's parts

  set fname [file join {*}$args]
  close [open $fname w]
}

proc Transpops_Demo {} {

  # alited_checked
  set TRANSPOPS_SRC /home/apl/PG/github/transpops/transpops.tcl
  source $TRANSPOPS_SRC

  set DEMODIR [file normalize /home/apl/PG/github/DEMO/alited]
  set fname transpops.txt  ;# default transpops' data file

  set CURRENTVIDEO [file join $DEMODIR _CURRENT_VIDEO_]

  set LAST 0

  # currently made video
  set video 8

  set test 0
  # test == 1 means that all video are run one by one
  # to test alited through all video scenarios
  #
  # setting to 0 makes the video of number = $video as set above
  # (i.e. when the video making may take several attempts)

  set step1 [set step2 [set step4 [set step6 [set step8 0]]]]

  if       {[set step2 [file exists $DEMODIR/STEP2]]} {
    file delete $DEMODIR/STEP2
  } elseif {[file exists $DEMODIR/STEP3]} {
    file delete $DEMODIR/STEP3
  } elseif {[set step4 [file exists $DEMODIR/STEP4]]} {
    file delete $DEMODIR/STEP4
  } elseif {[file exists $DEMODIR/STEP5]} {
    file delete $DEMODIR/STEP5
  } elseif {[set step6 [file exists $DEMODIR/STEP6]]} {
    file delete $DEMODIR/STEP6
  } elseif {[file exists $DEMODIR/STEP7]} {
    file delete $DEMODIR/STEP7
  } elseif {[set step8 [file exists $DEMODIR/STEP8]]} {
    file delete $DEMODIR/STEP8
  } else {
    set step1 1
    Transpops_Make_Empty_File $DEMODIR STEP2
    Transpops_Make_Empty_File $DEMODIR STEP3
    Transpops_Make_Empty_File $DEMODIR STEP4
    Transpops_Make_Empty_File $DEMODIR STEP5
    Transpops_Make_Empty_File $DEMODIR STEP6
    Transpops_Make_Empty_File $DEMODIR STEP7
    Transpops_Make_Empty_File $DEMODIR STEP8
  }
  set win {.alwin* .win.transpops* .dia*}

  ## ________________________ Init _________________________ ##

  if {$test} {
    if {![catch {set curvideo [glob $CURRENTVIDEO*]}]} {
      set curvideo [lindex [lsort $curvideo] end]
      set i [string last _ $curvideo]
      set video [string range $curvideo [incr i] end]
    }
  }

  ## ________________________ 1. Units _________________________ ##

  set dir 1.Units
  set fname transpops1.txt
  if {$video==1} {
    if {$step1} {
      # the very first start
    } elseif {$step2} {
      set fname transpops2.txt
    } elseif {$step4} {
      set fname transpops3.txt  ;# 3rd start
    } elseif {$step6} {
      set fname transpops4.txt  ;# 4th start
      set LAST 1
    }
  }

  ## ________________________ 2. Projects _________________________ ##

  if {$video==2} {
    set dir 2.Projects
    if {$step2} {
      set fname transpops.txt
    } elseif {$step4} {
      set fname transpops3.txt  ;# 4th start
      set LAST 2
    }
  }

  ## ________________________ 3. Find _________________________ ##

  if {$video==3} {
    if {$step2} {
      set dir 3.Find
      set fname transpops.txt
      set LAST 3
    }
  }

  ## ________________________ 4. bar-menu _________________________ ##

  if {$video==4} {
    set dir 4.bar-menu
    if {$step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step4} {
      set fname transpops2.txt  ;# 2nd start
    } elseif {$step6} {
      set fname transpops3.txt  ;# 3rd start
      set LAST 4
    }
  }

  ## ________________________ 5. Theme _________________________ ##

  if {$video==5} {
    set dir 5.Theme
    if {$step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step4} {
      set fname transpops2.txt  ;# 2nd start
    } elseif {$step6} {
      set fname transpops3.txt  ;# 3rd start
    } elseif {$step8} {
      set fname transpops4.txt  ;# 4th start
      set LAST 5
    }
  }

  ## ________________________ 6. Paver _________________________ ##

  if {$video==6} {
    if {$step2} {
      set dir 6.Paver
      set fname transpops.txt
      set LAST 6
    }
  }

  ## ________________________ 7. Little things _________________________ ##

  if {$video==7} {
    set dir 7.Little-things
    if {$step2} {
      set fname transpops.txt
    } elseif {$step4} {
      set fname transpops2.txt
      set LAST 7
    }
  }

  ## ________________________ 8. Project printer _________________________ ##

  if {$video==8} {
    set dir 8.Project-printer
    set fname transpops.txt
    set LAST 99
  }

  ## ________________________ Clear old flags, set new _________________________ ##

  if {$LAST} {
    foreach step [glob -nocomplain $DEMODIR/STEP*] {
      file delete $step
    }
    if {$test} {
      foreach video [glob -nocomplain $CURRENTVIDEO*] {
        file delete $video
      }
      if {$LAST<99} {
        Transpops_Make_Empty_File $CURRENTVIDEO[incr LAST]
      }
    }
  }

  ## ________________________ Create the current demo _________________________ ##

  set fname [file normalize [file join $DEMODIR $dir $fname]]
  if {[file exists $fname]} {
    ::transpops::run $fname $win
  }
}

# ________________________ Run demo stuff _________________________ #

catch {Transpops_Demo}

# ________________________ EOF _________________________ #
