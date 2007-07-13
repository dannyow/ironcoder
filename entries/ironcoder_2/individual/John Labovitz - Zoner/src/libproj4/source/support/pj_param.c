/*
** libproj -- library of cartographic projections
**
** Copyright (c) 2003   Gerald I. Evenden
*/
static const char
LIBPROJ_ID[] = "$Id: pj_param.c,v 2.1 2003/03/28 01:44:30 gie Distr. gie $";
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
#include <lib_proj.h>
#include <stdio.h>
#include <string.h>
	paralist * /* create parameter list entry */
pj_mkparam(char *str) {
	paralist *New;

	if ((New = (paralist *) malloc(sizeof(paralist) + strlen(str)))) {
		New->used = 0;
		New->next = 0;
		if (*str == '+')
			++str;
		(void)strcpy(New->param, str);
	}
	return New;
}
	PVALUE /* test for presence or get parameter value */
pj_param(paralist *pl, const char *opt) {
	int type;
	unsigned l;
	PVALUE value;

	type = *opt++;
	/* simple linear lookup */
	l = strlen(opt);
	while (pl && !(!strncmp(pl->param, opt, l) &&
	  (!pl->param[l] || pl->param[l] == '=')))
		pl = pl->next;
	if (type == 't')
		value.i = pl != 0;
	else if (pl) {
		pl->used |= 1;
		opt = pl->param + l;
		if (*opt == '=')
			++opt;
		switch (type) {
		case 'i':	/* integer input */
			value.i = atoi(opt);
			break;
		case 'd':	/* simple real input */
			value.f = atof(opt);
			break;
		case 'r':	/* degrees input */
			value.f = pj_dmstor(opt, 0);
			break;
		case 's':	/* char string */
			value.s = opt;
			break;
		case 'b':	/* boolean */
			switch (*opt) {
			case 'F': case 'f':
				value.i = 0;
				break;
			case '\0': case 'T': case 't':
				value.i = 1;
				break;
			default:
				pj_errno = -8;
				value.i = 0;
				break;
			}
			break;
		default:
bum_type:	/* note: this is an error in parameter, not a user error */
			fprintf(stderr, "invalid request to pj_param, fatal\n");
			exit(1);
		}
	} else /* not given */
		switch (type) {
		case 'b':
		case 'i':
			value.i = 0;
			break;
		case 'd':
		case 'r':
			value.f = 0.;
			break;
		case 's':
			value.s = 0;
			break;
		default:
			goto bum_type;
		}
	return value;
}
/* Revision log:
** $Log: pj_param.c,v $
** Revision 2.1  2003/03/28 01:44:30  gie
** Initial
**
*/
