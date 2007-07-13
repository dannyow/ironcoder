/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_fwd.c,v 2.1 2003/03/28 01:44:30 gie Distr. gie $";
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
/*
** Forward projection entry point
*/
#define PJ_LIB__
#include <lib_proj.h>
#include <errno.h>
# define EPS 1.0e-12
	XY /* forward projection entry */
pj_fwd(LP lp, PJ *P) {
	XY xy;
	double t;

	/* check for forward and latitude or longitude overange */
	if ((t = fabs(lp.phi)-HALFPI) > EPS || fabs(lp.lam) > 10.) {
		xy.x = xy.y = HUGE_VAL;
		pj_errno = -14;
	} else { /* proceed with projection */
		errno = pj_errno = 0;
		if (fabs(t) <= EPS)
			lp.phi = lp.phi < 0. ? -HALFPI : HALFPI;
		else if (P->geoc)
			lp.phi = atan(P->rone_es * tan(lp.phi));
		lp.lam -= P->lam0;	/* compute del lp.lam */
		if (!P->over)
			lp.lam = pj_adjlon(lp.lam); /* adjust del longitude */
		xy = (*P->fwd)(lp, P); /* project */
		if (pj_errno || (pj_errno = errno))
			xy.x = xy.y = HUGE_VAL;
		/* adjust for major axis and easting/northings */
		else {
			xy.x = P->fr_meter * (P->a * xy.x + P->x0);
			xy.y = P->fr_meter * (P->a * xy.y + P->y0);
		}
	}
	return xy;
}
/* Revision log:
** $Log: pj_fwd.c,v $
** Revision 2.1  2003/03/28 01:44:30  gie
** Initial
**
*/
