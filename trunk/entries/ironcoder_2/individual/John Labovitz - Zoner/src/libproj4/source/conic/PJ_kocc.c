/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_kocc.c,v 2.1 2003/03/28 01:46:13 gie Distr. gie $";
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
	void	*en, *en2; \
	double phi1; \
	double phit; \
	double n, kRF; \
	int czech;
#define PJ_LIB__
#include	<lib_proj.h>
PROJ_HEAD(kocc, "Krovak Oblique Conformal Conic")
	"\n\tConic, Sph&Ell\n\tlat_1= lat_t=";

FORWARD(e_forward); /* ellipsoid */
	double rho, theta;

	lp = pj_translate(pj_gauss(lp, P->en), P->en2);
	rho = P->kRF / pow(tan(.5 * lp.phi + FORTPI), P->n);
	theta = P->n * lp.lam;
	if (P->czech) {	/* Czech grid mode */
		xy.x = rho * cos(theta);
		xy.y = - rho * sin(theta);
	} else { /* proper math mode */
		xy.x = rho * sin(theta);
		xy.y = - rho * cos(theta);
	}
	return (xy);
}
INVERSE(e_inverse); /* ellipsoid */
	double x, y, rho, theta;

	if (P->czech) {
		x = -xy.y;
		y = -xy.x;
	} else {
		x = xy.x;
		y = xy.y;
	}
	rho = hypot(x, y);
	if (P->n < 0) rho = - rho;
	theta = atan2(x, -y);
	lp.phi = 2. * atan(pow(P->kRF / rho, 1./P->n)) - HALFPI;
	lp.lam = theta / P->n;
	return (pj_inv_gauss(pj_inv_translate(lp, P->en2), P->en));
}
FREEUP; if (P) {
	if (P->en) free(P->en);
	if (P->en2) free(P->en2);
	free(P);
	}
}
ENTRY0(kocc)
	double Rc, chi;

	P->czech = pj_param(P->params, "tczech").i;
	P->phi1 = pj_param(P->params, "rlat_1").f;
	P->phit = pj_param(P->params, "rlat_t").f;
	if (!(P->en = pj_gauss_ini(P->e, P->phi0, &chi, &Rc))) E_ERROR_0;
	if (!(P->en2 = pj_translate_ini(PI + P->phit, 0.))) E_ERROR_0;
	P->n = sin(P->phi1);
	P->kRF = P->k0 * Rc * cos(P->phi1) *
		pow(tan(0.5 * P->phi1 + FORTPI) , P->n) / P->n;
	P->inv = e_inverse;
	P->fwd = e_forward;
ENDENTRY(P)
/*
** $Log: PJ_kocc.c,v $
** Revision 2.1  2003/03/28 01:46:13  gie
** Initial
**
*/
