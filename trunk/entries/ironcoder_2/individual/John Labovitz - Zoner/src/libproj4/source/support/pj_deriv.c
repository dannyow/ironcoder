/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_deriv.c,v 2.1 2003/03/28 01:44:29 gie Distr. gie $";
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
** dervative of (*P->fwd) projection
*/
#define PJ_LIB__
#include "lib_proj.h"
	int
pj_deriv(LP lp, double h, PJ *P, struct DERIVS *der) {
	XY t;

	lp.lam += h;
	lp.phi += h;
	if (fabs(lp.phi) > HALFPI) return 1;
	h += h;
	t = (*P->fwd)(lp, P);
	if (t.x == HUGE_VAL) return 1;
	der->x_l = t.x; der->y_p = t.y; der->x_p = -t.x; der->y_l = -t.y;
	lp.phi -= h;
	if (fabs(lp.phi) > HALFPI) return 1;
	t = (*P->fwd)(lp, P);
	if (t.x == HUGE_VAL) return 1;
	der->x_l += t.x; der->y_p -= t.y; der->x_p += t.x; der->y_l -= t.y;
	lp.lam -= h;
	t = (*P->fwd)(lp, P);
	if (t.x == HUGE_VAL) return 1;
	der->x_l -= t.x; der->y_p -= t.y; der->x_p += t.x; der->y_l += t.y;
	lp.phi += h;
	t = (*P->fwd)(lp, P);
	if (t.x == HUGE_VAL) return 1;
	der->x_l -= t.x; der->y_p += t.y; der->x_p -= t.x; der->y_l += t.y;
	der->x_l /= (h += h);
	der->y_p /= h;
	der->x_p /= h;
	der->y_l /= h;
	return 0;
}
/*
** $Log: pj_deriv.c,v $
** Revision 2.1  2003/03/28 01:44:29  gie
** Initial
**
*/
