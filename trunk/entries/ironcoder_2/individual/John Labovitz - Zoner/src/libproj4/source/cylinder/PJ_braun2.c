/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_braun2.c,v 2.1 2003/04/06 02:49:58 gie Distr. gie $";
/*
** Permission is hereby granted, free of charge, to any person obtaining
** a copy of this software and associated documentation files (the
** "Software"), to deal in the Software without restriction, including
** without limitation the rights to use, copy, modify, merge, publish,
** distribute, sublicense, and/or sell copies of the Software, and to
** permit persons to whom the Software is furnished to do so, subject to
** the following conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#define PJ_LIB__
#include	<lib_proj.h>
PROJ_HEAD(braun2, "Braun's 2nd (Perspective)") "\n\tCyl, Sph, NI";
#define YA  1.4
#define YB  0.4
FORWARD(s_forward); /* spheroid */
	xy.x = lp.lam;
	xy.y = YA * sin(lp.phi)/(YB + cos(lp.phi));
	return (xy);
}
FREEUP; if (P) free(P); }
ENTRY0(braun2) P->es = 0.; P->inv = 0; P->fwd = s_forward; ENDENTRY(P)
/*
** $Log: PJ_braun2.c,v $
** Revision 2.1  2003/04/06 02:49:58  gie
** Initial
**
*/
