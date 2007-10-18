Ironcoder #5

Author: Jonathan Wight

Title: Spacecam

Overview:

This program overlays live video feed from your Mac's iSight camera (you do have an iSight on your mac right?) with images downloaded live from flickr tagged with the 'space' keyword.

Usage:

Run the app, watch as main window shows live video from iSight, click the "Gather Background" button, you now have five seconds to get out of sight of the camera while it memorizes the background.

Once this stage is finished the background will be replaced by the live images from Flickr and you can now look into the camera again. The intended effect is something like a green screen/chromakey effect - but on the cheap (akin to the effects in 10.5's iChat).

Technologies:

	ToxicMedia (my CoreImage/Quicktime framework) was used to get CoreImage images from the iSight camera. And some other basic CoreImage tasks (croping, scaling, drawing to an NSView).
	
	ToxicMedia was also used for the "GenericFilter" class (a quick and easy way to create CoreImage filters on the fly).
	
	JSON is used as a file format to retrieve data from Flickr (I already had some JSON code, but had to update it quite dramatically to work with Flickr's feed).
	
	Three custom CoreImage kernels were used for the image processing. Although only one was used in the 'finished' product.

Bugs:

	The most noticeable bug is that the filter that computes the difference between the static background and the current background doesn't do a very good job. I tried a couple of different algorithms but didn't get an effect I was happy with. There are a lot more sophisticated algorithms I could use but didn't have the time to try them.
	
Failures:

	I wanted to produce an average image background but taking 5 seconds or so of background images and then averaging them out. That would have helped to eliminate the noise from an unsteady cam. However I hit a limitation with CoreImage and had to give up with that technique (CoreImage doesn't like the output of a filter being used as an input for the same filter).
	
	One of the algorithms I thought would work well (converting RGB pixel values into HSV and weighting differences solely based on the Hue of the colour) didn't work well at all and was to complex to run on a Macbook's GPU.
	
	The Flickr code is very quick and dirty. It does not attempt  to download the feed more than once which means you're stuck with a limited number of images.

Successes:

	The effect can be rather good under certain conditions. It worked reasonably well first time.
	
	Getting images from flickr was quick and easy (once the bugs in my JSON code was fixed). Thanks to Blake Seely for info on getting data from Flickr.