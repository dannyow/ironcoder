/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_fahey.c,v 2.1 2003/03/28 01:46:51 gie Distr. gie $";
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
# include	<lib_proj.h>
PROJ_HEAD(fahey, "Fahey") "\n\tPcyl, Sph.";
#define TOL 1e-6
FORWARD(s_forward); /* spheroid */
	xy.y = 1.819152 * ( xy.x = tan(0.5 * lp.phi) );
	xy.x = 0.819152 * lp.lam * pj_sqrt(1 - xy.x * xy.x);
	return (xy);
}
INVERSE(s_inverse); /* spheroid */
	lp.phi = 2. * atan(xy.y /= 1.819152);
	lp.lam = fabs(xy.y = 1. - xy.y * xy.y) < TOL ? 0. :
		xy.x / (0.819152 * sqrt(xy.y));
	return (lp);
}
FREEUP; if (P) free(P); }
ENTRY0(fahey) P->es = 0.; P->inv = s_inverse; P->fwd = s_forward; ENDENTRY(P)
/*
** $Log: PJ_fahey.c,v $
** Revision 2.1  2003/03/28 01:46:51  gie
** Initial
**
*/
