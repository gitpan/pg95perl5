#-------------------------------------------------------
#
# Pg.pm,v 1.3 1995/10/15 17:26:44 mergl Exp
#
#-------------------------------------------------------


package Pg;

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

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
	PQclear
	PQprintTuples
	PQnotifies);


bootstrap Pg;


sub doQuery {

    local( $conn, $query, $array_ref ) = @_ ;

    local( $cmd, $result, $status, $nfields, $ntuples, $i, $j ) ;

    $cmd = "begin" ;
    $result = PQexec($conn, $cmd);
    $status = PQresultStatus($result);
    if (1 != $status) {
        PQclear($result);
        PQfinish($conn);
        return($status);
    }
    PQclear($result);

    $cmd = "declare eportal cursor for $query";
    $result = PQexec($conn, $cmd);
    $status = PQresultStatus($result);
    if (1 != $status) {
        PQclear($result);
        PQfinish($conn);
        return($status);
    }
    PQclear($result);


    $cmd = "fetch all in eportal";
    $result = PQexec($conn, $cmd);
    $status = PQresultStatus($result);
    if (2 != $status) {
        PQclear($result);
        PQfinish($conn);
        return($status);
    }

    $nfields = PQnfields($result);
    $ntuples = PQntuples($result);

    for ($i=0; $i < $ntuples; $i++) {
        for ($j=0; $j < $nfields; $j++) {
            if ( 0 == $j ) {
                $$array_ref[$i]  =        PQgetvalue($result, $i, $j);
            } else {
                $$array_ref[$i] .= "\t" . PQgetvalue($result, $i, $j);
            }
        }
    }
    PQclear($result);

    $cmd = "close eportal" ;
    $result = PQexec($conn, $cmd);
    $status = PQresultStatus($result);
    if (1 != $status) {
        PQclear($result);
        PQfinish($conn);
        return($status);
    }
    PQclear($result);

    $cmd = "end" ;
    $result = PQexec($conn, $cmd);
    $status = PQresultStatus($result);
    if (1 != $status) {
        PQclear($result);
        PQfinish($conn);
        return($status);
    }
    PQclear($result);

    return 0;

}


1;


#-------------------------------------------------------
# EOF
#-------------------------------------------------------
