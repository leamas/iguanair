#include "iguanaIR.h"
#include "compat.h"

#include <windows.h>
#include <stdio.h>
#include <popt.h>

#include "poptint.h"
#include "popt-fix.h"

const char *programName = NULL;

void poptPrintHelp(poptContext context, FILE *pipe, int flags)
{
    CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE console;
    int x, width = 80, optWidth = -1, pass;
    char *buffer = NULL;
    const struct poptOption *options;

    UNUSED(flags);

    /* snag the options pointer out of the context */
    options = context->options;

    console = GetStdHandle(STD_OUTPUT_HANDLE);
    if (console != INVALID_HANDLE_VALUE &&
        GetConsoleScreenBufferInfo(console, &info))
        width = info.dwSize.X;

    /* allocate enough space for a line (yes I'm leaving off the +1) */
    buffer = (char*)malloc(width);
    buffer[width - 1] = '\0';

    fprintf(pipe, "Usage: %s [OPTION...]\n", programName);
    /* figure out the width of the options in the first pass */
    for(pass = 0; pass < 2; pass++)
        for(x = 0; options[x].longName != NULL || options[x].shortName != '\0'; x++)
        {
            int offset;

            strcpy(buffer, "  ");
            offset = 2;
            if (options[x].shortName != '\0')
            {
                offset += sprintf(buffer + offset, "-%c", options[x].shortName);
                if (options[x].longName != NULL)
                    offset += sprintf(buffer + offset, ", ");
            }
            if (options[x].longName != NULL)
                offset += sprintf(buffer + offset, "--%s", options[x].longName);
            if (options[x].argDescrip != NULL)
                offset += sprintf(buffer + offset, "=%s", options[x].argDescrip);

            if (pass == 1)
            {
                int len;

                /* pad the first column */
                while(offset < optWidth)
                    buffer[offset++] = ' ';
                buffer[offset] = '\0';

                /* add the second */
                len = snprintf(buffer + offset, width - offset - 1, "%s", options[x].descrip);
                if (len == -1)
                {
                    char *space;
                    space = strrchr(buffer, ' ');
                    if (space != NULL)
                    {
                        space[0] = '\0';
                        offset = strlen(buffer + optWidth) + 1;
                        fprintf(pipe, "%s\n", buffer);
                        memset(buffer, ' ', optWidth);
                        strcpy(buffer + optWidth, options[x].descrip + offset);
                    }
                }
                fprintf(pipe, "%s\n", buffer);

            }
            else if (offset + 5 > optWidth)
                optWidth = offset + 5;
        }
}

void poptPrintUsage(poptContext context, FILE *pipe, int flags)
{
    poptPrintHelp(context, pipe, flags);
}
