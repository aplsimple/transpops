The Tcl/Tk *transpops* package displays popup messages.
Fit for demos, though may be used otherwise.

The messages are read from a *text file* and after pressing a *hotkey* are
shown one by one, in transparent mode. The most representative examples of
the *text files* are in demos/alited/ subdirectories which result in [demos of alited](https://github.com/aplsimple/alited/releases/tag/Demos_of_alited-1.6).

First called, the popup message is displayed under the mouse pointer. The following messages will be displayed at the same screen coordinates if not reset with an *alternative hotkey*.

The popup messages will be hidden at clicking them.

Also, you can draw on the screen, by means of [drawscreen](https://chiselapp.com/user/aplsimple/repository/drawscreen).

*Note for apave package*. The apave's showModal method includes a specific bind of Ctrl-Alt-0 keys to hide the transpops messages with these keys (because a modal window captures any clicks).

<hr>

Runs this way:

    package require transpops
    ::transpops::run transpops.txt wins ?events? ?fg? ?bg? ?events2? ?options?

where:

   * *transpops.txt* - name of *text file* containing messages
   * *wins* - list of toplevel windows the events are bound to
   * *events* - events to show messages at mouse pointer as last and forced, default "Alt-t Alt-y"
   * *fg, bg* - foreground and background colors
   * *events2* - list of events to start drawing on the screen, default "Control-x Control-X"
   * *options* - options of [drawscreen](https://chiselapp.com/user/aplsimple/repository/drawscreen)

<hr>

License: MIT.
