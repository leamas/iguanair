AC_DEFUN([AC_PROG_SWIG],[
        AC_PATH_PROG([SWIG],[swig])
        if test -z "$SWIG" ; then
                SWIG=
        elif test -n "$1" ; then
                AC_MSG_CHECKING([for a version of SWIG >= $1])
                [swig_version=`$SWIG -version 2>&1 | grep 'SWIG Version' | sed 's/.*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/g'`]
                if test -n "$swig_version" ; then
                        # Calculate the required version number components
                        [required=$1]
                        [required_major=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_major" ; then
                                [required_major=0]
                        fi
                        [required=`echo $required | sed 's/[0-9]*[^0-9]//'`]
                        [required_minor=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_minor" ; then
                                [required_minor=0]
                        fi
                        [required=`echo $required | sed 's/[0-9]*[^0-9]//'`]
                        [required_patch=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_patch" ; then
                                [required_patch=0]
                        fi
                        # Calculate the available version number components
                        [available=$swig_version]
                        [available_major=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_major" ; then
                                [available_major=0]
                        fi
                        [available=`echo $available | sed 's/[0-9]*[^0-9]//'`]
                        [available_minor=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_minor" ; then
                                [available_minor=0]
                        fi
                        [available=`echo $available | sed 's/[0-9]*[^0-9]//'`]
                        [available_patch=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_patch" ; then
                                [available_patch=0]
                        fi
			available_vers=`expr \( \( 100 \* $available_major \) + $available_minor \) \* 100 + $available_patch`
			required_vers=`expr \( \( 100 \* $available_major \) + $available_minor \) \* 100 + $available_patch`
                        if test $available_vers -lt $required_vers; then
                                SWIG=
                        else
                                SWIG_LIB=`$SWIG -swiglib`
                        fi
                else
                        SWIG=
                fi
                if test x"$SWIG" = x; then
                    AC_MSG_RESULT([no])
                else
                    AC_MSG_RESULT([yes])
                fi
        fi
        AC_SUBST([SWIG_LIB])
])

