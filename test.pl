#-------------------------------------------------------
#
# $Id: test.pl,v 2.2 1996/11/24 09:21:15 mergl Exp $
#
#-------------------------------------------------------

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..56\n"; }
END {print "not ok 1\n" unless $loaded;}
use Pg;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

$dbmain    = 'template1';
$dbname    = 'pgperltest';
$trace     = '/tmp/pgtrace.out';
$cnt       = 2;
$DEBUG     = 0; # set this to 1 for traces

######################### the following methods will be tested

#	new
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

#	reset
#	db
#	host
#	options
#	port
#	tty
#	fname
#	fnumber
#	ftype
#	fsize
#	getlength
#	getisnull
#	printTuples
#	lo_lseek
#	lo_tell
#	lo_import
#	lo_export

######################### handles error condition for PQsetdb

$SIG{PIPE} = sub { print "broken pipe\n" };

######################### create and connect to test database

$conn = Pg::new('', '', '', '', $dbmain);
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

$conn->exec("drop database $dbname");

$result = $conn->exec("create database $dbname");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);


$conn = Pg::new('', '', '', '', $dbname);
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

######################### debug, PQtrace

if ($DEBUG) {
    open(TRACE, ">$trace") || die "can not open $trace: $!";
    $conn->trace(TRACE);
}

######################### create and insert into table

$result = $conn->exec("create table person (name char16, age int4, location point)");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("CREATE", $result->cmdStatus);

for ($i=50; $i <= 90; $i = $i + 10) {
    $result = $conn->exec("insert into person values ('fred', $i, \'($i,10)\'::point)");
    cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
    cmp_ne(0, $result->oidStatus);
}

######################### copy to stdout, PQgetline

$result = $conn->exec("copy person to stdout");
cmp_eq(PGRES_COPY_OUT, $result->resultStatus);

$i = 50;
while (-1 != $ret) {
    $ret = $conn->getline($string, 256);
    last if $string eq "\\.";
    cmp_eq("fred	$i	($i,10)", $string);
    $i += 10;
}

cmp_eq(0, $conn->endcopy);

######################### delete and copy from stdin, PQputline

$result = $conn->exec("begin");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$result = $conn->exec("delete from person");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("DELETE", $result->cmdStatus);

$result = $conn->exec("copy person from stdin");
cmp_eq(PGRES_COPY_IN, $result->resultStatus);

for ($i=50; $i <= 90; $i = $i + 10) {
    # watch the tabs and do not forget the newlines
    $conn->putline("fred	$i	($i,10)\n");
}
$conn->putline("\\.\n");

cmp_eq(0, $conn->endcopy);

$result = $conn->exec("end");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### select from person, PQgetvalue

$result = $conn->exec("select * from person");
cmp_eq(PGRES_TUPLES_OK, $result->resultStatus);
$i = 50;
for ($k=0; $k < $result->ntuples; $k++) {
    $string = "";
    for ($l=0; $l < $result->nfields; $l++) {
        $string .= $result->getvalue($k, $l) . " ";
    }
    cmp_eq("fred $i ($i,10) ", $string);
    $i += 10;
}

######################### PQnotifies

if (!defined($pid = fork)) {
    die "can not fork: $!";
} elsif (! $pid) {
    # i'm the child
    sleep 2;
    $conn = Pg::new('', '', '', '', $dbname);
    $result = $conn->exec("notify person");
    exit; # destroys $conn
}

$conn = Pg::new('', '', '', '', $dbname);
$result = $conn->exec("listen person");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);
cmp_eq("LISTEN", $result->cmdStatus);

while (1) {
    $result = $conn->exec(" ");
    ($table, $pid) = $conn->notifies;
    last if $pid;
}

cmp_eq("person", $table);

######################### PQprint

$result = $conn->exec("select location from person where age = 70");
cmp_eq(PGRES_TUPLES_OK, $result->resultStatus);
open(PRINT, "| read IN; read IN; if [ \"\$IN\" = \"myLocation (70,10)\" ]; then echo \"ok $cnt\"; else echo \"not ok $cnt: print\"; fi ") || die "can not fork: $|";
$cnt ++;
$result->print(PRINT, 0, 0, 0, 0, 1, 0, " ", "", "", "myLocation");
close(PRINT) || die "bad PRINT: $!";

######################### PQlo_creat, PQlo_open, PQlo_write

$cwd = `pwd`;
chop $cwd;
$filename = "$cwd/Changes";
open(LO, $filename) || die "can not open $filename: $!";

$result = $conn->exec("begin");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$lobjId = $conn->lo_creat(PGRES_INV_READ|PGRES_INV_WRITE);
cmp_ne(0, $lobjId);

$lobj_fd = $conn->lo_open($lobjId, PGRES_INV_WRITE);
cmp_ne(-1, $lobj_fd);

$i = 0;
while (($nbytes = read(LO, $buf, 1024)) > 0) {
    $cmp_ary[$i] = $buf;
    cmp_eq($nbytes, $conn->lo_write($lobj_fd, $buf, $nbytes));
    $i++;
}

close(LO)|| die "bad LO: $!";
cmp_eq(0, $conn->lo_close($lobj_fd));

$result = $conn->exec("end");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### PQlo_read, PQlo_unlink

$result = $conn->exec("begin");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

$lobj_fd = $conn->lo_open($lobjId, PGRES_INV_READ);
cmp_ne(-1, $lobj_fd);

$i = 0;
while (($nbytes = $conn->lo_read($lobj_fd, $buf, 1024)) > 0) {
    cmp_eq($cmp_ary[$i], $buf);
    $i++;
}

cmp_eq(0, $conn->lo_close($lobj_fd));

cmp_ne(-1, $conn->lo_unlink($lobjId));

$result = $conn->exec("end");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### debug, PQuntrace

if ($DEBUG) {
    close(TRACE) || die "bad TRACE: $!";
    $conn->untrace;
}

######################### disconnect and drop test database

$conn = Pg::new('', '', '', '', $dbmain);
cmp_eq(PGRES_CONNECTION_OK, $conn->status);

$result = $conn->exec("drop database $dbname");
cmp_eq(PGRES_COMMAND_OK, $result->resultStatus);

######################### hopefully

print "all tests passed.\n" if 57 == $cnt;

######################### utility functions

sub cmp_eq {

    my $cmp = shift;
    my $ret = shift;
    my $msg;

    if ("$cmp" eq "$ret") {
	print "ok $cnt\n";
    } else {
        $msg = $conn->errorMessage;
	die "not ok $cnt: $cmp, $ret\n$msg\n";
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
	die "not ok $cnt: $cmp, $ret\n$msg\n";
    }
    $cnt++;
}

######################### EOF
