AdventureTime
Iron Coder 7

All code BSD Licensed

By Nur Monson

AdventureTime is a simple adventure game somewhat like the old ones but with
no inventory (among many other limitations) and fancier graphics enabled by
Core Animation. I know it's not the most retro thing, but I wanted to make
it so I did.

While I would hope that you enjoy the "adventure" it comes with, I realize
that I'm not a writer, musician, or an artist so I understand that hideous.
The real feature of AdventureTime is that it's totally
modular so you can make your own "adventure" if you don't mind editing
XML/plist files and managing a directory full of media yourself. I toyed with
the idea of writing an editor, but that would have given me less space in my entry
for "content" and it would have also just eaten a bunch of to make something
easier that was plenty bearable already. So I scrapped that idea (for now?).

There were, obviously, many things that I would have liked to have added but
I didn't want to spend the whole week working on this thing. I wish I could
have added effects to it, for instance. Or more animation. I really wanted
to make the whole game file one big binary to make casual browsing of the
source media and text harder, but that wasn't a central feature so I cut it.
The game will crash if it is missing any media asked for by the game file.

I recommend playing the game before reading about the technical details. It
will make it easier to understand. Also I apologize to anyone who appears
in the crappy sample "game." I didn't put anyone in there that I don't think
is cool. I was just being silly.

Despite sound and music support, the sample game uses neither because I ran
out of time.

===========
FILE FORMAT
===========

The AdventureTime app actually loads the "game.adventuretime" file from its
Resources directory. This file is a package-type type file that contains
a "game.plist" file that describes the adventure script as well as any number
of media files (to be referenced by the "game.plist" file).

Before I get into the structure of the "game.plist" file I should explain
the two main Classes used to construct a game.

============
GAME CLASSES
============

AdventureEvent:
This class describes one "screen" of data:
Background Image: 800x600 (should be opaque).
Right NPC Image: a character image on the right side of the screen. Up to
	400x600 pinned in the lower-righthand corner. Should be transparent
	(gif or PNG).
Left NPC Image: same as the Right NPC Image but pinned to the lower-lefthand
	corner.
Name: a string for the name of the character speaking.
Text: the text being spoken (or thought, etc.).
Sound: A sound to be played once at the start of the scene.
The elements of the current AdventureEvent always replace the elements
of the last AdventureEvent so if you want to keep the same background across
two or more events you need to have each event a reference to that image.
Similarly, if you want to clear an image for an event, just leave it out
completely (i.e. make it nil). Don't want a text box?-- Just leave Text
empty.

AdventureScene:
This class contains an array of AdventureEvents that are played through
one after the other as the player presses "any key." It also contains
an audio file to play while that scene is running (looped) and an
array of choices to display to the player at the end of the scene. Each
choice will send the player off to a new scene somewhere in the game's
collection of scenes. If there is only one choice, the player isn't
even shown the choice menu and that choice is taken automatically. If
there are no choices the game just stops there (game over/dead end).

There is also a small caching system at the AdventureScene level (supported
by the AdventureEvents) that keeps each resource from having to be loaded
more than once across any single scene or any two subsequent scenes
(i.e. if the last scene had it loaded, the next scene will just pull
from the cached objects from the last scene). Also, if a song was playing
in one scene and the same song is used in the next scene, it will
continue playing on into the next scene without interruption.

====================
game.plist structure
====================

By now you may be able to guess how this works but here it is anyway.

At the top level is an array of "scenes." A scene looks like this:

scene (dictionary)
	|
	+- name (string)
	+- song (string)
	+- events (array)
	+- choices (dictionary)
	
The choices dictionary consists of keys that are the text to be
displayed ("Cut the red wire.") and a number that indicates what scene
to branch to. A scene is allowed to branch to itself and as it was
mentioned above: you can leave it out if you want the game to end
here or you can have only once choice if you want it to branch silently
(you can use this to change music while it appears to be the same
scene).

The name is just there for use by an editing program so you don't
have to view a list of scenes by their index. The game effectively
ignores this.

Each event looks like this:

event (dictionary)
	|
	+- background (string)
	+- right (string)
	+- left (string)
	+- name (string)
	+- text (string)
	+- sound (string)
	
Every item that references some media (i.e. Everything, except for
"name" and "text") is the filename of a file that is in the ".adventure"
package. Image-type items can be anything that Image I/O can load
and audio files can be anything Quicktime can load. The filenames
are relative to the enclosing package so it's just the
filename with no path (i.e. "image.jpg" and "sound.m4a").

