#-------------------------------------------------------
#
# $Id: test.pl,v 2.6 1997/01/25 07:14:06 mergl Exp $
#
# Copyright (c) 1997  Edmund Mergl
#
#-------------------------------------------------------

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..67\n"; }
END {print "not ok 1\n" unless $loaded;}
use Pg;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

$dbmain = 'template1';
$dbname = 'pgperltest';
$trace  = '/tmp/pgtrace.out';
$cnt    = 2;
$DEBUG  = 0; # set this to 1 for traces

$| = 1;

######################### the following methods will be tested

#	connectdb
#	db
#	user
#	host
#	port
#	finish
#	status
#	errorMessage
#	trace
#	untrace
#	exec
#	getline
#	endcopy
#	putline
#	resultStatus
#	ntuples
#	nfields
#	fname
#	fnumber
#	ftype
#	fsize
#	cmdStatus
#	oidStatus
#	getvalue
#	print
#	notifies
#	lo_open
#	lo_close
#	lo_read
#	lo_write
#	lo_creat
#	lo_unlink

######################### the following methods will not be tested

#	setdb
#	reset
#	options
#	tty
#	getlength
#	getisnull
#	printTuples
#	lo_seek
#	lo_tell
#	lo_import
#	lo_export

######################### handles error condition

$SIG{PIPE} = sub { print "broken pipe\n" };

######################### create and connect to test database
# 2-4

$conn = Pg::connectdb("dbname = $dbmain");
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

# might fail if $dbname doesn't exist => don't check resultStatus
$result = $conn->exec("DROP DATABASE $dbname");

$result = $conn->exec("CREATE DATABASE $dbname");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$conn = Pg::connectdb("dbname = $dbname");
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

######################### debug, PQtrace

if ($DEBUG) {
    open(TRACE, ">$trace") || die "can not open $trace: $!";
    $conn->trace(TRACE);
}

######################### check PGconn
# 5-8

$db = $conn->db;
cmp_eq($dbname, $db);

$user = $conn->user;
cmp_ne("", $user);

$host = $conn->host;
cmp_ne("", $host);

$port = $conn->port;
cmp_ne("", $port);

######################### create and insert into table
# 9-20

$result = $conn->exec("CREATE TABLE person (id int4, name char16)");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("CREATE", $result->cmdStatus);

for ($i = 1; $i <= 5; $i++) {
    $result = $conn->exec("INSERT INTO person VALUES ($i, 'Edmund Mergl')");
    cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
    cmp_ne(0, $result->oidStatus);
}

######################### copy to stdout, PQgetline
# 21-27

$result = $conn->exec("COPY person TO STDOUT");
cmp_eq(PGRES_COPY_OUT, $result->resultStatus);

$i = 1;
while (-1 != $ret) {
    $ret = $conn->getline($string, 256);
    last if $string eq "\\.";
    cmp_eq("$i	Edmund Mergl", $string);
    $i ++;
}

cmp_eq(0, $conn->endcopy);

######################### delete and copy from stdin, PQputline
# 28-33

$result = $conn->exec("BEGIN");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$result = $conn->exec("DELETE FROM person");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("DELETE", $result->cmdStatus);

$result = $conn->exec("COPY person FROM STDIN");
cmp_eq(PGRES_COPY_IN, $result->resultStatus);

for ($i = 1; $i <= 5; $i++) {
    # watch the tabs and do not forget the newlines
    $conn->putline("$i	Edmund Mergl\n");
}
$conn->putline("\\.\n");

cmp_eq(0, $conn->endcopy);

$result = $conn->exec("END");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### select from person, PQgetvalue
# 34-47

$result = $conn->exec("SELECT * FROM person");
cmp_eq(PGRES_TUPLES_OK, $result->resultStatus);

for ($k = 0; $k < $result->nfields; $k++) {
    $fname = $result->fname($k);
    $ftype = $result->ftype($k);
    $fsize = $result->fsize($k);
    if (0 == $k) {
        cmp_eq("id", $fname);
        cmp_eq(23, $ftype);
        cmp_eq(4, $fsize);
    } else {
        cmp_eq("name", $fname);
        cmp_eq(20, $ftype);
        cmp_eq(16, $fsize);
    }
    $fnumber = $result->fnumber($fname);
    cmp_eq($k, $fnumber);
}

for ($k = 0; $k < $result->ntuples; $k++) {
    $string = "";
    for ($l = 0; $l < $result->nfields; $l++) {
        $string .= $result->getvalue($k, $l) . " ";
    }
    $i = $k + 1;
    cmp_eq("$i Edmund Mergl ", $string);
}

######################### PQnotifies
# 48-50

if (! defined($pid = fork)) {
    die "can not fork: $!";
} elsif (! $pid) {
    # i'm the child
    sleep 2;
    $conn = Pg::connectdb("dbname = $dbname");
    $result = $conn->exec("NOTIFY person");
    exit; # destroys $conn
}

$conn = Pg::connectdb("dbname = $dbname");
$result = $conn->exec("LISTEN person");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("LISTEN", $result->cmdStatus);

while (1) {
    $result = $conn->exec(" ");
    ($table, $pid) = $conn->notifies;
    last if $pid;
}

cmp_eq("person", $table);

######################### PQprint
# 51-52

$result = $conn->exec("SELECT name FROM person WHERE id = 2");
cmp_eq(PGRES_TUPLES_OK, $result->resultStatus);
open(PRINT, "| read IN; read IN; if [ \"\$IN\" = \"myName Edmund Mergl\" ]; then echo \"ok $cnt\"; else echo \"not ok $cnt\"; fi ") || die "can not fork: $|";
$cnt ++;
$result->print(PRINT, 0, 0, 0, 0, 1, 0, " ", "", "", "myName");
close(PRINT) || die "bad PRINT: $!";

######################### PQlo_creat, PQlo_open, PQlo_write
# 53-59

$cwd = `pwd`;
chop $cwd;
$filename = "$cwd/typemap";
open(LO, $filename) || die "can not open $filename: $!";

$result = $conn->exec("BEGIN");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$lobjId = $conn->lo_creat(PGRES_INV_READ|PGRES_INV_WRITE);
cmp_ne( 0,  $lobjId);
cmp_ne(-1, $lobjId);

$lobj_fd = $conn->lo_open($lobjId, PGRES_INV_WRITE);
cmp_ne(-1, $lobj_fd);

$i = 0;
while (($nbytes = read(LO, $buf, 1024)) > 0) {
    $cmp_ary[$i] = $buf;
    cmp_eq($nbytes, $conn->lo_write($lobj_fd, $buf, $nbytes));
    $i++;
}

close(LO)|| die "bad LO: $!";
cmp_ne(-1, $conn->lo_close($lobj_fd));

$result = $conn->exec("END");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### PQlo_read, PQlo_unlink
# 60-65

$result = $conn->exec("BEGIN");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$lobj_fd = $conn->lo_open($lobjId, PGRES_INV_READ);
cmp_ne(-1, $lobj_fd);

$i = 0;
while (($nbytes = $conn->lo_read($lobj_fd, $buf, 1024)) > 0) {
    cmp_eq($cmp_ary[$i], $buf);
    $i++;
}

cmp_ne(-1, $conn->lo_close($lobj_fd));

cmp_ne(-1, $conn->lo_unlink($lobjId));

$result = $conn->exec("END");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### debug, PQuntrace

if ($DEBUG) {
    close(TRACE) || die "bad TRACE: $!";
    $conn->untrace;
}

######################### disconnect and drop test database
# 66-67

$conn = Pg::connectdb("dbname = $dbmain");
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

$result = $conn->exec("DROP DATABASE $dbname");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### hopefully

print "all tests passed.\n" if 68 == $cnt;

######################### utility functions

sub cmp_eq {

    my $cmp = shift;
    my $ret = shift;
    my $msg;

    if ("$cmp" eq "$ret") {
	print "ok $cnt\n";
    } else {
        $msg = $conn->errorMessage;
	print "not ok $cnt: $cmp, $ret\n$msg\n";
        exit;
    }
    $cnt++;
}

sub cmp_ne {

    my $cmp = shift;
    my $ret = shift;
    my $msg;

    if ("$cmp" ne "$ret") {
	print "ok $cnt\n";
    } else {
        $msg = $conn->errorMessage;
	print "not ok $cnt: $cmp, $ret\n$msg\n";
        exit;
    }
    $cnt++;
}

######################### EOF
