#-------------------------------------------------------
#
# $Id: Pg.pm,v 2.2 1996/11/24 09:21:12 mergl Exp $
#
#-------------------------------------------------------

package Pg;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT $AUTOLOAD);

require Exporter;
require DynaLoader;
require AutoLoader;
require 5.003;

@ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default.
@EXPORT = qw(
	PQsetdb
	PQfinish
	PQreset
	PQdb
	PQhost
	PQoptions
	PQport
	PQtty
	PQstatus
	PQerrorMessage
	PQtrace
	PQuntrace
	PQexec
	PQgetline
	PQendcopy
	PQputline
	PQnotifies
	PQresultStatus
	PQntuples
	PQnfields
	PQfname
	PQfnumber
	PQftype
	PQfsize
	PQcmdStatus
	PQoidStatus
	PQgetvalue
	PQgetlength
	PQgetisnull
	PQclear
	PQprintTuples
	PQprint
	PQlo_open
	PQlo_close
	PQlo_read
	PQlo_write
	PQlo_lseek
	PQlo_creat
	PQlo_tell
	PQlo_unlink
	PQlo_import
	PQlo_export
	PGRES_CONNECTION_OK
	PGRES_CONNECTION_BAD
	PGRES_EMPTY_QUERY
	PGRES_COMMAND_OK
	PGRES_TUPLES_OK
	PGRES_COPY_OUT
	PGRES_COPY_IN
	PGRES_BAD_RESPONSE
	PGRES_NONFATAL_ERROR
	PGRES_FATAL_ERROR
	PGRES_INV_SMGRMASK
	PGRES_INV_ARCHIVE
	PGRES_INV_WRITE
	PGRES_INV_READ
	PGRES_InvalidOid
);

$VERSION = '1.4';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Pg macro $constname";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap Pg $VERSION;

sub doQuery {

    my $conn      = shift;
    my $query     = shift;
    my $array_ref = shift;

    my ($result, $status, $nfields, $ntuples, $i, $j);

    $result = PQexec($conn, $query);
    $status = PQresultStatus($result);
    return($status) if (2 != $status);

    $nfields = PQnfields($result);
    $ntuples = PQntuples($result);
    for ($i=0; $i < $ntuples; $i++) {
        for ($j=0; $j < $nfields; $j++) {
            $$array_ref[$i][$j] = PQgetvalue($result, $i, $j);
        }
    }

    PQclear($result);

    return 1;
}

1;

__END__


=head1 NAME

Pg - Perl extension for Postgres95


=head1 SYNOPSIS

new style:

use Pg;
C<
$conn = Pg::new('', '', '', '', 'template1');
$result = $conn-&gtexec("create database test");
>


you may also use the old style:

use Pg;
C<
$conn = PQsetdb('', '', '', '', template1);
$result = PQexec($conn, "create database test");
PQclear($result);
PQfinish($conn);
>


=head1 DESCRIPTION

The Pg module permits you to access all functions of the 
Libpq interface of Postgres95. Libpq is the programmer's 
interface to Postgres95. Pg tries to resemble this 
interface as close as possible. For examples of how to 
use this module, look at the file test.pl. For further 
examples look at the Libpq applications in 
../src/test/examples and ../src/test/regress. 

You have the choice between the old C-style and a 
new more Perl-ish style. The old style has the 
benefit, that existing Libpq applications can be 
ported to perl just by prepending every variable 
with a '$'. The new style uses class packages and 
might be more familiar for C++-programmers. 


=head1 GUIDELINES

=head2 old style

All functions and constants are imported into the calling 
packages namespace. In order to to get a uniform naming, 
all functions start with 'PQ' (e.g. PQlo_open) and all 
constants start with 'PGRES_' (e.g. PGRES_CONNECTION_OK). 

There are two functions, which allocate memory, that has 
to be freed by the user: 

	PQsetdb, use PQfinish to free memory.
	PQexec,  use PQclear to free memory.


Pg.pm contains one convenience function: doQuery. It fills a
two-dimensional array with the result of your query. Usage:

C<
Pg::doQuery($conn, "select attr1, attr2 from tbl", \@ary);

for $i ( 0 .. $#ary ) {
    for $j ( 0 .. $#{$ary[$i]} ) {
        print "$ary[$i][$j]\t";
    }
    print "\n";
}
>

Notice the inner loop !

=head2 new style

The new style uses blessed references as objects. 
After creating a new connection or result object, 
the relevant Libpq functions serve as virtual methods. 
One benefit of the new style: you do not have to care 
about freeing the connection- and result-structures. 
Perl calls the destructor whenever the last reference 
to an object goes away. 


=head1 CAVEATS

There are two exceptions, where the perl-functions differs 
from the C-counterpart: PQprint and PQnotifies. These 
functions deal with structures, which have been implemented 
in perl using lists. 


=head1 FUNCTIONS

The functions have been divided into three sections: 
Connection, Result, Large Objects.


=head2 1. Connection

With these functions you can establish and close a connection to a 
database. In Libpq a connection is represented by a structure called
PGconn. Using the appropriate methods you can access almost all 
fields of this structure.

B<$conn = Pg::new($pghost, $pgport, $pgoptions, $pgtty, $dbname)>

Opens a new connection to the backend. You may use an empty string for
any argument, in which case first the environment is checked and then 
hardcoded defaults are used. The connection identifier $conn ( a pointer 
to the PGconn structure ) must be used in subsequent commands for unique 
identification. Before using $conn you should call $conn-&gtstatus to ensure, 
that the connection was properly made. Use the methods below to access 
the contents of the PGconn structure.

B<PQfinish($conn)>

Old style only !
Closes the connection to the backend and frees all memory. 

B<$conn-&gtreset>

Resets the communication port with the backend and tries
to establish a new connection.

B<$dbName = $conn-&gtdb>

Returns the database name of the connection.

B<$pghost = $conn-&gthost>

Returns the host name of the connection.

B<$pgoptions = $conn-&gtoptions>

Returns the options used in the connection.

B<$pgport = $conn-&gtport>

Returns the port of the connection.

B<$pgtty = $conn-&gttty>

Returns the tty of the connection.

B<$status = $conn-&gtstatus>

Returns the status of the connection. For comparing the status 
you may use the following constants: 
 - PGRES_CONNECTION_OK
 - PGRES_CONNECTION_BAD

B<$errorMessage = $conn-&gterrorMessage>

Returns the last error message associated with this connection.

B<$conn-&gttrace(debug_port)>

Messages passed between frontend and backend are echoed to the 
debug_port file stream. 

B<$conn-&gtuntrace>

Disables tracing. 

B<$result = $conn-&gtexec($query)>

Submits a query to the backend. The return value is a pointer to 
the PGresult structure, which contains the complete query-result 
returned by the backend. In case of failure, the pointer points 
to an empty structure. In this, the perl implementation differs 
from the C-implementation. Using the old style, even the empty 
structure has to be freed using PQfree. Before using $result you 
should call resultStatus to ensure, that the query was 
properly executed. 

B<$ret = $conn-&gtgetline($string, $length)>

Reads a string up to $length - 1 characters from the backend. 
getline returns EOF at EOF, 0 if the entire line has been read, 
and 1 if the buffer is full. If a line consists of the two 
characters "\." the backend has finished sending the results of 
the copy command. 

B<$conn-&gtputline($string)>

Sends a string to the backend. The application must explicitly 
send the two characters "\." to indicate to the backend that 
it has finished sending its data. 

B<$ret = $conn-&gtendcopy>

This function waits  until the backend has finished the copy. 
It should either be issued when the last string has been sent 
to  the  backend  using  putline or when the last string has 
been received from the backend using getline. endcopy returns 
0 on success, nonzero otherwise. 

B<($table, $pid) = $conn-&gtnotifies>

Checks for asynchronous notifications. This functions differs from 
the C-counterpart which returns a pointer to a new allocated structure, 
whereas the perl implementation returns a list. $table is the table 
which has been listened to and $pid is the process id of the backend. 


=head2 2. Result

With these functions you can send commands to a database and
investigate the results. In Libpq the result of a command is 
represented by a structure called PGresult. Using the appropriate 
methods you can access almost all fields of this structure.

Use the functions below to access the contents of the PGresult structure.

B<$ntups = $result-&gtntuples

Returns the number of tuples in the query result.

B<$nfields = $result-&gtnfields>

Returns the number of fields in the query result.

B<$fname = $result-&gtfname($field_num)>

Returns the field name associated with the given field number. 

B<$fnumber = $result-&gtfnumber($field_name)>

Returns the field number associated with the given field name. 

B<$ftype = $result-&gtftype($field_num)>

Returns the oid of the type of the given field number. 

B<$fsize = $result-&gtfsize($field_num)>

Returns the size in bytes of the type of the given field number. 
It returns -1 if the field has a variable length.

B<$value = $result-&gtgetvalue($tup_num, $field_num)>

Returns the value of the given tuple and field. This is 
a null-terminated ASCII string. Binary cursors will not
work. 

B<$length = $result-&gtgetlength($tup_num, $field_num)>

Returns the length of the value for a given tuple and field. 

B<$null_status = $result-&gtgetisnull($tup_num, $field_num)>

Returns the NULL status for a given tuple and field. 

B<$result_status = $result-&gtresultStatus>

Returns the status of the result. For comparing the status you 
may use one of the following constants depending upon the 
command executed:
 - PGRES_EMPTY_QUERY
 - PGRES_COMMAND_OK
 - PGRES_TUPLES_OK
 - PGRES_COPY_OUT
 - PGRES_COPY_IN
 - PGRES_BAD_RESPONSE
 - PGRES_NONFATAL_ERROR
 - PGRES_FATAL_ERROR

B<$cmdStatus = $result-&gtcmdStatus>

Returns the command status of the last query command.

B<$oid = $result-&gtoidStatus>

In case the last query was an INSERT command it returns the oid of the 
inserted tuple. 

B<$result-&gtprintTuples($fout, $printAttName, $terseOutput, $width)>

Kept for backward compatibility. Use print.

B<$result-&gtprint($fout, $header, $align, $standard, $html3, $expanded, $pager, $fieldSep, $tableOpt, $caption, ...)>

Prints out all the tuples in an intelligent  manner. This function 
differs from the C-counterpart. The struct PQprintOpt has been 
implemented by a list. This list is of variable length, in order 
to care for the character array fieldName in PQprintOpt. 
The arguments $header, $align, $standard, $html3, $expanded, $pager
are boolean flags. The arguments $fieldSep, $tableOpt, $caption
are strings. You may append additional strings, which will be 
taken as replacement for the field names. 

B<PQclear($result)>

Old style only !
Frees all memory of the given result. 


=head2 3. Large Objects

These functions provide file-oriented access to user data. 
The large object interface is modeled after the Unix file 
system interface with analogues of open, close, read, write, 
lseek, tell. In order to get a consistent naming, all function 
names have been prepended with 'PQ' (old style only). 

B<$lobjId = $conn-&gtlo_creat($mode)>

Creates a new large object. $mode is a bitmask describing 
different attributes of the new object. Use the following constants: 
 - PGRES_INV_SMGRMASK
 - PGRES_INV_ARCHIVE
 - PGRES_INV_WRITE
 - PGRES_INV_READ

Upon failure it returns PGRES_InvalidOid. 

B<$ret = $conn-&gtlo_unlink($lobjId)>

Deletes a large object. Returns -1 upon failure. 

B<$lobj_fd = $conn-&gtlo_open($lobjId, $mode)>

Opens an existing large object and returns an object id. 
For the mode bits see lo_create. Returns -1 upon failure. 

B<$ret = $conn-&gtlo_close($lobj_fd)>

Closes an existing large object. Returns 0 upon success 
and -1 upon failure. 

B<$nbytes = $conn-&gtlo_read($lobj_fd, $buf, $len)>

Reads $len bytes into $buf from large object $lobj_fd. 
Returns the number of bytes read and -1 upon failure. 

B<$nbytes = $conn-&gtlo_write($lobj_fd, $buf, $len)>

Writes $len bytes of $buf into the large object $lobj_fd. 
Returns the number of bytes written and -1 upon failure. 

B<$ret = $conn-&gtlo_lseek($lobj_fd, $offset, $whence)>

Change the current read or write location on the large object 
$obj_id. Currently $whence can only be 0 (L_SET). 

B<$location = $conn-&gtlo_tell($lobj_fd)>

Returns the current read or write location on the large object 
$lobj_fd. 

B<$lobjId = $conn-&gtlo_import($filename)>

Imports a Unix file as large object and returns 
the object id of the new object. 

B<$ret = $conn-&gtlo_export($lobjId, $filename)>

Exports a large object into a Unix file. 
Returns -1 upon failure, 1 otherwise. 


=head1 AUTHOR

Edmund Mergl &ltE.Mergl@bawue.de&gt

=head1 SEE ALSO

libpq(3), large_objects(3).

=cut
