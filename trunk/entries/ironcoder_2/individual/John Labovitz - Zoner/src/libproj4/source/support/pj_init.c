/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_init.c,v 2.1 2003/03/28 01:44:30 gie Distr. gie $";
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
** projection initialization and closure
*/
#define PJ_LIB__
#include <lib_proj.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
	PJ *
pj_init(int argc, char **argv) {
	const char *s, *name;
	PJ *(*proj)(PJ *);
	paralist *curr = 0, *start = 0;
	int i;
	PJ *PIN = 0;

	errno = pj_errno = 0;
	/* put arguments into internal linked list */
	if (argc <= 0) { pj_errno = -1; goto bum_call; }
	for (i = 0; i < argc; ++i)
		if (i)
			curr = curr->next = pj_mkparam(argv[i]);
		else
			start = curr = pj_mkparam(argv[i]);
	if (pj_errno) goto bum_call;
	/* find projection selection */
	if (!(name = pj_param(start, "sproj").s))
		{ pj_errno = -4; goto bum_call; }
	for (i = 0; (s = pj_list[i].id) && strcmp(name, s) ; ++i) ;
	if (!s) { pj_errno = -5; goto bum_call; }
	proj = pj_list[i].proj;
	/* allocate projection structure */
	if (!(PIN = (*proj)(0))) goto bum_call;
	PIN->params = start;
	/* set ellipsoid/sphere parameters */
	if (pj_ell_set(start, &PIN->a, &PIN->es)) goto bum_call;
	PIN->e = sqrt(PIN->es);
	PIN->ra = 1. / PIN->a;
	PIN->one_es = 1. - PIN->es;
	if (PIN->one_es == 0.) { pj_errno = -6; goto bum_call; }
	PIN->rone_es = 1./PIN->one_es;
	/* set PIN->geoc coordinate system */
	PIN->geoc = (PIN->es && pj_param(start, "bgeoc").i);
	/* over-ranging flag */
	PIN->over = pj_param(start, "bover").i;
	/* central meridian */
	PIN->lam0=pj_param(start, "rlon_0").f;
	/* central latitude */
	PIN->phi0 = pj_param(start, "rlat_0").f;
	/* false easting and northing */
	PIN->x0 = pj_param(start, "dx_0").f;
	PIN->y0 = pj_param(start, "dy_0").f;
	/* general scaling factor */
	if (pj_param(start, "tk_0").i)
		PIN->k0 = pj_param(start, "dk_0").f;
	else if (pj_param(start, "tk").i)
		PIN->k0 = pj_param(start, "dk").f;
	else
		PIN->k0 = 1.;
	if (PIN->k0 <= 0.) {
		pj_errno = -31;
		goto bum_call;
	}
	/* set units */
	s = 0;
	if ((name = pj_param(start, "sunits").s)) { 
		for (i = 0; (s = pj_units[i].id) && strcmp(name, s) ; ++i) ;
		if (!s) { pj_errno = -7; goto bum_call; }
		s = pj_units[i].to_meter;
	}
	if (s || (s = pj_param(start, "sto_meter").s)) {
		PIN->to_meter = strtod(s, (char **)&s);
		if (*s == '/') /* ratio number */
			PIN->to_meter /= strtod(++s, 0);
		PIN->fr_meter = 1. / PIN->to_meter;
	} else
		PIN->to_meter = PIN->fr_meter = 1.;
	/* projection specific initialization */
	if (!(PIN = (*proj)(PIN)) || errno || pj_errno) {
bum_call: /* cleanup error return */
		if (!pj_errno)
			pj_errno = errno;
		if (PIN)
			pj_free(PIN);
		else
			for ( ; start; start = curr) {
				curr = start->next;
				free(start);
			}
		PIN = 0;
	}
	return PIN;
}
	void
pj_free(PJ *P) {
	if (P) {
		paralist *t = P->params, *n;

		/* free parameter list elements */
		for (t = P->params; t; t = n) {
			n = t->next;
			free(t);
		}
		/* free projection parameters */
		P->pfree(P);
	}
}
/* Revision log
** $Log: pj_init.c,v $
** Revision 2.1  2003/03/28 01:44:30  gie
** Initial
**
*/
