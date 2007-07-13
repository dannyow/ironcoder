/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: PJ_fc-loerr.c,v 1.3 2004/02/24 01:07:21 gie Exp gie $";
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
	double C0, C2, C4, CP1, CP3, CP5; \
	int	pointy;
#define PJ_LIB__
#include	<lib_proj.h>
PROJ_HEAD(fc_gen, "General optimization") "\n\tPCyl, Sph., No Inv.";
PROJ_HEAD(fc_pe, "Canters low_error, 1/2 pole length") "\n\tPCyl, Sph., No Inv.";
PROJ_HEAD(fc_ar, "Canters low_error, correct axis ratio") "\n\tPCyl, Sph., No Inv.";
PROJ_HEAD(fc_pp, "Canters low_error, pointed pole") "\n\tPCyl, Sph., No Inv.";

FORWARD(s_forward); /* sphere */
	double phi2 = lp.phi * lp.phi;
	
	xy.x = lp.lam * (P->C0 + phi2 * (P->C2 + phi2 * P->C4));
	xy.y = lp.phi * (P->CP1 + phi2 * (P->CP3 + phi2 * P->CP5));
	if (P->pointy)
		xy.x *= cos(lp.phi);
	return (xy);
}
FREEUP; if (P) free(P); }
	static void
setup(PJ *P) {
	P->es = 0;
	P->fwd = s_forward;
}
ENTRY0(fc_gen)
	P->C0 =   0.7920;
	P->C2 =  -0.0978;
	P->C4 =   0.0059;
	P->CP1 =  1.0304;
	P->CP3 =  0.0127;
	P->CP5 = -0.0250;
	P->pointy = 0;
	setup(P);
ENDENTRY(P)
ENTRY0(fc_pe)
	P->C0 =   0.7879;
	P->C2 =  -0.0238;
	P->C4 =  -0.0551;
	P->CP1 =  1.0370;
	P->CP3 = -0.0059;
	P->CP5 = -0.0147;
	P->pointy = 0;
	setup(P);
ENDENTRY(P)
ENTRY0(fc_ar)
	P->C0 =   0.8378;
	P->C2 =  -0.1053;
	P->C4 =  -0.0011;
	P->CP1 =  1.0150;
	P->CP3 =  0.0207;
	P->CP5 = -0.0375;
	P->pointy = 0;
	setup(P);
ENDENTRY(P)
ENTRY0(fc_pp)
	P->C0 =   0.8333;
	P->C2 =  -0.3385;
	P->C4 =   0.0942;
	P->CP1 =  1.0114;
	P->CP3 =  0.0243;
	P->CP5 = -0.0391;
	P->pointy = 1;
	setup(P);
ENDENTRY(P)
/*
** $Log: PJ_fc-loerr.c,v $
** Revision 1.3  2004/02/24 01:07:21  gie
** corrected pointed multiplier
**
** Revision 1.2  2004/02/23 22:03:43  gie
** corrected coefficient const sign for pp
**
** Revision 1.1  2004/02/22 21:30:29  gie
** Initial revision
**
*/
