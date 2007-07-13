/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_factors.c,v 2.2 2005/02/12 17:25:29 gie Exp gie $";
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
** projection scale factors
*/
#define PJ_LIB__
#include <lib_proj.h>
#include <errno.h>
#ifndef DEFAULT_H
#define DEFAULT_H   1e-5    /* radian default for numeric h */
#endif
#define EPS 1.0e-12
	int
pj_factors(LP lp, PJ *P, double h, struct FACTORS *fac) {
	struct DERIVS der;
	double cosphi, t, n, r;

	/* check for forward and latitude or longitude overange */
	if ((t = fabs(lp.phi)-HALFPI) > EPS || fabs(lp.lam) > 10.) {
		pj_errno = -14;
		return 1;
	} else { /* proceed */
		errno = pj_errno = 0;
		if (fabs(t) <= EPS) /* adjust to pi/2 */
			lp.phi = lp.phi < 0. ? -HALFPI : HALFPI;
		else if (P->geoc)
			lp.phi = atan(P->rone_es * tan(lp.phi));
		lp.lam -= P->lam0;	/* compute del lp.lam */
		if (!P->over)
			lp.lam = pj_adjlon(lp.lam); /* adjust del longitude */
		if (h <= 0.)
			h = DEFAULT_H;
		if (P->spc)	/* get what projection analytic values */
			P->spc(lp, P, fac);
		if (((fac->code & (IS_ANAL_XL_YL+IS_ANAL_XP_YP)) !=
			  (IS_ANAL_XL_YL+IS_ANAL_XP_YP)) &&
			  pj_deriv(lp, h, P, &der))
			return 1;
		if (!(fac->code & IS_ANAL_XL_YL)) {
			fac->der.x_l = der.x_l;
			fac->der.y_l = der.y_l;
		}
		if (!(fac->code & IS_ANAL_XP_YP)) {
			fac->der.x_p = der.x_p;
			fac->der.y_p = der.y_p;
		}
		cosphi = cos(lp.phi);
		if (!(fac->code & IS_ANAL_HK)) {
			fac->h = hypot(fac->der.x_p, fac->der.y_p);
			fac->k = hypot(fac->der.x_l, fac->der.y_l) / cosphi;
			if (P->es) {
				t = sin(lp.phi);
				t = 1. - P->es * t * t;
				n = sqrt(t);
				fac->h *= t * n / P->one_es;
				fac->k *= n;
				r = t * t / P->one_es;
			} else
				r = 1.;
		} else if (P->es) {
			r = sin(lp.phi);
			r = 1. - P->es * r * r;
			r = r * r / P->one_es;
		} else
			r = 1.;
		/* convergence */
		if (!(fac->code & IS_ANAL_CONV)) {
			fac->conv = - atan2(fac->der.y_l, fac->der.x_l);
			if (fac->code & IS_ANAL_XL_YL)
				fac->code |= IS_ANAL_CONV;
		}
		/* areal scale factor */
		fac->s = (fac->der.y_p * fac->der.x_l - fac->der.x_p * fac->der.y_l) *
			r / cosphi;
		/* meridian-parallel angle theta prime */
		fac->thetap = pj_asin(fac->s / (fac->h * fac->k));
		/* Tissot ellips axis */
		t = fac->k * fac->k + fac->h * fac->h;
		fac->a = sqrt(t + 2. * fac->s);
		t = (t = t - 2. * fac->s) <= 0. ? 0. : sqrt(t);
		fac->b = 0.5 * (fac->a - t);
		fac->a = 0.5 * (fac->a + t);
		/* omega */
		fac->omega = 2. * pj_asin(fabs(fac->h - fac->k)/(fac->h + fac->k));
	}
	return 0;
}
/*
** $Log: pj_factors.c,v $
** Revision 2.2  2005/02/12 17:25:29  gie
** re-did omega calc from h-k rather than a-b
**
** Revision 2.1  2003/03/28 01:44:30  gie
** Initial
**
*/
