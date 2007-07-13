# Makefile for basic compilation of libproj4 software
#
# libproj4 -- library of cartographic projections
#
# Copyright (c) 2003, 2005   Gerald I. Evenden
#
# "$Id: Makefile,v 2.11 2005/03/09 02:59:44 gie Exp gie $";
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
#  The following is a site dependent, edittable section

prefix = /usr/local

# edit to reflect directory where system defaults and inits are located
LIB = $(prefix)/lib
BIN = $(prefix)/bin
INC = $(prefix)/include

# remove comment from following line to use GSL library
#GSL=1

# select local compiler to use
CC = gcc

# normally set on runline when debugging or testing file
T =

#------------- end of editables ----------------------------

L = libproj4.a

.PRECIOUS: $L

LAZ = \
	$L(azimuthal/PJ_aeqd.o) $L(azimuthal/PJ_gnom.o) $L(azimuthal/PJ_laea.o) \
	$L(azimuthal/PJ_mod_ster.o) $L(azimuthal/PJ_nsper.o) \
	$L(azimuthal/PJ_nzmg.o) $L(azimuthal/PJ_ortho.o) \
	$L(azimuthal/PJ_sterea.o) $L(azimuthal/PJ_stere.o) \
	$L(azimuthal/PJ_rouss.o) $L(azimuthal/PJ_geos.o) \
	$L(azimuthal/PJ_aitoff.o) $L(azimuthal/PJ_wag7.o) \
	$L(azimuthal/PJ_hammer.o) $L(azimuthal/PJ_wag9.o) \
	$L(azimuthal/PJ_gilbert.o)

LCO = \
	$L(conic/PJ_aea.o) $L(conic/PJ_bipc.o) $L(conic/PJ_bonne.o) \
	$L(conic/PJ_eqdc.o) $L(conic/PJ_imw_p.o) $L(conic/PJ_kocc.o) \
	$L(conic/PJ_lcca.o) $L(conic/PJ_lcc.o) $L(conic/PJ_hall.o) \
	$L(conic/PJ_poly.o) $L(conic/PJ_rpoly.o) $L(conic/PJ_sconics.o)

LCY = \
	$L(cylinder/PJ_cass.o) $L(cylinder/PJ_cc.o) $L(cylinder/PJ_cea.o) \
	$L(cylinder/PJ_eqc.o) $L(cylinder/PJ_cyl_stere.o) $L(cylinder/PJ_labrd.o) \
	$L(cylinder/PJ_lsat.o) $L(cylinder/PJ_merc.o) $L(cylinder/PJ_mill.o) \
	$L(cylinder/PJ_ocea.o) $L(cylinder/PJ_omerc.o) \
	$L(cylinder/PJ_somerc.o) $L(cylinder/PJ_tcc.o) $L(cylinder/PJ_tcea.o) \
	$L(cylinder/PJ_tmerc.o) $L(cylinder/PJ_braun2.o) $L(cylinder/PJ_cen_cyl) \
	$L(cylinder/PJ_ardn_cls.o) $L(cylinder/PJ_cubic.o) \
	$L(cylinder/PJ_tob_sqr.o) $L(cylinder/PJ_mill_per.o) \
	$L(cylinder/PJ_mill_2.o) $L(cylinder/PJ_stmerc.o)

LMI = \
	$L(misc/PJ_airy.o) $L(misc/PJ_august.o) $L(misc/PJ_armadillo.o) \
	$L(misc/PJ_bacon.o) $L(misc/PJ_chamb.o) $L(misc/PJ_guyou.o) \
	$L(misc/PJ_lagrng.o) $L(misc/PJ_larr.o) $L(misc/PJ_lask.o) \
	$L(misc/PJ_nocol.o) $L(misc/PJ_ob_tran.o) $L(misc/PJ_oea.o) \
	$L(misc/PJ_tpeqd.o) $L(misc/PJ_vandg2.o) $L(misc/PJ_vandg4.o) \
	$L(misc/PJ_vandg.o) $L(misc/PJ_dummy.o) $L(misc/PJ_apian2.o) \
	$L(misc/PJ_four1.o) $L(misc/PJ_eisen.o)

LPS = \
	$L(pseudo/PJ_boggs.o) $L(pseudo/PJ_collg.o) $L(pseudo/PJ_crast.o) \
	$L(pseudo/PJ_denoy.o) $L(pseudo/PJ_eck1.o) $L(pseudo/PJ_eck2.o) \
	$L(pseudo/PJ_eck3.o) $L(pseudo/PJ_eck4.o) $L(pseudo/PJ_eck5.o) \
	$L(pseudo/PJ_fahey.o) $L(pseudo/PJ_fouc_s.o) $L(pseudo/PJ_gins8.o) \
	$L(pseudo/PJ_gn_sinu.o) $L(pseudo/PJ_goode.o) $L(pseudo/PJ_hatano.o) \
	$L(pseudo/PJ_loxim.o) $L(pseudo/PJ_mbtfpp.o) $L(pseudo/PJ_mbtfpq.o) \
	$L(pseudo/PJ_mbt_fps.o) $L(pseudo/PJ_moll.o) $L(pseudo/PJ_nell.o) \
	$L(pseudo/PJ_nell_h.o) $L(pseudo/PJ_oxford.o) $L(pseudo/PJ_putp2.o) \
	$L(pseudo/PJ_putp3.o) $L(pseudo/PJ_putp4p.o) $L(pseudo/PJ_putp5.o) \
	$L(pseudo/PJ_putp6.o) $L(pseudo/PJ_robin.o) $L(pseudo/PJ_sts.o) \
	$L(pseudo/PJ_urm5.o) $L(pseudo/PJ_urmfps.o) $L(pseudo/PJ_wag2.o) \
	$L(pseudo/PJ_wag3.o) $L(pseudo/PJ_wink1.o) $L(pseudo/PJ_wink2.o) \
	$L(pseudo/PJ_equi_moll.o) $L(pseudo/PJ_erdi_ksz.o) \
	$L(pseudo/PJ_fc-loerr.o) $L(pseudo/PJ_maurer.o) $L(pseudo/PJ_mcb_s3.o) \
	$L(pseudo/PJ_semiconf.o) $L(pseudo/PJ_s_min_err.o) \
	$L(pseudo/PJ_baranyi4.o) $L(pseudo/PJ_holzel.o) $L(pseudo/PJ_wag5.o) \
	$L(pseudo/PJ_four2.o) $L(pseudo/PJ_mayr.o) $L(pseudo/PJ_tob_g1.o) \
	$L(pseudo/PJ_baker.o) $L(pseudo/PJ_baranyi.o) $L(pseudo/PJ_trapez.o)

LSU = \
	$L(support/pj_adjlon.o) $L(support/pj_auth.o) $L(support/pj_dmstor.o) \
	$L(support/pj_ellps.o) $L(support/pj_ell_set.o) $L(support/pj_errno.o) \
	$L(support/pj_fwd.o) $L(support/pj_gauss.o) $L(support/pj_init.o) \
	$L(support/pj_inv.o) $L(support/pj_list.o) $L(support/pj_mdist.o) \
	$L(support/pj_msfn.o) $L(support/pj_param.o) $L(support/pj_phi2.o) \
	$L(support/pj_strerrno.o) $L(support/pj_trans.o) \
	$L(support/pj_tsfn.o) $L(support/pj_units.o) $L(support/pj_zpoly1.o) \
	$L(support/pj_factors.o) $L(support/pj_deriv.o) $L(support/pj_pr_list.o) \
	$L(support/pj_translate.o) $L(support/pj_rtodms.o)

RLIB = $(LAZ) $(LCO) $(LCY) $(LMI) $(LPS) $(LSU)

CFLAGS = -O -I./  $(LDEF)

CFLAGS += -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch ppc -arch i386
LDFLAGS += -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch ppc -arch i386

ifdef GSL
GSL_LIB = -lgsl -lgslcblas
CPPFLAGS = -DPJ_GSL_LIB
endif

LPROJ=lproj.o emess.o

lproj: $(LPROJ) $T $L
	$(CC) -o lproj -I./ $(LPROJ) $T -L./ -lproj4 $(GSL_LIB) -lm 

$(LPROJ): lib_proj.h lproj.h

libproj4: $(RLIB)
	if [ -f /usr/bin/ranlib -o -f /bin/ranlib ] ; then ranlib $L ; fi

$(RLIB): lib_proj.h
support/pj_list.o: pj_list.h

all: libproj4

install:
	install libproj4.a $(LIB)
	install lproj $(BIN)
	install lib_proj.h $(INC)

clean:
	/bin/rm -f core *.o

veryclean:
	/bin/rm -f core *.o lproj libproj4.a

$(RLIB) : lib_proj.h
#
# $Log: Makefile,v $
# Revision 2.11  2005/03/09 02:59:44  gie
# updated
#
# Revision 2.10  2005/02/04 16:08:38  gie
# corrected ".a" on install libproj4
#
# Revision 2.9  2005/02/04 01:54:40  gie
# generalized and added install lines
#
# Revision 2.8  2005/02/03 17:38:30  gie
# added projections and control
#
# Revision 2.7  2004/07/14 15:45:01  gie
# new projections
#
# Revision 2.6  2004/03/05 21:28:42  gie
# additional projections
# ls
#
# Revision 2.5  2004/02/21 18:58:44  gie
# changed to .4 on many references
#
# Revision 2.4  2003/07/14 14:37:34  gie
# removed unused projection from list
#
# Revision 2.3  2003/07/03 16:12:11  gie
# improvements and corrections
#
# Revision 2.2  2003/04/22 00:22:21  gie
# update module list
#
# Revision 2.1  2003/03/28 15:37:20  gie
# Initial
#
