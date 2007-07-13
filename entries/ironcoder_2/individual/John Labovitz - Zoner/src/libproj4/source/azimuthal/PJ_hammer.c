/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_hammer.c,v 2.1 2003/03/28 01:46:39 gie Distr. gie $";
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
#define PROJ_PARMS__ \
	double w; \
	double m, rm;
#define PJ_LIB__
# include	<lib_proj.h>
PROJ_HEAD(hammer, "Hammer & Eckert-Greifendorff")
	"\n\tMisc Sph, no inv.\n\tW= M=";
FORWARD(s_forward); /* spheroid */
	double cosphi, d;

	d = sqrt(2./(1. + (cosphi = cos(lp.phi)) * cos(lp.lam *= P->w)));
	xy.x = P->m * d * cosphi * sin(lp.lam);
	xy.y = P->rm * d * sin(lp.phi);
	return (xy);
}
FREEUP; if (P) free(P); }
ENTRY0(hammer)
	if (pj_param(P->params, "tW").i) {
		if ((P->w = fabs(pj_param(P->params, "dW").f)) <= 0.) E_ERROR(-27);
	} else
		P->w = .5;
	if (pj_param(P->params, "tM").i) {
		if ((P->m = fabs(pj_param(P->params, "dM").f)) <= 0.) E_ERROR(-27);
	} else
		P->m = 1.;
	P->rm = 1. / P->m;
	P->m /= P->w;
	P->es = 0.; P->fwd = s_forward;
ENDENTRY(P)
/*
** $Log: PJ_hammer.c,v $
** Revision 2.1  2003/03/28 01:46:39  gie
** Initial
**
*/
