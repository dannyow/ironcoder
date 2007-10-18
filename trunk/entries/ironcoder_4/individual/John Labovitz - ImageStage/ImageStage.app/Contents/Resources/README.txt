ImageStage
by John Labovitz, Eureka Toolworks
johnl@johnlabovitz.com / www.johnlabovitz.com

ImageStage uses Yahoo Images to find images related to "space," and then shows those images 
on a radar screen.


Caveats

It doesn't work well if you don't have an internet connection, or if that connection is slow.
Only small files are asked for (50-100k), but if those files aren't received within a few seconds, 
the request is cancelled.

I had a bug where the app would run out of images to display, but not be able to get more.
I believe that's now fixed (by using a watchdog timer), but if you just get a blank screen, try
to run the app again.