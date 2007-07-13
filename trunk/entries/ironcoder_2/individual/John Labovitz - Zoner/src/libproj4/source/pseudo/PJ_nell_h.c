/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_nell_h.c,v 2.2 2004/12/12 15:22:36 gie Exp gie $";
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
	double n, np, root, Cy, Dy; \
	int mode;
#define PJ_LIB__
#define N_TOL 1e-6
# include	<lib_proj.h>
PROJ_HEAD(nell_h, "Nell-Hammer") "\n\tPCyl., Sph. [n=]";
#define NITER 9
#define EPS 1e-7
FORWARD(s_forward); /* spheroid */
	double cosphi, rtanf;

	cosphi = cos(lp.phi);
	switch (P->mode) {
	case 1: /* n = 0.5 */
		xy.x = 0.5 * lp.lam * (1. + cosphi);
		xy.y = 2.0 * (lp.phi - tan(0.5 *lp.phi));
		break;
	case 2: /* n > 0.5 */
		xy.x = (P->n + P->np * cosphi) * lp.lam;
		rtanf = P->root * tan(0.5 * lp.phi);
		xy.y = P->Cy * (lp.phi - P->Dy * atan(rtanf));
		break;
	case 0: /* n < 0.5 */
		xy.x = (P->n + P->np * cosphi) * lp.lam;
		xy.y = P->Cy * (lp.phi - P->Dy * atanh((1.-2.*P->n)*tan(0.5*lp.phi)/
				P->root));
		break;
	}
	return (xy);
}
INVERSE(s_inverse); /* spheroid */
	double V, c, p;
	int i;

	p = 0.5 * xy.y;
	for (i = NITER; i ; --i) {
		c = cos(0.5 * lp.phi);
		lp.phi -= V = (lp.phi - tan(lp.phi/2) - p)/(1. - 0.5/(c*c));
		if (fabs(V) < EPS)
			break;
	}
	if (!i) {
		lp.phi = p < 0. ? -HALFPI : HALFPI;
		lp.lam = 2. * xy.x;
	} else
		lp.lam = 2. * xy.x / (1. + cos(lp.phi));
	return (lp);
}
FREEUP; if (P) free(P); }
ENTRY0(nell_h)
	P->es = 0.;
	if (pj_param(P->params, "tn").i) {
		P->n = pj_param(P->params, "dn").f;
		if ((P->n < N_TOL) || (P->n > 1.-N_TOL))
			E_ERROR(-40)
	} else
		P->n = 0.5;
	P->np = 1.0 - P->n;
	if (fabs(P->n - 0.5) < N_TOL) {
		P->mode = 1;
		P->inv = s_inverse;
	} else if (P->n < 0.5) {
		P->mode = 0;
		P->root = sqrt(1.0 - 2. * P->n);
		P->Cy = 1.0/(1.-P->n);
		P->Dy = 2. * P->n / P->root;
	} else {
		P->mode = 2;
		P->root = sqrt(2. * P->n - 1.0);
		P->Cy = 1.0/(1.-P->n);
		P->Dy = 2.0* P->n / P->root;
	}
	P->fwd = s_forward;
ENDENTRY(P)
/*
** $Log: PJ_nell_h.c,v $
** Revision 2.2  2004/12/12 15:22:36  gie
** added complete form of projection---n= option
**
** Revision 2.1  2003/03/28 01:46:51  gie
** Initial
**
*/
