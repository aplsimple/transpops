#! /usr/bin/env tclsh
###########################################################
# Name:    drawscreen.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    02/11/2023
# Brief:   Handles drawing on the screen.
# License: MIT.
###########################################################

package require Tk
package require treectrl

# ________________________ Data of drawscreen _________________________ #

namespace eval ::drawscreen {

  namespace export run cget configure
  namespace ensemble create

  namespace eval my {
    variable draw
    array set draw {
      width 6
      fill #ff0000
      length 10
      bell yes
      started no X 0 Y 0 img {}
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
  if {$events eq {}} {set events {<Control-x> <Control-X>}}
  foreach w $wins {
    if {$com eq {-}} {set com "::drawscreen::my::Drawing $w ; break"}
    after idle [list ::drawscreen::my::Bind $w $events $com]
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
    after 200 [list ::drawscreen::my::Bind $w $events $com]
  }
}
#_______________________

proc ::drawscreen::my::Drawing {rootwin} {
  # Initializes drawing: creates a canvas holding the screen's content.
  #   rootwin - a parent window's path

  variable draw
  set win [string trimright $rootwin .].drawscreen
  if {[winfo exists $win]} return ;# esp. for Windows' lag
  catch {set draw(oldfocus) [focus]}
  focus $rootwin
  set draw(win) $win
  set draw(cnv) $win.canvas
  set w [winfo screenwidth .]
  set h [winfo screenheight .]
  toplevel $win
  wm withdraw $win
  wm geometry $win 1x1+0+0
  wm attributes $win -alpha 0.0 -topmost 1
  wm overrideredirect $win 1
  set draw(img) [image create photo -width $w -height $h]
  canvas $draw(cnv) -width $w -height $h -relief flat -bd 0 -highlightthickness 0
  $draw(cnv) create image 0 0 -image $draw(img) -anchor nw
  pack $draw(cnv) -expand 1 -fill both -ipady 0 -padx 0 -pady 0 -side top
  ::drawscreen::my::Loupe $w $h
  bind $draw(cnv) <ButtonPress-1>   "::drawscreen::my::DrawStart %X %Y"
  bind $draw(cnv) <Motion>          "::drawscreen::my::Draw %X %Y"
  bind $draw(cnv) <ButtonRelease-1> "::drawscreen::my::DrawFinish"
  bind $draw(cnv) <Double-Button-1> ::drawscreen::my::DrawingDone
  bind $draw(cnv) <ButtonPress-3>   ::drawscreen::my::DrawingDone
  # with "after" we avoid Tk shimmering
  after idle [list after 1 [list after 1 [list after 1 [list after 1 " \
    wm deiconify $win; \
    wm geometry $win ${w}x${h}+0+0; \
    wm attributes $win -alpha 1.0"]]]]
  Bell
}
#_______________________

proc ::drawscreen::my::DrawingDone {} {
  # Deletes the drawing stuff.

  variable draw
  Bell
  set draw(started) no
  image delete $draw(img)
  destroy $draw(win)
  catch {focus $draw(oldfocus)}
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
  if {$draw(started)} {
    if {abs($X-$draw(X))>$draw(length) || abs($Y-$draw(Y))>$draw(length)} {
      $draw(cnv) create line $X $Y $draw(X) $draw(Y) -fill $draw(fill) -width $draw(width)
      set draw(X) $X
      set draw(Y) $Y
    }
  }
}
#_______________________

proc ::drawscreen::my::DrawFinish {} {
  # Finishes a current drawing.

  variable draw
  set draw(started) no
}
#_______________________

proc ::drawscreen::my::Loupe {w h} {
  # Captures a screen image and pushes it into the canvas.
  #   w - width of image
  #   h - height of image

  variable draw
  set loupe_ctr_x [expr {$w / 2}]
  set loupe_ctr_y [expr {$h / 2}]
  loupe $draw(img) $loupe_ctr_x $loupe_ctr_y $w $h 1
}
#_______________________

proc ::drawscreen::my::Bell {} {
  # Sounds.

  variable draw
  if {$draw(bell)} bell
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
    catch {
      set ch [open ~/TMP/drawscreen.log a]
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
    if {$opt in {fill width length bell}} {set my::draw($opt) $val}
  }
}

# _________________________________ main _________________________________ #

if {[info exist ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
  lassign $::argv hotk
  if {$hotk eq {}} {set hotk {Control-x Control-X}}
  set hk [string map [list < {} > {} { } {, }] $hotk]
  label .labinfo -text \
    "Press $hk, then\ndrag-n-drop... or\nright/double click."
  pack .labinfo -padx 50 -pady 50
  bind . <Escape> exit
  ::drawscreen::run . $hotk {*}[lrange $::argv 1 end]
}

# _________________________________ EOF _________________________________ #
