/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_trans.c,v 2.1 2003/03/28 01:44:30 gie Distr. gie $";
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
** Alternative transendental functions checked for near domain
** range problems
*/
#include <lib_proj.h>
#define ONE_TOL	 1.00000000000001
#define TOL	0.000000001
#define ATOL 1e-50
	double
pj_asin(double v) {
	double av;

	if ((av = fabs(v)) >= 1.) {
		if (av > ONE_TOL)
			pj_errno = -19;
		return (v < 0. ? -HALFPI : HALFPI);
	}
	return asin(v);
}
	double
pj_acos(double v) {
	double av;

	if ((av = fabs(v)) >= 1.) {
		if (av > ONE_TOL)
			pj_errno = -19;
		return (v < 0. ? PI : 0.);
	}
	return acos(v);
}
	double
pj_sqrt(double v) { return ((v <= 0) ? 0. : sqrt(v)); }
	double
pj_atan2(double n, double d) {
	return ((fabs(n) < ATOL && fabs(d) < ATOL) ? 0. : atan2(n,d));
}
/*
** $Log: pj_trans.c,v $
** Revision 2.1  2003/03/28 01:44:30  gie
** Initial
**
*/

