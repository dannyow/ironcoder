LICENSE:

---    

Copyright (c) 2007, Ian J. Baird

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the Ian J. Baird nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

---    

Date:    4/1/07
Version: 1.3
Author:  Ian J. Baird <ibaird@skorpiostech.com>

Changes from 1.1: The screensaver now handles multiple monitors correctly. 
Changes form 1.2: The screensaver now handles previewing correctly.

Instructions: Open the LeRoiEstMort.xcodeproj bundle using XCode 2.4.1. Compile the project using the Release target. Install the ScreenSaver by double clicking on the build product (called LeRoiEstMore.saver) in the build/Release folder. When prompted, either install the screensaver for the current user (recommended) or for all users if you wish.

Activate the screensaver to test. The screen saver should cycle automatically between randomly chosen clips.

APIs Used:

Screensaver, OpenGL, WebKit, Cocoa

Theme Usage: All of the movie clips used by the application are related to "Life" in some way or another.

Movie00 - "Prom Night Baby" - this film examines the deep societal impact of teen pregnancy
Movie01 - "Every Sperm is Sacred" - this film examines the Roman Catholic view of life
Movie02 - "The Big Bang" - this film examines the precursors to life, and the differing opinions (evolution vs. creationism)
Movie03 - "The Bright Side of Life" - this is a song about life, originally from Monty Python's movie "The Life of Brian"

Notes:
         
All movies are streamed live from YouTube. No other companies IP rights have been violated in the making of this screensaver.

The screensaver makes a "best effort" to cycle between clips based on the stated duration of the clip plus a "load time fudge factor" of ten seconds. A generic moviexx.html template was used along with the movies.plist file to seed the WebView with content to render.

WARNING: If you have enbabled LittleSnitch on your system and the movies do not download, then please add ScreenSaverEngine.app to the list of allowed users of the network, or the screensaver will not work!

WARNING: This new version only allows one version of the NSScreenSaverView to be active at a time, therefore the "Test" functionality from the System Prefs panel doesn't work for this. Set it as your screensaver and activate the screensaver to test!


