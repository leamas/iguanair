#ifndef _POPT_FIX_
#define _POPT_FIX_

void poptPrintHelp(poptContext context, FILE *pipe, int flags);
void poptPrintUsage(poptContext context, FILE *pipe, int flags);

extern const char *programName;

#endif
