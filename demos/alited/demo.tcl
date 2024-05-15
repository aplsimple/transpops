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

  # currently made video
  set video 8

  set step1 [set step2 [set step3 [set step4 [set step5 0]]]]

  if       {[set step2 [file exists $DEMODIR/STEP2]]} {
    if {[winfo exists .alwin]} {file delete $DEMODIR/STEP2}
  } elseif {[set step3 [file exists $DEMODIR/STEP3]]} {
    if {[winfo exists .alwin]} {file delete $DEMODIR/STEP3}
  } elseif {[set step4 [file exists $DEMODIR/STEP4]]} {
    if {[winfo exists .alwin]} {file delete $DEMODIR/STEP4}
  } elseif {[set step5 [file exists $DEMODIR/STEP5]]} {
    if {[winfo exists .alwin]} {file delete $DEMODIR/STEP5}
  } else {
    set step1 1
    Transpops_Make_Empty_File $DEMODIR STEP2
    Transpops_Make_Empty_File $DEMODIR STEP3
    Transpops_Make_Empty_File $DEMODIR STEP4
    Transpops_Make_Empty_File $DEMODIR STEP5
  }
  set win {.alwin* .win.transpops* .dia*}

  ## ________________________ 1. Units _________________________ ##

  set fname transpops.txt
  if {$video==1} {
    set dir 1.Units
    set fname transpops1.txt
    if {$step1} {
      # the very first start
    } elseif {$step2} {
      set fname transpops2.txt
    } elseif {$step3} {
      set fname transpops3.txt  ;# 3rd start
    } elseif {$step4} {
      set fname transpops4.txt  ;# 4th start
    }
  }

  ## ________________________ 2. Projects _________________________ ##

  if {$video==2} {
    set dir 2.Projects
    if {$step3} {
      set fname transpops3.txt  ;# 4th start
    }
  }

  ## ________________________ 3. Find _________________________ ##

  if {$video==3} {
    set dir 3.Find
    set LAST 1
  }

  ## ________________________ 4. bar-menu _________________________ ##

  if {$video==4} {
    set dir 4.bar-menu
    if {$step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step3} {
      set fname transpops2.txt  ;# 2nd start
    }
  }

  ## ________________________ 5. Theme _________________________ ##

  if {$video==5} {
    set dir 5.Theme
    if {$step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step3} {
      set fname transpops2.txt  ;# 2nd start
    } elseif {$step4} {
      set fname transpops3.txt  ;# 3rd start
    } elseif {$step5} {
      set fname transpops4.txt  ;# 4th start
    }
  }

  ## ________________________ 6. Paver _________________________ ##

  if {$video==6} {
    set dir 6.Paver
  }

  ## ________________________ 7. Little things _________________________ ##

  if {$video==7} {
    set dir 7.Little-things
    if {$step3} {
      set fname transpops2.txt
    }
  }

  ## ________________________ 8. Little things #2 _________________________ ##

  if {$video==8} {
    set dir 8.Little-things2
  }

  ## ________________________ 9. Misc _________________________ ##

  if {$video==9} {
    set dir 9.Misc
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
