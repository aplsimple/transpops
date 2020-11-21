#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The transpops package displays popup messages.
# The messages are read from a file and after pressing a hotkey are
# shown one by one under the mouse pointer.
#
# Scripted by Alex Plotnikov.
#
# Lisense: MIT.
# _______________________________________________________________________ #

package require Tk

package provide transpops 1.2.1

# _________________ Common data of transpops namespace __________________ #

namespace eval ::transpops {

  namespace eval my {
    variable msgs [list] imsgs 0 wmsgs ".win.transpops" omsgs ""
    variable fg #000000 bg #FBFB95
    variable alpha 0.0 alphaincr 0.1
    variable cntwait 0
    variable geom ""
  }
}
# ______________ Private procedures of transpops namespace ______________ #

proc ::transpops::my::Show {win evn} {
  # Makes the popup toplevel window and starts popups.
  #   win - parent window's path
  #   evn - index of event (2nd sets the geometry)
 
  variable geom
  variable msgs
  variable imsgs
  variable wmsgs
  variable alpha
  variable alphaincr
  variable fg
  variable bg
  set wmsgs [string trimright $win .].transpops
  catch {destroy $wmsgs}
  if {[incr imsgs]>=[llength $msgs]} return
  set msg [string map {\\n \n} [lindex $msgs $imsgs-1]]
  if {$msg eq ""} {set imsgs 99999999; return}
  toplevel $wmsgs
  wm withdraw $wmsgs
  wm overrideredirect $wmsgs 1
  label $wmsgs.l -padx 30 -pady 30 -foreground $fg -background $bg \
    -font {-weight bold -size 20 -family Quicksand} -relief solid -text $msg -justify left
  set alpha 0.0
  set alphaincr [expr {abs($alphaincr)}]
  pack $wmsgs.l -fill both -expand true
  set alpha 0.0
  set alphaincr 0.007
  bind $wmsgs <ButtonPress> {set ::transpops::my::cntwait 0}
  if {[regexp {^http[s]?://\S+$} $msg]} {
    catch {
      ::apave::paveObj makeLabelLinked $wmsgs.l \
        "::apave::openDoc $msg@@$msg@@" $fg $bg $fg yellow
    }
  }
  set x [expr {[winfo pointerx .]+10}]
  set y [expr {[winfo pointery .]+10}]
  if {$geom eq "" || $evn==2} {set geom +$x+$y}
  wm geometry $wmsgs $geom
  after 10 "wm deiconify $wmsgs; wm attributes $wmsgs -alpha 0.0 -topmost 1"
  after 10 "::transpops::my::Popup {$msg}"
}
#_____

proc ::transpops::my::Popup {msg} {
  # Popups a message in the popup window.
  #   msg - the message

  variable wmsgs
  variable alpha
  variable alphaincr
  variable cntwait
  if {![winfo exists $wmsgs]} return
  if {$cntwait>0} {
    incr cntwait -1
  } else {
    set alpha [expr {$alpha+$alphaincr}]
    if {$alpha>1.0} {
      set cntwait [expr {int(max(2,[string length $msg]/12.)/$alphaincr)}]
      set alphaincr [expr {-$alphaincr}]
      set alpha 1.0
    } elseif {$alpha<0.0} {
      catch {destroy $wmsgs}
      return
    }
    catch {wm attributes $wmsgs -alpha $alpha}
  }
  after 10 "::transpops::my::Popup {$msg}"
}

# _____________ Interface procedures of transpops namespace _____________ #

proc ::transpops::run {fname events win {fg1 #000000} {bg1 #FBFB95}} {
  # Initializes and runs the popup messages.
  #   fname - name of file containing the messages
  #   events - events bound to the window to run popups
  #   win - the window's path
  #   fg1 - foreground of popups
  #   bg1 - background of popups

  set ::transpops::my::fg $fg1
  set ::transpops::my::bg $bg1
  set chan [open $fname]
  chan configure $chan -encoding utf-8
  set ::transpops::my::msgs [split [read $chan] \n]
  close $chan
  set ::transpops::my::imsgs 0
  foreach ev $events {
    bind $win $ev [list ::transpops::my::Show $win [incr evnnn]]
  }
}
# _________________________________ EOF _________________________________ #
if {[info exist ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
  pack [label .l -text "Press Ctrl+q" -padx 50 -pady 70]
  lassign $::argv fname hotk win
  if {$fname eq ""} {set fname ./.bak/transpops.txt}
  if {$hotk eq ""} {set hotk <Control-q>}
  if {$win eq ""} {set win .}
  ::transpops::run $fname $hotk $win
}
