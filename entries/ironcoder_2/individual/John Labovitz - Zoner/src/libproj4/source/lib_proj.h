/* General projections header file */
/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003, 2005   Gerald I. Evenden
**
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

#ifndef PROJECTS_H
#define PROJECTS_H

/* LIBPROJ4 Cartographic Projection Library -- Revision Log:
** $Log: lib_proj.h,v $
** Revision 2.5  2005/02/03 17:33:54  gie
** update date
**
** Revision 2.4  2003/07/03 16:26:26  gie
** removed transverse
**
** Revision 2.3  2003/07/03 16:06:25  gie
** updates and corrections
**
** Revision 2.2  2003/04/22 00:23:25  gie
** general updating
**
** Revision 2.1  2003/03/28 15:37:48  gie
** Initial
**
*/
    /* standard inclusions */
#include <math.h>
#include <stdlib.h>
	/* some useful constants */
#define HALFPI		1.5707963267948966
#define FORTPI		0.78539816339744833
#ifndef PI
#define PI		3.14159265358979323846
#endif
#define TWOPI		6.2831853071795864769
#define RAD_TO_DEG	57.29577951308232
#define DEG_TO_RAD	.0174532925199432958

typedef struct { double u, v; }	UV;
typedef struct { double r, i; }	COMPLEX;

#ifdef PROJ_UV_TYPE
#define XY UV
#define LP UV
#else
typedef struct { double x, y; }     XY;
typedef struct { double lam, phi; } LP;
#endif

	extern int		/* global error return code */
pj_errno;

typedef union { double  f; int  i; const char *s; } PVALUE;

struct PJ_ELLPS {
	char	*id;	/* ellipse keyword name */
	char	*major;	/* a= value */
	char	*ell;	/* elliptical parameter */
	char	*name;	/* comments */
};
struct PJ_UNITS {
	char	*id;	/* units keyword */
	char	*to_meter;	/* multiply by value to get meters */
	char	*name;	/* comments */
};
struct DERIVS {
		double x_l, x_p; /* derivatives of x for lambda-phi */
		double y_l, y_p; /* derivatives of y for lambda-phi */
};
struct FACTORS {
	struct DERIVS der;
	double h, k;	/* meridinal, parallel scales */
	double omega, thetap;	/* angular distortion, theta prime */
	double conv;	/* convergence */
	double s;		/* areal scale factor */
	double a, b;	/* max-min scale error */
	int code;		/* info as to analytics, see following */
};
#define IS_ANAL_XL_YL 01	/* derivatives of lon analytic */
#define IS_ANAL_XP_YP 02	/* derivatives of lat analytic */
#define IS_ANAL_HK	04		/* h and k analytic */
#define IS_ANAL_CONV 010	/* convergence analytic */
    /* parameter list struct */
typedef struct ARG_list {
	struct ARG_list *next;
	char used;
	char param[1]; } paralist;
	/* base projection data structure */
typedef struct PJconsts {
	XY  (*fwd)(LP, struct PJconsts *);
	LP  (*inv)(XY, struct PJconsts *);
	void (*spc)(LP, struct PJconsts *, struct FACTORS *);
	void (*pfree)(struct PJconsts *);
	const char *descr;
	paralist *params;   /* parameter list */
	int over;   /* over-range flag */
	int geoc;   /* geocentric latitude flag */
	double
		a,  /* major axis or radius if es==0 */
		e,  /* eccentricity */
		es, /* e ^ 2 */
		ra, /* 1/A */
		one_es, /* 1 - e^2 */
		rone_es, /* 1/one_es */
		lam0, phi0, /* central longitude, latitude */
		x0, y0, /* easting and northing */
		k0,	/* general scaling factor */
		to_meter, fr_meter; /* cartesian scaling */
#ifdef PROJ_PARMS__
PROJ_PARMS__
#endif /* end of optional extensions */
} PJ;

struct PJ_LIST {
	char	*id;		/* projection keyword */
	PJ		*(*proj)(PJ *);	/* projection entry point */
	char 	* const *descr;	/* description text */
};

/* Generate pj_list external or make list from include file */
#ifndef PJ_LIST_H
extern struct PJ_LIST pj_list[];
#else
#define PROJ_HEAD(id, name) \
	extern PJ *pj_##id(PJ *); extern char * const pj_s_##id;
#include PJ_LIST_H
#undef PROJ_HEAD
#define PROJ_HEAD(id, name) {#id, pj_##id, &pj_s_##id},
	struct PJ_LIST
pj_list[] = {
#include PJ_LIST_H
		{0,     0,  0},
	};
#undef PROJ_HEAD
#endif

#ifndef PJ_ELLPS__
extern struct PJ_ELLPS pj_ellps[];
#endif

#ifndef PJ_UNITS__
extern struct PJ_UNITS pj_units[];
#endif

#ifdef PJ_LIB__
    /* repeatative projection code */
#define PROJ_HEAD(id, name) static const char des_##id [] = name
#define ENTRYA(name) const char * const pj_s_##name = des_##name; \
	PJ *pj_##name(PJ *P) { if (!P) { \
	if ((P = (PJ *)malloc(sizeof(PJ)))) { \
	P->pfree = freeup; P->fwd = 0; P->inv = 0; \
	P->spc = 0; P->descr = des_##name;
#define ENTRYX } return P; } else {
#define ENTRY0(name) ENTRYA(name) ENTRYX
#define ENTRY1(name, a) ENTRYA(name) P->a = 0; ENTRYX
#define ENTRY2(name, a, b) ENTRYA(name) P->a = 0; P->b = 0; ENTRYX
#define ENDENTRY(p) } return (p); }
#define E_ERROR(err) { pj_errno = err; freeup(P); return(0); }
#define E_ERROR_0 { freeup(P); return(0); }
#define F_ERROR { pj_errno = -20; return(xy); }
#define I_ERROR { pj_errno = -20; return(lp); }
#define FORWARD(name) static XY name(LP lp, PJ *P) { XY xy={0.,0.}
#define INVERSE(name) static LP name(XY xy, PJ *P) { LP lp={0.,0.}
#define FREEUP static void freeup(PJ *P) {
#define SPECIAL(name) static void name(LP lp, PJ *P, struct FACTORS *fac)
#endif
	/* procedure prototypes */
double  pj_dmstor(const char *, char **);
void pj_set_rtodms(int, int);
char *pj_rtodms(char *, double, const char *);
double pj_adjlon(double);
double pj_acos(double), pj_asin(double), pj_sqrt(double),
	pj_atan2(double, double);
PVALUE pj_param(paralist *, const char *);
paralist *pj_mkparam(char *);
int pj_ell_set(paralist *, double *, double *);
void *pj_mdist_ini(double);
double pj_mdist(double, double, double, const void *);
double pj_inv_mdist(double, const void *);
void *pj_gauss_ini(double, double, double *,double *);
LP pj_gauss(LP, const void *);
LP pj_inv_gauss(LP, const void *);
LP pj_translate(LP, const void *);
LP pj_inv_translate(LP, const void *);
void *pj_translate_ini(double, double);
double pj_tsfn(double, double, double);
double pj_msfn(double, double, double);
double pj_phi2(double, double);
double pj_qsfn(double, const void *);
void *pj_auth_ini(double, double *);
double pj_auth_lat(double, const void *);
double pj_auth_inv(double, const void *);
COMPLEX pj_zpoly1(COMPLEX, COMPLEX *, int);
COMPLEX pj_zpolyd1(COMPLEX, COMPLEX *, int, COMPLEX *);
int pj_deriv(LP, double, PJ *, struct DERIVS *);
int pj_factors(LP, PJ *, double, struct FACTORS *);
XY pj_fwd(LP, PJ *);
LP pj_inv(XY, PJ *);
void pj_pr_list(PJ *);
void pj_free(PJ *);
PJ *pj_init(int, char **);
char *pj_strerrno(int);

#endif /* end of basic projections header */
/*
** $Log: lib_proj.h,v $
** Revision 2.5  2005/02/03 17:33:54  gie
** update date
**
** Revision 2.4  2003/07/03 16:26:26  gie
** removed transverse
**
** Revision 2.3  2003/07/03 16:06:25  gie
** updates and corrections
**
** Revision 2.2  2003/04/22 00:23:25  gie
** general updating
**
** Revision 2.1  2003/03/28 15:37:48  gie
** Initial
**
*/
