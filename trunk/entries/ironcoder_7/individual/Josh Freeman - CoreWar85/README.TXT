
Core War '85 for Mac OS X

Version 1.0
November 18, 2007

Written by Josh Freeman

Copyright (c) 2007, Twilight Edge Software

All rights reserved.


------------------------------------------------------------------------------
LICENSE:

This software is distributed under the BSD License

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
      this list of conditions and the following disclaimer in the documentation 
      and/or other materials provided with the distribution.
    * Neither the name, "Twilight Edge Software", nor the names of its 
      contributors may be used to endorse or promote products derived from this 
      software without specific prior written permission.

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


------------------------------------------------------------------------------
ABOUT:

Core War is a computer game where two programs battle for control of a
simulated computer. It was designed by A.K. Dewdney & David Jones and
presented through several articles Dewdney wrote for Scientific American
magazine, beginning in 1984.

Core War programs are written in a simplified assembly language called 
Redcode. While the Redcode language has continued to evolve over the past 
23 years, "Core War '85" (this app) is based on the 'retro' version specified 
in Dewdney's first two articles.

Core War '85 allows the user to select two or more Redcode Programs and run 
them in a round-robin tournament, displaying each battle on screen in a 
representation of the simulated computer's memory.


------------------------------------------------------------------------------
IRON CODER INGREDIENTS (Core Animation Retro):

CORE: "Core War '85" is so core, it even has it in its name!

ANIMATION: There's plenty of animation on the screen as the Redcode programs
run through simulated memory, however, as Core War '85 was developed on Tiger, 
there is no Layer Kit functionality.

RETRO: A RETRO version of a RETRO game that even runs on a RETRO OS. (Panther)


------------------------------------------------------------------------------
SYSTEM REQUIREMENTS:

- Computer running Mac OS X Panther or later


------------------------------------------------------------------------------
TOURNAMENT DETAILS:

Core War '85 runs a round-robin tournament between the programs chosen by the
user. Each loaded program competes in a 1-on-1 match with every other program.

A match consists of 7 battles, where the two programs are placed randomly in
memory and run until either one program loses all its processes through errors
or until time runs out (32,000 cycles).

Winning a battle is worth 3 points and a tie is worth 1 point. After 
7 battles, the program with more points is declared the winner of the match.


------------------------------------------------------------------------------
INSTRUCTIONS:

Core War '85's main window contains a large dark area at the top, which 
represents the simulated computer's memory. The table underneath it lists all 
currently loaded programs and their statistics during the tournament.

Below the table are 4 buttons:

"Load Programs..."
------------------
Press this button to bring up an open dialog where you can choose one or more
Redcode Programs (or folders containing them). In order for Redcode Programs
to be recognized by Core War '85, they must be text files with the extension,
".txt". 
When a program is successfully loaded by the app, it will appear in the 
table. Some sample programs have been included in the "Redcode Programs"
folder.

"Remove Programs"
-----------------
Press this button to remove all loaded programs.

"Reset Tournament"
------------------
Press this button to cancel the tournament if it's running, and reset all
tournament statistics.

"BEGIN Tournament"
------------------
Once you have loaded two or more programs, press this button to begin the
tournament. 
While the tournament runs, the button will change its title to 
"PAUSE Tournament"; Click once to pause the battle, then again to resume.


------------------------------------------------------------------------------
WRITING REDCODE PROGRAMS:

At the time of this writing, scanned images of Dewdney's original articles are
available here:
http://www.koth.org/info/sciam/
(Only SciAm1a.jpg through SciAm2f.jpg are relevant to this app.)

An introduction to writing Redcode programs can be found here:
http://vyznev.net/corewar/guide.html

Please note that the above guide also refers to instructions available in 
later versions of Redcode, but not supported here.

Supported instructions are listed below.


------------------------------------------------------------------------------
CORE WAR '85 SUPPORTED INSTRUCTIONS:

DAT    Data
MOV    Move
SUB    Subtract
JMP    Jump
JMZ    Jump If Zero
JMG    Jump If Greater Than Zero
DJZ    Decrement, Jump If Zero
CMP    Compare
SPL    Split


------------------------------------------------------------------------------
CONTACT: 

Josh Freeman
corewar@twilightedge.com
