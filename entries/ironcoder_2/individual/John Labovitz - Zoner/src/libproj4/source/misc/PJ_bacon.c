/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_bacon.c,v 2.2 2005/02/03 16:44:00 gie Exp gie $";
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
# define HLFPI2	2.46740110027233965467
# define EPS	1e-10
#define PROJ_PARMS__ \
	int bacn; \
	int ortl;
#define PJ_LIB__
#include	<lib_proj.h>
PROJ_HEAD(apian1, "Apian Globular I") "\n\tMisc Sph, no inv.";
PROJ_HEAD(ortel, "Ortelius Oval") "\n\tMisc Sph, no inv.";
PROJ_HEAD(bacon, "Bacon Globular") "\n\tMisc Sph, no inv.";
FORWARD(s_forward); /* spheroid */
	double ax, f;

	xy.y = P->bacn ? HALFPI * sin(lp.phi) : lp.phi;
	if ((ax = fabs(lp.lam)) >= EPS) {
		if (P->ortl && ax >= HALFPI)
			xy.x = sqrt(HLFPI2 - lp.phi * lp.phi + EPS) + ax - HALFPI;
		else {
			f = 0.5 * (HLFPI2 / ax + ax);
			xy.x = ax - f + sqrt(f * f - xy.y * xy.y);
		}
		if (lp.lam < 0.) xy.x = - xy.x;
	} else
		xy.x = 0.;
	return (xy);
}
FREEUP; if (P) free(P); }
ENTRY0(bacon)
	P->bacn = 1;
	P->ortl = 0;
	P->es = 0.; P->fwd = s_forward;
ENDENTRY(P)
ENTRY0(apian1)
	P->bacn = P->ortl = 0;
	P->es = 0.; P->fwd = s_forward;
ENDENTRY(P)
ENTRY0(ortel)
	P->bacn = 0;
	P->ortl = 1;
	P->es = 0.; P->fwd = s_forward;
ENDENTRY(P)
/*
** $Log: PJ_bacon.c,v $
** Revision 2.2  2005/02/03 16:44:00  gie
** revised name of Apian 1
**
** Revision 2.1  2003/03/28 01:46:39  gie
** Initial
**
*/
