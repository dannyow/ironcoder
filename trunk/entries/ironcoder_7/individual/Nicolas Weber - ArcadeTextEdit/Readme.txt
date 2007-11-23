Turn sound on, then launch ArcadeTextEdit.app and start writing something.

Lessons learned: NSTextViews don't play nice with Core Animation :-P And the
CI bloom filter is kinda slow.

The program displays a score that gets higher as you type, and some "special"
words trigger a small animation that gives you a few bonus points (try
"ironcoder" for example). While you're typing, the score text glows (which is
quite cpu heavy).

It uses several features of core animation. Layer backed views for the text
and scroll view (doesn't work too well -- turn on spell checking for example.
Scrolling looks weird too and the text disappears while the window is
resized), bare layers for score view and the text zoom effect,
QCCompositionLayer for the background, CATextLayers for the font effects and
the score, a CIFilter for the scoreboard glow and lots of (mainly explicit)
CAAnimations.

I wanted to do add lots and lots of other things (a few ideas are outlined
in notes.txt), but I didn't find the time. Thanks to having nine days, I
was able to complete at least _something_. And writing this was fun :-)

Nicolas Weber
nicolasweber@gmx.de 


 vim:set tw=78:
