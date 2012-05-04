# -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT(iguanaIR,
  esyscmd(grep Version: ../packaging/fedora/iguanaIR.spec | sed 's/Version: *//' | tr -d '\n'),
  support@iguanaworks.net)
AC_PREFIX_DEFAULT([/usr])
AC_CONFIG_SRCDIR([daemon.c])
AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PROG_SED

DYNLIB_EXT=so
DYNMOD_EXT=so

AC_SUBST(DYNLIB_EXT)
AC_SUBST(DYNMOD_EXT)

# Check for some target-specific stuff.
AC_CANONICAL_HOST
AC_SUBST(host_os)
libdirname=lib
AC_SUBST(libdirname)
case "$host" in
*-*-linux*)
    case "$host_cpu" in
    	 x86_64|ppc64|s390x|sparc64|amdd64)
	    libdirname=lib64
	    ;;
    esac
    ;;
        
*-*-darwin*)
    DYNLIB_EXT=dylib
    if test "$GCC" = "yes"; then
    CFLAGS="$CFLAGS -no-cpp-precomp"
    fi
    ;;
esac
libdir='${exec_prefix}/${libdirname}'
eval "mac_libdir=$libdir"

AC_DEFINE_UNQUOTED(DYNMOD_EXT, "${DYNMOD_EXT}", [loadable module extension])

# Checks for libraries.
AC_CHECK_LIB([popt], [poptGetContext],
  [AC_CHECK_HEADER(popt.h, [HAVE_POPT_DEVEL=yes])]
)
if test x$HAVE_POPT_DEVEL = x; then
  AC_MSG_ERROR([Could not find popt; please install libpopt-dev (popt-devel in Fedora; popt in MacPorts; etc.)])
fi

AC_CHECK_LIB([pthread], [pthread_create])
AC_CHECK_LIB([rt], [clock_gettime],
  [
    RTLIB=-lrt
    AC_SUBST([RTLIB])
  ]
)

# Checks for header files.
AC_HEADER_DIRENT
AC_HEADER_STDC
AC_CHECK_HEADERS([float.h limits.h stddef.h stdint.h stdlib.h string.h sys/param.h sys/socket.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_C_INLINE
AC_TYPE_MODE_T
AC_TYPE_SIZE_T
AC_HEADER_TIME
AC_STRUCT_TM
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_C_VOLATILE

# Checks for library functions.
AC_FUNC_LSTAT
AC_FUNC_LSTAT_FOLLOWS_SLASHED_SYMLINK
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_FUNC_SELECT_ARGTYPES
AC_TYPE_SIGNAL
AC_FUNC_STRFTIME
AC_FUNC_VPRINTF
AC_CHECK_FUNCS([floor gettimeofday memset mkdir select socket strchr strdup strerror strrchr strspn strstr mach_absolute_time])

# Some default environment variable values
CFLAGS="-Wall -pedantic"

# use -Wextra when possible
AX_CFLAGS_GCC_OPTION(-Wextra)

# TODO: really just want this when we NEED -fPIC
# AX_CFLAGS_GCC_OPTION(-fPIC)

# enable and disable debugging
AC_ARG_ENABLE(debug,
  [  --enable-debug configure with debugging features enabled ],
  [ if test x$enableval = xyes; then
      ENABLE_DEBUG_FLAGS=yes
    fi ]
)
if test x$ENABLE_DEBUG_FLAGS = xyes; then
  CPPFLAGS="$CPPFLAGS -D_DEBUG"
  CFLAGS="$CFLAGS -g"
else
  CFLAGS="$CFLAGS -O2"
fi

# Allow the user to override clock_gettime detection
AC_ARG_ENABLE(clock_gettime,
  [  --disable-clock_gettime do not use clock_gettime even if it exists],
  [ if test x$enableval = xno; then
        DISABLE_CLOCK_GETTIME=yes
    fi ],
)
if ! test x$DISABLE_CLOCK_GETTIME = xyes; then
    AC_CHECK_FUNC(clock_gettime,
        AC_DEFINE(USE_CLOCK_GETTIME, 1, [use the available clock_gettime])
    )
fi

# check for libusb-1.0; we want the lib and the headers to compile
AC_CHECK_LIB([usb-1.0], [libusb_init],
  [AC_CHECK_HEADER([libusb-1.0/libusb.h], [LIBUSB_10=-lusb-1.0])]
)
AC_SUBST(LIBUSB_10)

# if we do not have libusb-1.0, look for libusb
if test x"$LIBUSB_10" = x; then

AC_CHECK_LIB([usb], [usb_get_busses], [
    AC_CHECK_HEADER([usb.h], [
    LIBUSB_0=-lusb=yes
      VERSION=0
      for num in `2>/dev/null libusb-config --version | tr '.' ' '`
       do
        VERSION=$(($VERSION * 100 + $num))
      done

      AC_DEFINE_UNQUOTED(LIBUSB_VERSION, $VERSION, [version of libusb])
      # Older versions of libusb do not play with threads at all
      # nicely.  This driver was actually developed on such a version
      # of libusb.  However, in later versions threads seem to not eat
      # the responses for URBs intended for other threads.  By
      # defining LIBUSB_NO_THREADS you can request the slower (around
      # 1/4 the speed for USB transaction heavy workloads), but safer,
      # behavior where 2 threads never use the same libusb object at
      # once.
      #
      # version 0.1.8 and earlier need more than this (i.e. NOT SUPPORTED)
      # version 0.1.10a and earlier need this
      # version 0.1.11 and later do not need this;
      #                works with kernel-2.6.5 and later
      # version 0.1.12 only works with kernel-2.6.10 and later
      #
      if test $VERSION -lt 111; then
        AC_DEFINE(LIBUSB_NO_THREADS, 1, [whether to use threads with libusb])
      else
        AC_ARG_ENABLE(no-threads,
            [  --disable-no-threads enable the "no threads" option ],
            [ if test "x$enableval" == "xno"; then
                LIBUSB_THREADS_OPTIONAL=no
            fi
          ]
        )
        if test x$LIBUSB_THREADS_OPTIONAL != xno; then
          AC_DEFINE(LIBUSB_NO_THREADS, 1, [whether to use threads with libusb])
          AC_DEFINE(LIBUSB_NO_THREADS_OPTION, 1,
                    [whether to makes threads optional with libusb])
        fi
      fi

      # Want to use the constantly incrementing devnum if it exists.
      # This functionality was introduced in version 0.1.9 of libusb.
      #
      if test $VERSION -lt 109; then
        AC_DEFINE(LIBUSB_DEVNUM(dev), (dev->bus->location),
                                      [what to use for the libusb devnum])
      else
        AC_DEFINE(LIBUSB_DEVNUM(dev), (dev->devnum),
                                      [what to use for the libusb devnum])
      fi
      unset VERSION
    ])
  ]
)
fi

AC_SUBST(LIBUSB_0)

if test x$LIBUSB_10 = x -a x$LIBUSB_0 = x; then
  AC_MSG_ERROR([Could not find a USB library; please install libusb-1.0.0-dev or libusb-dev (libusb-devel on Fedora; libusb-1.0 in MacPorts; etc.)])
  exit 1
fi

# Allow the user to override python detection
AC_ARG_ENABLE(python,
  [  --enable-python build a Python interface],
  [ if test x$enableval == xno; then
        USE_PYTHON=no
    fi ]
)
if test x$USE_PYTHON != xno; then
    # fetch the Python version
    AC_PYTHON_DEVEL()
    # look for swig since we need it to build the Pyhon bindings
    req_swig_version=1.3.31
    AC_PROG_SWIG($req_swig_version)
    if test x"$SWIG" = x; then
        AC_MSG_ERROR([Could not find a usable version of SWIG; please use --disable-python or install SWIG $req_swig_version or later])
    fi
fi

# Output some files
AC_CONFIG_FILES([Make.settings Makefile drivers/Makefile darwin/Makefile utils/Makefile scripts/Makefile reflasher/Makefile packaging/Makefile])
AC_OUTPUT([autoconf/stamp-h iguanaIR.i setup.py])

