package ifneeded transpops 1.2.4 [list source [file join $dir transpops.tcl]]

# A short intro (for Ruff! docs generator:)

namespace eval ::transpops {

  set _ruff_preamble {
The Tcl/Tk *transpops* package displays popup messages.
Fit for demos, though may be used otherwise.

The messages are read from a *text file* and after pressing a *hotkey* are
shown one by one, in transparent mode.

First called, the popup message is displayed under the mouse pointer. The following messages will be displayed at the same screen coordinates if not reset with an *alternative hotkey*.

<hr>

Runs this way:

    package require transpops
    ::transpops::run transpops.txt {<Control-t> <Alt-t>} {.w1 .w2} ?fg? ?bg?

where:

   * *transpops.txt* - name of *text file* containing messages
   * *Control-t* - *hotkey* event to start the pop-up of messages
   * *Alt-t* - *alternative hotkey* event to restart the pop-up of messages at new coordinates
   * *.w1 .w2* - list of toplevel windows the events are bound to
   * *fg, bg* - foreground and background colors

Of course, those `<Control-t>` and `<Alt-t>` may be substituted with other events specific for the application.

<hr>

License: MIT.
  }

}

namespace eval ::transpops::my {

  set _ruff_preamble {
  The *::transpops::my* namespace contains procedures for internal usage by
  *transpops* package.
  }
}
