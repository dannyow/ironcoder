/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_sts.c,v 2.6 2005/03/06 17:40:30 gie Exp gie $";
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
	double C_x, C_y, C_p; \
	int tan_mode;
#define PJ_LIB__
# include	<lib_proj.h>
PROJ_HEAD(kav5, "Kavraisky V") "\n\tPCyl., Sph.";
PROJ_HEAD(qua_aut, "Quartic Authalic") "\n\tPCyl., Sph.";
PROJ_HEAD(mbt_s, "McBryde-Thomas Sine (No. 1)") "\n\tPCyl., Sph.";
PROJ_HEAD(fouc, "Foucaut") "\n\tPCyl., Sph.";
PROJ_HEAD(gen_ts, "General Sine-Tangent") "\n\tPCyl., Sph.\n\t+t|+s +p= +q=";
/* sqrt(PI) */
#define SQPI 1.772453850905516027298167483 
FORWARD(s_forward); /* spheroid */
	double c;

	xy.x = P->C_x * lp.lam * cos(lp.phi);
	xy.y = P->C_y;
	lp.phi *= P->C_p;
	c = cos(lp.phi);
	if (P->tan_mode) {
		xy.x *= c * c;
		xy.y *= tan(lp.phi);
	} else {
		xy.x /= c;
		xy.y *= sin(lp.phi);
	}
	return (xy);
}
INVERSE(s_inverse); /* spheroid */
	double c;
	
	xy.y /= P->C_y;
	c = cos(lp.phi = P->tan_mode ? atan(xy.y) : pj_asin(xy.y));
	lp.lam = xy.x / (P->C_x * cos(lp.phi /= P->C_p));
	if (P->tan_mode)
		lp.lam /= c * c;
	else
		lp.lam *= c;
	return (lp);
}
FREEUP; if (P) free(P); }
	static PJ *
setup(PJ *P, double p, double q, int mode) {
	P->es = 0.;
	P->inv = s_inverse;
	P->fwd = s_forward;
	P->C_x = q / p;
	P->C_y = p;
	P->C_p = 1/ q;
	P->tan_mode = mode;
	return P;
}
ENTRY0(kav5) ENDENTRY(setup(P, 1.50488, 1.35439, 0))
ENTRY0(qua_aut) ENDENTRY(setup(P, 2., 2., 0))
ENTRY0(mbt_s) ENDENTRY(setup(P, 1.48875, 1.36509, 0))
ENTRY0(fouc) ENDENTRY(setup(P, SQPI, 2., 1))
ENTRY0(gen_ts)
	double p, q;
	int mode;

	mode = pj_param(P->params, "tt").i;
	if (!mode && !pj_param(P->params, "ts").i)
		E_ERROR(-48)
	if (!pj_param(P->params, "tp").i || !pj_param(P->params, "tq").i)
		E_ERROR(-49)
	p = pj_param(P->params, "dp").f;
	q = pj_param(P->params, "dq").f;
	(void)setup(P, p, q, mode);
ENDENTRY(P)
/*
** $Log: PJ_sts.c,v $
** Revision 2.6  2005/03/06 17:40:30  gie
** re-corrected p factor for Foucout
**
** Revision 2.5  2005/02/26 19:32:54  gie
** added general input type
**
** Revision 2.4  2005/01/21 01:21:34  gie
** correct nomenclature of name
**
** Revision 2.3  2003/06/19 02:01:03  gie
** corrected p in foucaut
**
** Revision 2.2  2003/04/07 19:28:38  gie
** Corrected Foucout constant from sqrt(pi) to 2*sqrt(pi)
**
** Revision 2.1  2003/03/28 01:46:52  gie
** Initial
**
*/
