#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The transpops package displays popup messages.
# The messages are read from a file and (after pressing a hotkey) are
# shown one by one under the mouse pointer.
#
# Scripted by Alex Plotnikov.
#
# License: MIT.
# _______________________________________________________________________ #

package require Tk

package provide transpops 2.3

source [file join [file dirname [info script]] drawscreen2.tcl]

# _________________ Data of transpops namespace __________________ #

namespace eval ::transpops {

  namespace eval my {
    variable msgs [list] text {} imsgs 0 wmsgs .win.transpops omsgs {}
    variable wtxt $wmsgs.labtrans
    variable fg #000000 bg #FBFB95
    variable alpha 0.0 alphaincr 0.1
    variable cntwait 0 waitfactor 8.0
    variable geom {}
    variable draw
    array set draw {
      events {}
      opts {}
      app no
    }
    variable textTags [list \
      [list "r" "-foreground #930000"] \
      [list "b" "-foreground #004080"] \
      [list "g" "-foreground #005700"] \
      [list "link" "::apave::openDoc %t@@https://%l@@"] \
    ]
  }
}
# ______________ Private procedures of transpops namespace ______________ #

proc ::transpops::my::OptionVar {tag} {
  # Name of variable for transpops options.
  #   tag - options' tag (common name or message's index)

  return "::transpops::my::_TP_OPTIONS_$tag"
}

proc ::transpops::my::Show {win evn} {
  # Makes the popup toplevel window and starts popups.
  #   win - parent window's path
  #   evn - index of event (2nd sets the geometry)

  variable geom
  variable text
  variable textTags
  variable msgs
  variable imsgs
  variable wmsgs
  variable wtxt
  variable alpha
  variable alphaincr
  variable cntwait
  variable fg
  variable bg
  if {![winfo exists $win]} return
  set fS red
  set wmsgs [string trimright $win .].transpops
  set wtxt $wmsgs.labtrans
  catch {destroy $wtxt}
  catch {destroy $wmsgs}
  while {1} {
    if {[incr imsgs]>[llength $msgs]} return
    set msg [string trim [lindex $msgs $imsgs-1]]
    if {$msg ne {}} break
  }
  set rows 0
  set cols 10
  set text {}
  foreach row [split $msg \n] {
    set row [string trim $row]
    append text $row \n
    set row [string map [list <link> {} </link> {}] $row]
    foreach c [split rbgABCDEFGHIJKLMNOPRSTUVWXYZ {}] {
      set row [string map [list <$c> {} </$c> {}] $row]
    }
    if {[set c [string length $row]]>$cols} {set cols $c}
    incr rows
  }
  catch {
    # when used within apave theme, disable theming transpops
    ::apave::obj untouchWidgets *.transpops*
  }
  toplevel $wmsgs
  wm withdraw $wmsgs
  wm overrideredirect $wmsgs 1
  wm attributes $wmsgs -topmost yes
  set varOPTS [OptionVar $imsgs]
  if {[info exists $varOPTS]} {
    set opts [set $varOPTS]
  } else {
    set opts {}
  }
  set font {-weight bold -size 16 -family Mono}
  if {[catch {
    set text [string trim $text]
    text $wtxt -padx 30 -pady 30 -foreground $fg -background $bg \
      -font $font \
      -relief solid {*}$opts -width $cols -height $rows -state disabled
    pack $wtxt
    ::apave::obj initLinkFont -underline 1 {*}$font -foreground $fg -background $bg
    ::apave::obj displayTaggedText $wtxt ::transpops::my::text $textTags
  } e]} then {
    catch {destroy $wtxt}
    label $wtxt -padx 30 -pady 30 -foreground $fg -background $bg \
      -font $font \
      -relief solid -text $msg -justify left {*}$opts
    pack $wtxt -fill both -expand true
  }
  set alpha 0.0
  set alphaincr [expr {abs($alphaincr)}]
  set alpha 0.0
  set alphaincr 0.007
  set cntwait 0
  bind $wtxt <ButtonPress-1> {set ::transpops::my::cntwait 0; break}
  if {[regexp {^http[s]?://\S+$} $msg]} {
    catch {
      ::apave::obj makeLabelLinked $wtxt \
        "::apave::openDoc $msg@@$msg@@" $fg $bg $fg yellow
    }
  }
  set x [expr {[winfo pointerx $win]+10}]
  set y [expr {[winfo pointery $win]+10}]
  if {$geom eq {} || $evn==2} {set geom +$x+$y}
  wm geometry $wmsgs $geom
  after 10 "wm deiconify $wmsgs; wm attributes $wmsgs -alpha 0.0 -topmost 1"
  after 15 "::transpops::my::Popup {$msg}"
}
#_______________________

proc ::transpops::my::Popup {msg} {
  # Popups a message in the popup window.
  #   msg - the message

  variable wmsgs
  variable wtxt
  variable alpha
  variable alphaincr
  variable cntwait
  variable waitfactor
  if {![winfo exists $wmsgs]} return
  if {$cntwait>0} {
    incr cntwait -1
  } else {
    set alpha [expr {$alpha+$alphaincr}]
    if {$alpha>1.0} {
      set cntwait [expr {int(max(2,[string length $msg]/$waitfactor)/$alphaincr)}]
      set alphaincr [expr {-$alphaincr}]
      set alpha 1.0
    } elseif {$alpha<0.0} {
      catch {destroy $wtxt}
      catch {destroy $wmsgs}
      return
    }
    catch {wm attributes $wmsgs -alpha $alpha}
  }
  after 10 "::transpops::my::Popup {$msg}"
}
#_______________________

proc ::transpops::my::RunMe {win ev scrp} {
  # Binds an event on a window to a script.
  #   win - the window's path
  #   ev - event on the window
  #   scrp - the bound script
  # The binding is made only on an existing window.
  # The windows may be created and destroyed, so Run watches if they are available.

  variable draw
  set w $win
  catch {
    # the window's path may be a glob pattern - compare the current toplevel to it
    set wfoc [winfo toplevel [focus]]
    if {[string match $w $wfoc]} {set w $wfoc}
  }
  if {[winfo exists $w]} {
    set sc "[string map [list %w $w] $scrp] ; break"
    if {![string match <*> $ev]} {set ev <$ev>}
    if {[string first $sc [bind $w $ev]]==-1} {
      bind $w $ev $sc
    }
    catch {::drawscreen run $w $draw(events) {*}$draw(opts)}
  }
  after 500 [list ::transpops::my::RunMe $win $ev $scrp]
}
#_______________________

proc ::transpops::my::Run {fname wins {events ""} {fg1 ""} {bg1 ""} {events2 ""} args} {
  # Initializes and runs the popup messages.
  #   fname - name of file containing the messages
  #   events - events on the window to run bound popups
  #   wins - the list of parent window pathes
  #   fg1 - foreground of popups
  #   bg1 - background of popups
  #   events2 - events to start drawing
  #   args -  options of *drawscreen*

  variable draw
  variable msgs
  variable imsgs
  variable fg
  variable bg
  variable textTags
  if {$events eq {}} {set events {{Alt-t Alt-T} {Alt-y Alt-Y}}}
  if {$fg1 eq {}} {set fg1 #000000}
  if {$bg1 eq {}} {set bg1 #FBFB95}
  set fg $fg1
  set bg $bg1
  set chan [open $fname]
  chan configure $chan -encoding utf-8
  set msgs [list]
  set merge no
  foreach line [split [read $chan] \n] {
    # skip comments
    if {[string index $line 0] eq {#}} {
      # comments may be valuable
      set line [string trim [string range $line 1 end]]
      set ov [split $line]
      lassign $ov o v
      if {[string match TRANSPOP* $o]} {
        # set/use options of transpops
        # e.g.
        #   # TRANSPOPred -foreground #000 -background red
        #   # TRANSPOP2   -foreground #fff -background black
        # then using them:
        #   # TRANSPOP2
        #   # TRANSPOPred
        # also to set tags r, b, g:
        #   TRANSPOP TAG b -font {-weight bold -size 20 -family Mono} -foreground red
        # and using:
        #   this is <b>bolded text</b>
        if {[string match {TRANSPOP TAG *} $line]} {
          set nam [lindex $line 2]
          set tag [list $nam [lrange $line 3 end]]
          if {[set i [lsearch -exact -index 0 $textTags $nam]]>-1} {
            set textTags [lreplace $textTags $i $i $tag]
          } else {
            lappend textTags $tag
          }
          continue
        }
        set varOPTS [OptionVar $o]
        if {$v ne {}} {
          # setting options
          set $varOPTS [lrange $ov 1 end]
        } elseif {[info exists $varOPTS]} {
          # using options
          set llen [llength $msgs]
          if {!$merge} {incr llen}
          set [OptionVar $llen] [set $varOPTS]
        }
      }
      continue
    }
    # if it's a list of items, mark them accordingly
    if {[regexp {^\s*[*]\s+} $line]} {
      set i [string first * $line]
      set line [string range $line 0 $i-1]\u2022[string range $line $i+1 end]
    }
    # if line has "\\" at its end, it continues a message
    set line2 [string map {{ } {} - {} + {} / {} \\ {} * {} = {}} $line]
    set continued [expr {$line2 ne {} || $line eq {}}]
    if {$continued} {
      if {$merge} {
        set last [lindex $msgs end]
        append last \n $line
        set msgs [lreplace $msgs end end $last]
      } else {
        lappend msgs $line
      }
    }
    set merge $continued
  }
  close $chan
  set imsgs 0
  set timo 300
  set draw(events) $events2
  set draw(opts) $args
  foreach w $wins {
    set ei 0
    foreach event2 $events {
      incr ei
      foreach ev $event2 {  ;# for {Alt-t Alt-T} etc.
        after $timo [list ::transpops::my::RunMe $w $ev [list ::transpops::my::Show %w $ei]]
      }
    }
    if {$draw(app)} {bind $w <Escape> exit}
  }
}

# _____________ Interface procedures of transpops namespace _____________ #

proc ::transpops::run {args} {
  # Runs my::Run and catches errors. Logs errors to a log file.
  #   args - arguments of my::Run.

  if {[catch {my::Run {*}$args} err]} {
    catch {
      set ch [open /home/apl/TMP/transpops.log a]
      puts $ch $err
      close $ch
    }
  }
}

# ________________________ main _________________________ #

if {[info exist ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
  lassign $::argv fname hotk fg1 bg1 hotk2 o1 v1 o2 v2 o3 v3 o4 v4
  if {$fname eq {}} {set fname [file normalize ./.bak/transpops.txt]}
  if {$hotk eq {}} {set hotk {{Alt-t Alt-T} {Alt-y Alt-Y}}}
  if {$hotk2 eq {}} {set hotk2 {Control-x Control-X}}
  set hk [string map [list < {} > {} { } {, }] $hotk]
  set hk2 [string map [list < {} > {} { } {, }] $hotk2]
  label .labinfo -text \
    "Press $hk.\n\nPress $hk2, then\ndrag-n-drop... or\nright/double click."
  pack .labinfo -padx 50 -pady 50
  set ::transpops::my::draw(app) yes
  ::transpops::run $fname . $hotk $fg1 $bg1 $hotk2 $o1 $v1 $o2 $v2 $o3 $v3 $o4 $v4
}

# _________________________________ EOF _________________________________ #
