#-------------------------------------------------------
#
# $Id: Makefile.PL,v 1.4 1997/01/25 07:14:03 mergl Exp $
#
# Copyright (c) 1997  Edmund Mergl
#
#-------------------------------------------------------

use ExtUtils::MakeMaker;

print "\nConfiguring Pg\n";
print "Remember to actually read the README file !\n";
die "\nYou didn't read the README file !\n" unless ($] >= 5.003);

if (! $ENV{POSTGRESHOME}) {
    warn "\$POSTGRESHOME not defined. Searching for Postgres...\n";
    foreach(qw(/usr/pgsql /usr/local/pgsql /usr/pgsql-6.0 /usr/local/pgsql-6.0)) {
        if (-d "$_/lib") {
            $ENV{POSTGRESHOME} = $_;
            last;
        }
    }
}

if ($ENV{POSTGRESHOME}) {
    print "\nFound Postgres in $ENV{POSTGRESHOME}\n";
} else {
    die "Unable to determine \$POSTGRESHOME !\n";
}

WriteMakefile(
    'NAME'	   => 'Pg',
    'VERSION_FROM' => 'Pg.pm',
    'LIBS'	   => ["-L$ENV{POSTGRESHOME}/lib -lpq"],
    'INC'	   =>  "-I$ENV{POSTGRESHOME}/include",
);

# EOF
