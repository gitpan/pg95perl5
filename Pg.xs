/*-------------------------------------------------------
 *
 * Pg.xs,v 1.4 1995/10/15 17:42:14 mergl Exp
 *
 *-------------------------------------------------------*/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef bool
#undef bool
#endif

#include "libpq-fe.h"


MODULE = Pg	PACKAGE = Pg




PGconn *
PQsetdb(pghost, pgport, pgoptions, pgtty, dbname)
	char *	pghost
	char *	pgport
	char *	pgoptions
	char *	pgtty
	char *	dbname


void
PQfinish(conn)
	PGconn *	conn


void
PQreset(conn)
	PGconn *	conn


char *
PQdb(conn)
	PGconn *	conn


char *
PQhost(conn)
	PGconn *	conn


char *
PQoptions(conn)
	PGconn *	conn


char *
PQport(conn)
	PGconn *	conn


char *
PQtty(conn)
	PGconn *	conn


ConnStatusType
PQstatus(conn)
	PGconn *	conn


char *
PQerrorMessage(conn)
	PGconn *	conn


void
PQtrace(conn, debug_port)
	PGconn *	conn
	FILE *	debug_port


void
PQuntrace(conn)
	PGconn *	conn


PGresult *
PQexec(conn, query)
	PGconn *	conn
	char *	query


int
PQgetline(conn, maxlen)
	PGconn *	conn
	int	maxlen
	PPCODE:
	{
	    int ret ;
	    char * string = (char *)  calloc(1, maxlen + 1) ;
	    ret = PQgetline( conn, string, maxlen ) ;
	    EXTEND(sp, 2) ;
	    PUSHs(sv_2mortal(newSVnv(ret))) ;
	    PUSHs(sv_2mortal(newSVpv((char*)string, strlen(string)))) ;
	    free(string) ;
	}



int
PQendcopy(conn)
	PGconn *	conn


void
PQputline(conn, string)
	PGconn *	conn
	char *	string


ExecStatusType
PQresultStatus(res)
	PGresult *	res


int
PQntuples(res)
	PGresult *	res


int
PQnfields(res)
	PGresult *	res


char *
PQfname(res, field_num)
	PGresult *	res
	int	field_num


int
PQfnumber(res, field_name)
	PGresult *	res
	char *	field_name


Oid
PQftype(res, field_num)
	PGresult *	res
	int	field_num


int2
PQfsize(res, field_num)
	PGresult *	res
	int	field_num


char *
PQcmdStatus(res)
	PGresult *	res


char *
PQoidStatus(res)
	PGresult *	res


char *
PQgetvalue(res, tup_num, field_num)
	PGresult *	res
	int	tup_num
	int	field_num


int
PQgetlength(res, tup_num, field_num)
	PGresult *	res
	int	tup_num
	int	field_num


void
PQclear(res)
	PGresult *	res


void
PQprintTuples(res, fout, printAttName, terseOutput, width)
	PGresult *	res
	FILE *	fout
	int	printAttName
	int	terseOutput
	int	width


PGnotify *
PQnotifies(conn)
	PGconn *	conn


