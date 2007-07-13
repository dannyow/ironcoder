/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_tob_sqr.c,v 2.1 2003/04/06 02:49:58 gie Distr. gie $";
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
#define RSQPI 0.5641895835477562869480794515
#define SQPI  1.772453850905516027298167483
PROJ_HEAD(tob_sqr, "Tobler's World in a Square") "\n\tCyl, Sph";

FORWARD(s_forward); /* spheroid */
	xy.x = RSQPI * lp.lam;
	xy.y = SQPI * sin(lp.phi);
	return (xy);
}
INVERSE(s_inverse); /* spheroid */
	lp.lam = xy.x * SQPI;
	lp.phi = pj_asin(xy.y * RSQPI);
	return (lp);
}
FREEUP; if (P) free(P); }
ENTRY0(tob_sqr) P->es = 0.; P->inv = s_inverse; P->fwd = s_forward; ENDENTRY(P)
/*
** $Log: PJ_tob_sqr.c,v $
** Revision 2.1  2003/04/06 02:49:58  gie
** Initial
**
*/
