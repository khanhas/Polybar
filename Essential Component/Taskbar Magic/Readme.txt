Hide taskbar AND start button (Vista too)

Every program I've tried to hide these left the start button in Vista, so I wrote a small program myself to do it.

Instructions:
-Begin by auto-hiding your taskbar (right click, properties, auto hide), this frees up the maximum space on your desktop when the bar is hidden
-Run it, if you are running a dock program (like Rocket Dock), then allocate 45 pixels or so for it
-Click Ok
-To re-show the taskbar, or close the program, simply hit Ctrl+Alt+Esc to bring the options back
-You can also re-adjust the allocated dock space in that menu

Known bugs
-Some anti-virus programs have blacklisted everything written in Autoit, I've included the source, you can compile it yourself with a compiler from www.autoitscript.com
-Sometimes the taskbar likes to come back (like if you invoke the start menu), just wait <2.5 seconds, and my program will hide it again
-Can't hide the start menu... I mean... I guess I could try if there's enough demand...

Thanks to Kerie Roark (myspace.com/spookypirate) for the help in desinging the icon

Enjoy