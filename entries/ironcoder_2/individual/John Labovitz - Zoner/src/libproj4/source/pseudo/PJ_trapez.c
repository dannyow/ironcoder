/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2005   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_trapez.c,v 1.1 2005/02/10 20:07:51 gie Exp gie $";
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
#define PROJ_PARMS__ \
	double N0, N1;
# include	<lib_proj.h>
PROJ_HEAD(trapez, "Trapezoidal") "\n\tPCyl., Sph.\n\tlat_1= lat_2=";
FORWARD(s_forward); /* spheroid */

	xy.x = lp.lam * (lp.phi * P->N1 - P->N0);
	xy.y = lp.phi - P->phi0;
	return (xy);
}
INVERSE(s_inverse); /* spheroid */

	lp.phi = xy.y + P->phi0;
	lp.lam = xy.x / (lp.phi * P->N1 - P->N0);
	return (lp);
}
FREEUP; if (P) free(P); }
ENTRY0(trapez)
	if (pj_param(P->params, "tlat_1").i && pj_param(P->params, "tlat_2").i) {
		double phi1, phi2, cp1, cp2, d;

		cp1 = cos(phi1 = pj_param(P->params, "rlat_1").f);
		cp2 = cos(phi2 = pj_param(P->params, "rlat_2").f);
		if ((d = phi1- phi2) == 0)
			E_ERROR(-33)
		P->N1 = (cp1 - cp2)/d;
		P->N0 = (phi2 * cp1 - phi1 * cp2)/d;
	} else
		E_ERROR(-41)
	P->es = 0.;
	P->fwd = s_forward;
	P->inv = s_inverse;
ENDENTRY(P)
/*
** $Log: PJ_trapez.c,v $
** Revision 1.1  2005/02/10 20:07:51  gie
** Initial revision
**
*/
