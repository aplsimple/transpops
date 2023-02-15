#! /usr/bin/env tclsh
###########################################################
# Name:    demo.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/07/2021
# Brief:   Handles demo's data.
# License: MIT.
###########################################################

# ________________________ Demo procedure _________________________ #

proc TRANSPOPS_DEMO {} {

  set TRANSPOPS_SRC [file normalize ~/PG/github/transpops/transpops.tcl]
  source $TRANSPOPS_SRC

  set DEMODIR [file normalize ~/PG/github/DEMO/alited]
  set fname transpops.txt  ;# default transpops' data file
  set win .alwin

  set step1 [set step2 [set step3 [set step4 [set step5 [set step6 0]]]]]
  if       {[set step2 [file exists $DEMODIR/STEP2]]} {
    file delete $DEMODIR/STEP2
  } elseif {[set step3 [file exists $DEMODIR/STEP3]]} {
    file delete $DEMODIR/STEP3
  } elseif {[set step4 [file exists $DEMODIR/STEP4]]} {
    file delete $DEMODIR/STEP4
  } elseif {[set step5 [file exists $DEMODIR/STEP5]]} {
    file delete $DEMODIR/STEP5
  } elseif {[set step6 [file exists $DEMODIR/STEP6]]} {
    file delete $DEMODIR/STEP6
  } elseif {[set step7 [file exists $DEMODIR/STEP7]]} {
    file delete $DEMODIR/STEP7
  } elseif {[set step8 [file exists $DEMODIR/STEP8]]} {
    file delete $DEMODIR/STEP8
  } else {
    set step1 1
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP2
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP3
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP4
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP5
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP6
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP7
    file copy -force $TRANSPOPS_SRC $DEMODIR/STEP8
  }

  ## ________________________ 1. Start _________________________ ##

  if 0 {
    set dir 1.Start
    if {$step1} {
      set fname transpops0.txt  ;# the very first start
      set win {.diaalitedObjToDel1 .alwin}
    } elseif {$step2} {
      set fname transpops1.txt  ;# after creation of ./config/alited
      set win {.alwin.diaPref .alwin}
    } elseif {$step4} {
      set fname transpops2.txt ;# at restart with new settings
    } else {
      set fname transpops3.txt ;# just to welcome
    }
  }

  ## ________________________ 2. Units _________________________ ##

  if 0 {
    set dir 2.Units
  }

  ## ________________________ 3. Projects _________________________ ##

  if 1 {
    set dir 3.Projects
    set win {.alwin.diaPrj .alwin.diaPref .alwin}
  }

  ## ________________________ 4. Find _________________________ ##

  if 0 {
    set dir 4.Find
    set win {.alwin.diaPref .alwin.winFind .alwin}
  }

  ## ________________________ 5. bar-menu _________________________ ##

  if 0 {
    set dir 5.bar-menu
    set win {.alwin.diaPref .alwin}
    if {$step1 || $step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step4} {
      set fname transpops2.txt  ;# 2nd start
    } else {
      set fname transpops3.txt  ;# 3rd start
    }
  }

  ## ________________________ 6. Theme _________________________ ##

  if 0 {
    set dir 6.Theme
    set win {.alwin.diaPref .alwin.winFind .alwin.diaPrj .alwin}
    if {$step1 || $step2} {
      set fname transpops1.txt  ;# 1st start
    } elseif {$step4} {
      set fname transpops2.txt  ;# 2nd start
    } elseif {$step6} {
      set fname transpops3.txt  ;# 3rd start
    } else {
      set fname transpops4.txt  ;# 4th start
    }
  }

  if {[file exists [set fname [file normalize [file join $DEMODIR $dir $fname]]]]} {
    #set ::transpops::my::perchars 1.0 ;# for popups to be 12 times longer
    ::transpops::run $fname $win
  }

}

catch {TRANSPOPS_DEMO}

#RUNF1: ../../alited/src/alited.tcl DEBUG
# ~/.config2
