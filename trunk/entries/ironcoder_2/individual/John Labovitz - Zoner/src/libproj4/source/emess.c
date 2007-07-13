/* Error message processing */
/*
** Copyright (c) 2003   Gerald I. Evenden
*/
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

static const char RCS_ID[]="$Id: emess.c,v 2.1 2003/03/28 15:38:31 gie Distr. gie $";
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#define EMESS_ROUTINE
#include "lproj.h"
extern char const pj_release[];
	void
emess(int code, char *fmt, ...) {
	va_list args;

	va_start(args, fmt);
	/* prefix program name, if given */
	if (fmt != NULL)
		(void)fprintf(stderr,"libproj4 system\n<%s>: ",emess_dat.Prog_name);
	/* print file name and line, if given */
	if (emess_dat.File_name != NULL && *emess_dat.File_name) {
		(void)fprintf(stderr,"while processing file: %s", emess_dat.File_name);
		if (emess_dat.File_line > 0)
			(void)fprintf(stderr,", line %d\n", emess_dat.File_line);
		else
			(void)fputc('\n', stderr);
	} else
		putc('\n', stderr);
	/* if |code|==2, print errno code data */
	if (code == 2 || code == -2)
		(void)fprintf(stderr, "Sys errno: %d: %s\n",
			errno,
#ifdef HAVE_STRERROR
			strerror(errno));
#else
			"<system mess. texts unavail.>");
#endif
	/* post remainder of call data */
	(void)vfprintf(stderr,fmt,args);
	va_end(args);
	/* die if code positive */
	if (code > 0) {
		(void)fputs("\nprogram abnormally terminated\n", stderr);
		exit(code);
	}
	else
		putc('\n', stderr);
}
/*
** $Log: emess.c,v $
** Revision 2.1  2003/03/28 15:38:31  gie
** Initial
**
*/
