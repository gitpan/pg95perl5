# -------------------------------------------------------
#
# Makefile.PL,v 1.2 1995/07/27 19:57:50 li00357 Exp
#
# -------------------------------------------------------

use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'     => 'Pg',
	'MYEXTLIB' => ' /usr/local/postgres95/lib/libpq.so.1',
	'INC'      => ' -I /usr/local/postgres95/include'
);
