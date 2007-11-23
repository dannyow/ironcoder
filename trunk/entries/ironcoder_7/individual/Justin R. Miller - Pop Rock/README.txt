Ironcoder VII Entry

Title: 		Pop Rock
Date:		November 18, 2007
Author: 	Justin Miller
		Code Sorcery Workshop 
		incanus@codesorcery.net

SUMMARY:

Pop Rock takes the Ironcoder theme of Retro and the API of Core Animation and combines them as a retro rock concert app launcher. As each app is launched, it is a featured performer on stage, playing a guitar riff in front of the rest of your running apps. The more apps you are running at the time, the more popular the launched app and the better the crowd reaction. 

 * less than 4 other apps: 	poor crowd reaction
 * 4-7 other apps running:	lame crowd reaction
 * 8-15 other apps running: 	enthusiastic crowd reaction
 * 16+ other apps running:	awesome crowd reaction

TECH NOTES:

I actually don't use Core Animation/LayerKit, but instead chose Quartz Composer as the main programming language since I've been wanting to mess with it for a while now. Besides, it uses the same underlying 2D animation technology and this project consists mostly of somewhat-coordinated 2D translations of the sort that Core Animation handles. Don't hate me. 

I use a font in the animation that I think looks the best but is not a system default. It comes with MS Office or is found in Pop Rock's source folder, so running Pop Rock from the .dmg should locate the font automatically. 

My award for best looking app on stage and holding a guitar is Cyberduck. 

CREDITS & THANKS: 

Much thanks to Mike Zornek for the idea of an app launcher with his amazing MegaManEffect at http://blog.clickablebliss.com/2007/06/30/universal-megamaneffect/

Thanks to my wife Michelle for putting up with my hours of coding and hearing the same damn guitar noises over and over again. 

Guitar riffs adapted from some stuff I found on the net and can't find right now (public domain, though). 

Stage image from a Google Images search. 

Remaining sound effects from Futurama, GarageBand, and Grace's husband (thanks!).