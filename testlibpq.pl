#!/usr/local/bin/perl

#-------------------------------------------------------
#
# $Id: testlibpq.pl,v 1.2 1995/07/27 19:57:53 li00357 Exp $
#
#-------------------------------------------------------
#
# An example of how to use Postgres from perl.

# Be certain that the postgres ``bin'' directory is in your path.
# Also, you *must* have the postmaster running!


use Pg;


# these are from libpq-fe.h

$PGRES_EMPTY_QUERY    = 0 ;
$PGRES_COMMAND_OK     = 1 ;
$PGRES_TUPLES_OK      = 2 ;
$PGRES_COPY_OUT       = 3 ;
$PGRES_COPY_IN        = 4 ;
$PGRES_BAD_RESPONSE   = 5 ;
$PGRES_NONFATAL_ERROR = 6 ;
$PGRES_FATAL_ERROR    = 7 ;


$pghost    = 'localhost';
$pgport    = '5432';
$pgoptions = '';
$pgtty     = '';
$dbname    = 'pgperltest';


init_handler();


# Destroy then create the database
# an error is ok in destroydb, since the database may not exist.
print("Destroying database $dbname\n");
system("destroydb $dbname");
print("Creating database $dbname\n");
if (system("createdb $dbname") / 256) {
	die("$0: createdb failed on $dbname\n");
}

# specify the database to access
$conn = PQsetdb ($pghost, $pgport, $pgoptions, $pgtty, $dbname);
&good_bye() if PQstatus($conn);
printf("Connected to database %s at %s using port %s\n", PQdb($conn), PQhost($conn), PQport($conn));

print("\nCreating relation person:\n");
test_create();

print("\nRelation person before appends:\n");
test_functions();

print("\nAppending to relation person:\n");
test_append();

print("\nRelation person after appends:\n");
test_functions();

print("\nTesting copy:\n");
test_copy();

print("\nRelation person after copy:\n");
test_functions();

print("\nRemoving from relation person:\n");
test_remove();

print("\nRelation person after removes:\n");
test_functions();

# finish execution
print("\nTests complete!\n");
PQfinish($conn);
exit(0);


sub test_create {

    $result = PQexec($conn, "begin");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    $cmd = "create table person (name char16, age int4, location point)";
    printf("command = %s\n", $cmd);
    $result = PQexec($conn, $cmd);
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    $result = PQexec($conn, "end");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);
}


sub test_append {

    $result = PQexec($conn, "begin");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    for ($i=50; $i <= 150; $i = $i + 10) {
	$cmd = "insert into person values (\'fred\', $i, \'($i,10)\'::point)";
	printf("command = %s\n", $cmd);
        $result = PQexec($conn, $cmd);
        good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
        PQclear($result);
    }

    $result = PQexec($conn, "end");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);
}


sub test_remove {

    $result = PQexec($conn, "begin");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    for ($i=50; $i <= 150; $i = $i + 10) {
	$cmd = "delete from person where person.age = $i ";
	printf("command = %s\n", $cmd);
        $result = PQexec($conn, $cmd);
        good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
        PQclear($result);
    }

    $result = PQexec($conn, "end");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);
}


sub test_functions {

    $result = PQexec($conn, "begin");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    $cmd = "declare eportal cursor for select * from person";
    $result = PQexec($conn, $cmd);
    &good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    $cmd = "fetch all in eportal";
    $result = PQexec($conn, $cmd);
    &good_bye() if $PGRES_TUPLES_OK != PQresultStatus($result);

    $nfields = PQnfields($result);
    $ntuples = PQntuples($result);

    for ($j=0; $j < $nfields; $j++) {
        printf("%-15s", PQfname($result, $j));
    }
    print("\n");

    for ($i=0; $i < $ntuples; $i++) {
        for ($j=0; $j < $nfields; $j++) {
            printf("%-15s", PQgetvalue($result, $i, $j));
        }
        print("\n");
    }
    PQclear($result);

    $result = PQexec($conn, "close eportal");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);

    $result = PQexec($conn, "end");
    good_bye() if $PGRES_COMMAND_OK != PQresultStatus($result);
    PQclear($result);
}


sub test_copy {
    $cmd = "copy person from stdin";
    $result = PQexec($conn, $cmd);
    &good_bye() if $PGRES_COPY_IN != PQresultStatus($result) ;

    PQputline($conn, "bill	21	(1,2)\n");
    PQputline($conn, "bob	61	(3,4)\n");
    PQputline($conn, "sally	39	(5,6)\n");
    PQputline($conn, ".\n");
    PQendcopy($conn);
    PQclear($result);
}


sub init_handler {
    $SIG{'HUP'}  = 'handler';
    $SIG{'INT'}  = 'handler';
    $SIG{'QUIT'} = 'handler';
}


sub handler {  # 1st argument is signal name
    local($sig) = @_;
    print("Caught a SIG$sig--shutting down connection to Postgres.\n");
    PQclear($result) if $result;
    PQfinish($conn)  if $conn;
    exit(0);
}


sub good_bye {
    $string = PQerrorMessage($conn) if $conn;
    print "error: $string\n";
    PQclear($result) if $result;
    PQfinish($conn)  if $conn;
    exit(0);
}
