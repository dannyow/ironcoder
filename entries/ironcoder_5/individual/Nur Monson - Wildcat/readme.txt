Wildcat

By: Nur Monson (nur.monson@gmail.com)
http://www.theidiotproject.com
Date: April 1, 2007
Version: 1.0
License: BSD
Iron Coder V

It's just a crapy life simulator in a screen saver. Little creatures wanter around on
a randomly generated landscape. There's way too much code in here that's not being used.
I even set up some lame space partitioning and wanted to have them die and give birth. There's
also so code to texture the lanscape in there (with a crappy fragment shader!) but in the end
I figured a solid color looked better than crappy textures.

It uses OpenGL and makes liberal use of the SSRandom... functions in the Screen Saver framework.
Those are some pretty handy functions. The landscape is a bezier curve built from a randomly
generated heightfield that I then used to draw a triangle strip at some arbitrary level of detail.
The little creatures are just seeded with a bunch of random values and set loose. They are
textured with a redrawing of the :awesome: emote from somethingawful.

If you want to actually have them interact take a look at the BeastMaster/BeastKeeper classes.
I love those class names so I had to leave them in (plus I did a lot of work on them).
BeastMaster needs lots more code but BeastKeeper is mostly done. Unlock the secrets of my dead
code!

Oh yeah, in my testing, sometimes the textures wouldn't load for the creatures and I'd just get
colored squares. It's pretty rare, but if it happens just run it again. I also may have fixed it
but I don't have time to test it properly so I can't be totally sure.

Also, the name "Wildcat" is totally arbitrary aside from the fact that the creatures are WILD!
I was listening to the Ratatat song Wildcat when I started, and I know big Steve loves big cats.
I was also much better than my first project name "IronCoderV" which I deleted soon after I came
up with this one. I didn't want to spend too much time coming up with a cooler name. I needed
that time to work on features that wouldn't get used dammit!

Just drop the .saver file into one of your system Screen Saver directories:
/Library/Screen Savers/
~/Library/Screen Savers/
