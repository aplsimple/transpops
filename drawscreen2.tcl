#! /usr/bin/env tclsh
###########################################################
# Name:    drawscreen2.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    02/11/2023
# Brief:   Handles drawing on the screen.
# License: MIT.
###########################################################

package require Tk

# ________________________ Data of drawscreen _________________________ #

namespace eval ::drawscreen {

  namespace export run cget configure
  namespace ensemble create

  namespace eval my {
    variable windraw wDrwScr_
    variable draw
    array set draw {
      width 5
      fill red
      length 6
      dobell yes
      started no
      X 0 Y 0
    }
  }
}

# ________________________ Private procedures _________________________ #

proc ::drawscreen::my::Binding {wins events {com -}} {
  # Sets the bindings and options to start drawing.
  #   wins - the list of parent window pathes
  #   events - events to start drawing
  #   com - command to bind

  variable draw
  if {$events eq {}} {set events {<Control-q> <Control-Q>}}
  foreach w $wins {
    if {$com eq {-}} {set com "::drawscreen::my::Drawing $w ; break"}
    ::drawscreen::my::Bind $w $events $com
  }
}
#_______________________

proc ::drawscreen::my::Bind {w events com} {
  # Binds drawing events on a window to Drawing proc.
  #   w - the window's path
  #   events - list of events to start drawing
  #   com - command to bind (or {} to unbind)

  variable draw
  if {[winfo exists $w]} {
    foreach ev $events {
      if {$com eq {}} {
        bind $w $ev $com  ;# unbind at errors
      } elseif {[string first $com [bind $w $ev]]==-1} {
        if {![string match <*> $ev]} {set ev <$ev>}
        bind $w $ev $com
      }
    }
  }
  if {$com ne {}} {
    # as windows may be created and destroyed,
    # do check periodically if they are available
    set com [list ::drawscreen::my::Bind $w $events $com]
    catch {after cancel $com}
    after 500 $com
  }
}
#_______________________

proc ::drawscreen::my::Drawing {rootwin} {
  # Initializes drawing: creates a transparent window covering the screen.
  #   rootwin - a parent window's path

  variable draw
  Bell
  set draw(grab) [grab current]
  catch {grab release $draw(grab)}
  set win [string trimright $rootwin .].drawscreen
  if {[winfo exists $win]} return ;# esp. for Windows' lag
  catch {set draw(oldfocus) [focus]}
  focus $rootwin
  set draw(win) $win
  set draw(cnv) $win.canvas
  set w [winfo screenwidth .]
  set h [winfo screenheight .]
  toplevel $win -height 1 -width 1
  wm withdraw $win
  wm attributes $win -alpha 0.0 -topmost 1
  wm overrideredirect $win 1
  canvas $draw(cnv) -width $w -height $h -relief flat -bd 0 -highlightthickness 0
  pack $draw(cnv) -expand 1 -fill both -ipady 0 -padx 0 -pady 0 -side top
  BindingDraw $draw(cnv)
  # with "after" we avoid Tk shimmering
  after idle [list after 1 [list after 1 [list after 1 [list after 1 " \
    wm attributes $win -alpha 0.0; \
    wm deiconify $win; \
    wm geometry $win ${w}x${h}+0+0"]]]]
  set draw(incrwin) 0
}
#_______________________

proc ::drawscreen::my::DrawingDone {} {
  # Deletes the drawing stuff.

  variable draw
  set draw(started) no
  Bell
  catch {grab set $draw(grab)}
  after idle "destroy $draw(win); catch {focus $draw(oldfocus)}"
  after idle ::drawscreen::my::RunDrawingDone
}
#_______________________

proc ::drawscreen::my::RunDrawingDone {} {
  # Destroys drawing windows.

  variable draw
  variable windraw
  if {$draw(incrwin)>0} {
    catch {destroy .$windraw[set draw(incrwin)]}
    incr draw(incrwin) -1
    after idle ::drawscreen::my::RunDrawingDone
  }
}
#_______________________

proc ::drawscreen::my::DrawStart {X Y} {
  # Starts a current drawing.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  variable draw
  set draw(X) $X
  set draw(Y) $Y
  set draw(started) yes
}
#_______________________

proc ::drawscreen::my::Draw {X Y} {
  # Does a current drawing.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  variable draw
  variable windraw
  if {$draw(started)} {
    set w [expr {abs($X-$draw(X))}]
    set h [expr {abs($Y-$draw(Y))}]
    set drawX [expr {$w>$draw(length)}]
    set drawY [expr {$h>$draw(length)}]
    if {$drawX || $drawY} {
      if {$draw(X)<$X} {set x $draw(X)} {set x $X}
      if {$draw(Y)<$Y} {set y $draw(Y)} {set y $Y}
      set draw(X) $X
      set draw(Y) $Y
      set wdr .$windraw[incr draw(incrwin)]
      set cnv $wdr.canvas
      if {$drawX} {
        set h $draw(width)
      } else {
        set w $draw(width)
      }
      toplevel $wdr -height 1 -width 1
      wm withdraw $wdr
      wm overrideredirect $wdr 1
      wm attributes $wdr -topmost 1
      pack [canvas $cnv -width [incr w 2] -height [incr h 2] -relief flat -bd 0 -highlightthickness 0 -background $draw(fill)]
      wm geometry $wdr ${w}x${h}+$x+$y
      wm deiconify $wdr
      BindingDraw $cnv
    }
  }
}
#_______________________

proc ::drawscreen::my::DrawFinish {X Y} {
  # Finishes a current drawing.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  variable draw
  Draw $X $Y
  set draw(started) no
}
#_______________________

proc ::drawscreen::my::BindingDraw {win} {
  # Sets working bindings for drawing.
  #   win - window's path

  bind $win <ButtonPress-1>   {::drawscreen::my::DrawStart %X %Y; break}
  bind $win <Motion>          {::drawscreen::my::Draw %X %Y; break}
  bind $win <ButtonRelease-1> {::drawscreen::my::DrawFinish %X %Y; break}
  bind $win <Double-Button-1> {::drawscreen::my::DrawingDone; break}
  bind $win <ButtonPress-3>   {::drawscreen::my::DrawingDone; break}
}
#_______________________

proc ::drawscreen::my::Bell {} {
  # Sounds.

  variable draw
  if {$draw(dobell)} bell
}
#_______________________

proc ::drawscreen::my::HomeDir {} {
  # For Tcl 9.0 & Windows: gets a home directory ("~").

  if {[catch {set hd [file home]}]} {
    if {[info exists ::env(HOME)]} {set hd $::env(HOME)} {set hd ~}
  }
  return $hd
}

# ________________________ Interface procedures _________________________ #

proc ::drawscreen::run {wins {events ""} args} {
  # Runs my::Binding and catches errors. Logs errors to a log file.
  #   wins - the list of parent window pathes
  #   events - events to start drawing
  #   args - options of drawscreen

  configure {*}$args
  if {[catch {my::Binding $wins $events} err]} {
    catch {my::DrawingDone}
    catch {my::Binding $wins $events {}}
    set hd [my::HomeDir]
    catch {
      set ch [open [file join $hd TMP drawscreen.log] a]
      puts $ch $err
      close $ch
    }
  }
}
#_______________________

proc ::drawscreen::cget {args} {
  # Gets option values of drawscreen (width, fill, length).
  #   args - list of option names (can be "width fill -fill -width" etc.)

  variable my::draw
  set res [list]
  foreach opt $args {
    set opt [string trimleft $opt -]
    if {[info exists my::draw($opt)]} {
      set val $my::draw($opt)
    } else {
      set val {}
    }
    lappend res $val
  }
  return $res
}
#_______________________

proc ::drawscreen::configure {args} {
  # Sets option values of drawscreen (width, fill, length).
  #   args - list of pairs "option value" (e.g. "width 8 -fill blue")

  variable my::draw
  foreach {opt val} $args {
    set opt [string trimleft $opt -]
    if {$opt in {fill width length dobell}} {set my::draw($opt) $val}
  }
}

# _________________________________ main _________________________________ #

if {[info exist ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
  wm geometry . +0+0
  lassign $::argv hotk
  if {$hotk eq {}} {set hotk {Control-q Control-Q}}
  set hk [string map [list < {} > {} { } {, }] $hotk]
  label .labinfo -text \
    "Press $hk, then\ndrag-n-drop... or\nright/double click."
  pack .labinfo -padx 50 -pady 50
  bind . <Escape> exit
  ::drawscreen::run . $hotk {*}[lrange $::argv 1 end]
}

# _________________________________ EOF _________________________________ #
