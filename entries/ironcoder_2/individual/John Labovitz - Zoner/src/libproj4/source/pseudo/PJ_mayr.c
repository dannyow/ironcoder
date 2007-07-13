/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_mayr.c,v 1.4 2004/12/14 01:45:24 gie Exp gie $";
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
#define N_TOL 1e-6
#define PJ_LIB__
#ifdef PJ_GSL_LIB
#include <gsl/gsl_integration.h>
#define GSL_WORK 1000
#define PROJ_PARMS__ \
	double n[2]; \
	gsl_function func; \
	gsl_integration_workspace *work; \
	int mode;
#include	<lib_proj.h>
	static double
mayr_kernel(double x, double *n) {
	return (pow(cos(x), n[0]));
}
#else
#define PROJ_PARMS__ \
	int mode;
#include	<lib_proj.h>
#endif
PROJ_HEAD(mayr, "Mayr (Tobler Meridian  Geometric Mean)") "\n\tPCyl., Sph., NoInv.";
/* definition of segment bounds for <1e-7 error (unit sphere)  */
#define SEG1 1.4
#define SEG2 1.55
#define SEG3 1.57
#define BASE1 1.151132004484049
#define BASE2 1.196140916241303
#define BASE3 1.19812525384759
#define HALFN 4
/* Gauss Legendre weights/abscissa */
double X[] = {
    0.96028985649753618,
    0.79666647741362673,
    0.52553240991632899,
    0.18343464249564981 };
double W[] = {
    0.10122853629037638,
    0.22238103445337443,
    0.31370664587788744,
    0.36268378337836199 };
/* Mayr kernel */
#define func(v) sqrt(cos(v))
	static
double gauss_legendre(double x0, double x1) {
	int i = 0;
	double s = 0., *x = X,	*w = W, xsize, xmean, arg;

	xmean = 0.5 * (x1 + x0);
	xsize = 0.5 * (x1 - x0);
	while ( i++ < HALFN ) {
		arg = xsize * *x++;
		s += *w++ * (func(xmean - arg) + func(xmean + arg));
	};
	return xsize * s;
}
	static
double integrate(double val) {
	double out;

	if (val <= SEG1)
		out = gauss_legendre(0., val);
	else if (val <= SEG2)
		out = BASE1 + gauss_legendre(SEG1, val);
	else if (val <= SEG3)
		out = BASE2 + gauss_legendre(SEG2, val);
	else
		out = BASE3 + gauss_legendre(SEG3, val);
	return out;
}
FORWARD(s_forward); /* spheroid */

	xy.x = lp.lam * func(lp.phi);
	xy.y = integrate(fabs(lp.phi));
	if (lp.phi < 0.)
		xy.y = -xy.y;
	return (xy);
}
#ifdef PJ_GSL_LIB
FORWARD(s_forwardg); /* numerical integration n <> 0.5 */
	double error;
	
	gsl_integration_qags(&P->func, 0., fabs(lp.phi), 1e-7, 1e-8, GSL_WORK,
		P->work, &xy.y, &error);
	xy.x = lp.lam * pow(cos(lp.phi), P->n[1]);
	if (lp.phi < 0.)
		xy.y = -xy.y;
	return (xy);
}
#endif
FREEUP;
	if (P) {
#ifdef PJ_GSL_LIB
		if (P->mode) 
			gsl_integration_workspace_free(P->work);
#endif
		free(P);
	}
}
ENTRY0(mayr)
	P->es = 0;
	if (pj_param(P->params, "tn").i) {
#ifdef PJ_GSL_LIB
		P->n[0] = pj_param(P->params, "dn").f;
		if ((P->n[0] < N_TOL) || (P->n[0] > 1.-N_TOL))
			E_ERROR(-40)
		P->fwd = s_forwardg;
		P->n[1] = 1. - P->n[0];
		P->func.function = &mayr_kernel;
		P->func.params = P->n;
		P->work = gsl_integration_workspace_alloc (GSL_WORK);
		P->mode = 1;
#else
		E_ERROR(-47)
#endif
	} else {
		P->mode = 0;
		P->fwd = s_forward;
	}
ENDENTRY(P)
/*
** $Log: PJ_mayr.c,v $
** Revision 1.4  2004/12/14 01:45:24  gie
** goomba error corrected
**
** Revision 1.3  2004/12/14 01:34:06  gie
** added general range code
**
** Revision 1.2  2004/12/06 19:10:28  gie
** correct if else if conditions
**
** Revision 1.1  2004/12/06 17:36:39  gie
** Initial revision
**
*/
