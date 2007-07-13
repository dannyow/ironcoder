/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_gn_sinu.c,v 2.2 2003/06/20 21:03:34 gie Exp gie $";
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
	void	*en; \
	double	m, n, C_x, C_y;
#define PJ_LIB__
#include	<lib_proj.h>
PROJ_HEAD(gn_sinu, "General Sinusoidal Series") "\n\tPCyl, Sph.\n\tm= n=";
PROJ_HEAD(sinu, "Sinusoidal (Sanson-Flamsteed)") "\n\tPCyl, Sph&Ell";
PROJ_HEAD(eck6, "Eckert VI") "\n\tPCyl, Sph.";
PROJ_HEAD(mbtfps, "McBryde-Thomas Flat-Polar Sinusoidal") "\n\tPCyl, Sph.";
#define EPS10	1e-10
#define MAX_ITER 8
#define LOOP_TOL 1e-7
/* Ellipsoidal Sinusoidal only */
FORWARD(e_forward); /* ellipsoid */
	double s, c;

	xy.y = pj_mdist(lp.phi, s = sin(lp.phi), c = cos(lp.phi), P->en);
	xy.x = lp.lam * pj_msfn(s, c, P->es);
	return (xy);
}
INVERSE(e_inverse); /* ellipsoid */
	double s;

	if ((s = fabs(lp.phi = pj_inv_mdist(xy.y, P->en))) < HALFPI)
		lp.lam = xy.x / pj_msfn(sin(lp.phi), cos(lp.phi), P->es);
	else if ((s - EPS10) < HALFPI)
		lp.lam = 0.;
	else I_ERROR;
	return (lp);
}
/* General spherical sinusoidals */
FORWARD(s_forward); /* sphere */
	if (!P->m)
		lp.phi = P->n != 1. ? pj_asin(P->n * sin(lp.phi)): lp.phi;
	else {
		double k, V;
		int i;

		k = P->n * sin(lp.phi);
		for (i = MAX_ITER; i ; --i) {
			lp.phi -= V = (P->m * lp.phi + sin(lp.phi) - k) /
				(P->m + cos(lp.phi));
			if (fabs(V) < LOOP_TOL)
				break;
		}
		if (!i)
			F_ERROR
	}
	xy.x = P->C_x * lp.lam * (P->m + cos(lp.phi));
	xy.y = P->C_y * lp.phi;
	return (xy);
}
INVERSE(s_inverse); /* sphere */

	xy.y /= P->C_y;
	lp.phi = P->m ? pj_asin((P->m * xy.y + sin(xy.y)) / P->n) :
		( P->n != 1. ? pj_asin(sin(xy.y) / P->n) : xy.y );
	lp.lam = xy.x / (P->C_x * (P->m + cos(xy.y)));
	return (lp);
}
FREEUP; if (P) { if (P->en) free(P->en); free(P); } }
	static void /* for spheres, only */
setup(PJ *P) {
	P->es = 0;
	P->C_x = (P->C_y = sqrt((P->m + 1.) / P->n))/(P->m + 1.);
	P->inv = s_inverse;
	P->fwd = s_forward;
}
ENTRY1(sinu, en)
	
	if (P->es) {
		if (!((P->en = pj_mdist_ini(P->es))))
			E_ERROR_0;
		P->inv = e_inverse;
		P->fwd = e_forward;
	} else {
		P->en = (void *)0;
		P->n = 1.;
		P->m = 0.;
		setup(P);
	}
ENDENTRY(P)
ENTRY1(eck6, en)
	P->m = 1.;
	P->n = 2.570796326794896619231321691;
	setup(P);
ENDENTRY(P)
ENTRY1(mbtfps, en)
	P->m = 0.5;
	P->n = 1.785398163397448309615660845;
	setup(P);
ENDENTRY(P)
ENTRY1(gn_sinu, en)
	if (pj_param(P->params, "tn").i && pj_param(P->params, "tm").i) {
		P->n = pj_param(P->params, "dn").f;
		P->m = pj_param(P->params, "dm").f;
	} else
		E_ERROR(-99)
	setup(P);
ENDENTRY(P)
/*
** $Log: PJ_gn_sinu.c,v $
** Revision 2.2  2003/06/20 21:03:34  gie
** shortened elliptical sinusoidal code
**
** Revision 2.1  2003/03/28 01:46:51  gie
** Initial
**
*/
