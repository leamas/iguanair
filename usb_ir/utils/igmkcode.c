/*
 * igmkcode: filter the output of igclient --receiver-on --sleep=<sleep>
 *           and produce syntactically valid codes.
 *
 * Yves Arrouye, April 24, 2012.
 * Copyright (C) 2012, Yves Arrouye. All rights reserved.
 */

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static long lstrtol(const char *src, char **endptr, int base) {
    if (!src || isspace(*src) || *src == '+' || *src == '-' ||
        (base == 16 && *src == '0' && src[1] && src[1] == 'x')) {
        *endptr = (char *) src;
        return 0;
    }
    
    return strtol(src, endptr, base);
}

/*
 * Makes a code from some garbled input. Supports the following:
 *
 * - A proper iguana IR file.
 * - The output of igclient --receiver-on --sleep=<sleep>
 *
 * Any sequence of pulse or space commands will have their values summed
 * up before being printed. Any non pulse or space line in a sequece of
 * pulse or space is ignored.
 */
static int mkcode(FILE *in) {
    char buffer[BUFSIZ];
    
    int prev_is_space = 1, seen_pulse = 0;
    int prev_value = 0;
 
    int lineno = 0;

    int is_plain_numbers = -1;

    while (fgets(buffer, sizeof(buffer), in)) {
        int is_pulse = 0, is_space = 0;
	int value = 0;

        char *bufferp = buffer;
	for (; isspace(*bufferp); ++bufferp);    /* Skip leading whitespace. */

	/* TODO: deal with boundaries to remove big spaces. */

	if (!strncmp(bufferp, "carrier", 7) &&  (bufferp[7] == ':' || isspace(bufferp[7]))) {
	  printf("%s", bufferp);
	} else if ((is_pulse = !strncmp(bufferp, "pulse", 5)) || (is_space = !strncmp(bufferp, "space", 5))) {
	    char *endvalue;
	    bufferp += 5;

	    if (*bufferp == ':') {
	        ++bufferp;
	    }
	    if (*bufferp == ' ') {
	      ++bufferp;
	    }

	    if (is_pulse && !seen_pulse) {
	        seen_pulse = is_pulse;
	    }

	    value = lstrtol(bufferp, &endvalue, 10);
	    if (endvalue != bufferp) {
	        if ((is_space && prev_is_space) || (is_pulse && !prev_is_space)) {
		    prev_value += value;
		    continue;
		}
	    }
	} else if (!strncmp(buffer, "received ", 8)) {
	    if (!seen_pulse && prev_is_space) {
	        prev_value = 0;
	    }
	    continue;
	} else {
	    if (is_plain_numbers != 0) {
	        char *endvalue;
		value = lstrtol(bufferp, &endvalue, 10);
		if (endvalue == bufferp) {
		    continue;
		}
		is_space = !prev_is_space;
		is_pulse = !is_space;
	    } else {
	        continue;
	    }
	}

	if (++lineno > 1) {
	    if (lineno > 2 && !prev_is_space) {
	        putchar('\n');
	    }
	    printf(prev_is_space ? "space %d" : "pulse %d\n", prev_value);
	}

	prev_is_space = is_space;
	prev_value = value;
    }

    if (prev_value) {
	printf(prev_is_space ? "space %d" : "pulse %d\n", prev_value);
    }

    return 0;
}

int main(int argc, const char **argv) {
    argc = 0, argv = NULL;	/* Quiet the compiler. */
    return mkcode(stdin);
}

