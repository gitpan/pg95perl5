/*-------------------------------------------------------
 *
 * $Id: Pg.xs,v 2.6 1997/02/15 08:52:54 mergl Exp $
 *
 * Copyright (c) 1997  Edmund Mergl
 *
 *-------------------------------------------------------*/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef bool
#undef bool
#endif

#ifdef DEBUG
#undef DEBUG
#endif

#ifdef ABORT
#undef ABORT
#endif

#include "postgres.h"
#include "libpq-fe.h"

typedef struct pg_conn* PG_conn;
typedef struct pg_result* PG_result;

static double
constant(name, arg)
char *name;
int arg;
{
    errno = 0;
    switch (*name) {
    case 'A':
	break;
    case 'B':
	break;
    case 'C':
	break;
    case 'D':
	break;
    case 'E':
	break;
    case 'F':
	break;
    case 'G':
	break;
    case 'H':
	break;
    case 'I':
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	break;
    case 'N':
	break;
    case 'O':
	break;
    case 'P':
	if (strEQ(name, "PGRES_CONNECTION_OK"))
	return 0;
	if (strEQ(name, "PGRES_CONNECTION_BAD"))
	return 1;
	if (strEQ(name, "PGRES_INV_SMGRMASK"))
	return 0x0000ffff;
	if (strEQ(name, "PGRES_INV_ARCHIVE"))
	return 0x00010000;
	if (strEQ(name, "PGRES_INV_WRITE"))
	return 0x00020000;
	if (strEQ(name, "PGRES_INV_READ"))
	return 0x00040000;
	if (strEQ(name, "PGRES_InvalidOid"))
	return 0;
	if (strEQ(name, "PGRES_EMPTY_QUERY"))
	return 0;
	if (strEQ(name, "PGRES_COMMAND_OK"))
	return 1;
	if (strEQ(name, "PGRES_TUPLES_OK"))
	return 2;
	if (strEQ(name, "PGRES_COPY_OUT"))
	return 3;
	if (strEQ(name, "PGRES_COPY_IN"))
	return 4;
	if (strEQ(name, "PGRES_BAD_RESPONSE"))
	return 5;
	if (strEQ(name, "PGRES_NONFATAL_ERROR"))
	return 6;
	if (strEQ(name, "PGRES_FATAL_ERROR"))
	return 7;
	break;
    case 'Q':
	break;
    case 'R':
	break;
    case 'S':
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    case 'a':
	break;
    case 'b':
	break;
    case 'c':
	break;
    case 'd':
	break;
    case 'e':
	break;
    case 'f':
	break;
    case 'g':
	break;
    case 'h':
	break;
    case 'i':
	break;
    case 'j':
	break;
    case 'k':
	break;
    case 'l':
	break;
    case 'm':
	break;
    case 'n':
	break;
    case 'o':
	break;
    case 'p':
	break;
    case 'q':
	break;
    case 'r':
	break;
    case 's':
	break;
    case 't':
	break;
    case 'u':
	break;
    case 'v':
	break;
    case 'w':
	break;
    case 'x':
	break;
    case 'y':
	break;
    case 'z':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}








MODULE = Pg		PACKAGE = Pg


double
constant(name,arg)
	char *		name
	int		arg


PGconn *
PQconnectdb(conninfo)
	char *	conninfo
	PROTOTYPE: $
	CODE:
		RETVAL = PQconnectdb((const char *)conninfo);
	OUTPUT:
		RETVAL


HV *
PQconndefaults()
	CODE:
		PQconninfoOption *infoOption;
		RETVAL = newHV();
                if (infoOption = PQconndefaults()) {
			while (infoOption->keyword != NULL) {
				hv_store(RETVAL, infoOption->keyword, strlen(infoOption->keyword), newSVpv(infoOption->val, 0), 0);
				infoOption++;
			}
		}
	OUTPUT:
		RETVAL


PGconn *
PQsetdb(pghost, pgport, pgoptions, pgtty, dbname)
	char *	pghost
	char *	pgport
	char *	pgoptions
	char *	pgtty
	char *	dbname
	PROTOTYPE: $$$$$


void
PQfinish(conn)
	PGconn *	conn
	PROTOTYPE: $


void
PQreset(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQdb(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQuser(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQhost(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQoptions(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQport(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQtty(conn)
	PGconn *	conn
	PROTOTYPE: $


ConnStatusType
PQstatus(conn)
	PGconn *	conn
	PROTOTYPE: $


char *
PQerrorMessage(conn)
	PGconn *	conn
	PROTOTYPE: $


void
PQtrace(conn, debug_port)
	PGconn *	conn
	FILE *	debug_port
	PROTOTYPE: $$


void
PQuntrace(conn)
	PGconn *	conn
	PROTOTYPE: $



PGresult *
PQexec(conn, query)
	PGconn *	conn
	char *	query
	PROTOTYPE: $$
	CODE:
		RETVAL = PQexec(conn, query);
                if (! RETVAL) { RETVAL = (PGresult *)calloc(1, sizeof(PGresult)); }
	OUTPUT:
		RETVAL


int
PQgetline(conn, string, length)
	PROTOTYPE: $$$
	PREINIT:
		SV *sv_buffer = SvROK(ST(1)) ? SvRV(ST(1)) : ST(1);
	INPUT:
		PGconn *	conn
		int	length
		char *	string = sv_grow(sv_buffer, length);
	CODE:
		RETVAL = PQgetline(conn, string, length);
	OUTPUT:
		RETVAL
		string


int
PQendcopy(conn)
	PGconn *	conn
	PROTOTYPE: $


void
PQputline(conn, string)
	PGconn *	conn
	char *	string
	PROTOTYPE: $$


void
PQnotifies(conn)
	PGconn *	conn
	PROTOTYPE: $
	PREINIT:
		PGnotify *notify;
	PPCODE:
		notify = PQnotifies(conn);
		if (notify) {
			XPUSHs(sv_2mortal(newSVpv((char *)notify->relname, 0)));
			XPUSHs(sv_2mortal(newSViv(notify->be_pid)));
			free(notify);
		}


ExecStatusType
PQresultStatus(res)
	PGresult *	res
	PROTOTYPE: $


int
PQntuples(res)
	PGresult *	res
	PROTOTYPE: $


int
PQnfields(res)
	PGresult *	res
	PROTOTYPE: $


char *
PQfname(res, field_num)
	PGresult *	res
	int	field_num
	PROTOTYPE: $$


int
PQfnumber(res, field_name)
	PGresult *	res
	char *	field_name
	PROTOTYPE: $$


Oid
PQftype(res, field_num)
	PGresult *	res
	int	field_num
	PROTOTYPE: $$


int2
PQfsize(res, field_num)
	PGresult *	res
	int	field_num
	PROTOTYPE: $$


char *
PQcmdStatus(res)
	PGresult *	res
	PROTOTYPE: $


char *
PQoidStatus(res)
	PGresult *	res
	PROTOTYPE: $
	PREINIT:
		const char *GAGA;
	CODE:
		GAGA = PQoidStatus(res);
		RETVAL = (char *)GAGA;
	OUTPUT:
		RETVAL


char *
PQgetvalue(res, tup_num, field_num)
	PGresult *	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


int
PQgetlength(res, tup_num, field_num)
	PGresult *	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


int
PQgetisnull(res, tup_num, field_num)
	PGresult *	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


void
PQclear(res)
	PGresult *	res
	PROTOTYPE: $


void
PQprintTuples(res, fout, printAttName, terseOutput, width)
	PGresult *	res
	FILE *	fout
	int	printAttName
	int	terseOutput
	int	width
	PROTOTYPE: $$$$$


void
PQprint(fout, res, header, align, standard, html3, expanded, pager, fieldSep, tableOpt, caption, ...)
	FILE *	fout
	PGresult *	res
	bool	header
	bool	align
	bool	standard
	bool	html3
	bool	expanded
	bool	pager
	char *	fieldSep
	char *	tableOpt
	char *	caption
	PROTOTYPE: $$$$$$$$$$$;@
	PREINIT:
		PQprintOpt ps;
		int i;
	CODE:
		ps.header    = header;
		ps.align     = align;
		ps.standard  = standard;
		ps.html3     = html3;
		ps.expanded  = expanded;
		ps.pager     = pager;
		ps.fieldSep  = fieldSep;
		ps.tableOpt  = tableOpt;
		ps.caption   = caption;
		Newz(0, ps.fieldName, items + 1 - 11, char*);
		for (i = 11; i < items; i++) {
			ps.fieldName[i - 11] = (char *)SvPV(ST(i), na);
		}
		PQprint(fout, res, &ps);
		Safefree(ps.fieldName);


int
lo_open(conn, lobjId, mode)
	PGconn *	conn
	Oid	lobjId
	int	mode
	PROTOTYPE: $$$
	ALIAS:
		PQlo_open = 1


int
lo_close(conn, fd)
	PGconn *	conn
	int	fd
	PROTOTYPE: $$
	ALIAS:
		PQlo_close = 1


int
lo_read(conn, fd, buf, len)
	PROTOTYPE: $$$$
	ALIAS:
		PQlo_read = 1
	PREINIT:
		SV *sv_buffer = SvROK(ST(2)) ? SvRV(ST(2)) : ST(2);
	INPUT:
		PGconn *	conn
		int	fd
		int	len
		char *	buf = sv_grow(sv_buffer, len + 1);
	CLEANUP:
		if (RETVAL >= 0) {
			SvCUR(sv_buffer) = RETVAL;
			SvPOK_only(sv_buffer);
			*SvEND(sv_buffer) = '\0';
			if (tainting) {
				sv_magic(sv_buffer, 0, 't', 0, 0);
			}
		}


int
lo_write(conn, fd, buf, len)
	PGconn *	conn
	int	fd
	char *	buf
	int	len
	PROTOTYPE: $$$$
	ALIAS:
		PQlo_write = 1


int
lo_lseek(conn, fd, offset, whence)
	PGconn *	conn
	int	fd
	int	offset
	int	whence
	PROTOTYPE: $$$$
	ALIAS:
		PQlo_lseek = 1


Oid
lo_creat(conn, mode)
	PGconn *	conn
	int	mode
	PROTOTYPE: $$
	ALIAS:
		PQlo_creat = 1


int
lo_tell(conn, fd)
	PGconn *	conn
	int	fd
	PROTOTYPE: $$
	ALIAS:
		PQlo_tell = 1


int
lo_unlink(conn, lobjId)
	PGconn *	conn
	Oid	lobjId
	PROTOTYPE: $$
	ALIAS:
		PQlo_unlink = 1


Oid
lo_import(conn, filename)
	PGconn *	conn
	char *	filename
	PROTOTYPE: $$
	ALIAS:
		PQlo_import = 1


int
lo_export(conn, lobjId, filename)
	PGconn *	conn
	Oid	lobjId
	char *	filename
	PROTOTYPE: $$$
	ALIAS:
		PQlo_export = 1




PG_conn
connectdb(conninfo)
	char *	conninfo
	PROTOTYPE: $
	CODE:
		RETVAL = PQconnectdb((const char *)conninfo);
	OUTPUT:
		RETVAL


HV *
conndefaults()
	CODE:
		PQconninfoOption *infoOption;
		RETVAL = newHV();
                if (infoOption = PQconndefaults()) {
			while (infoOption->keyword != NULL) {
				hv_store(RETVAL, infoOption->keyword, strlen(infoOption->keyword), newSVpv(infoOption->val, 0), 0);
				infoOption++;
			}
		}
	OUTPUT:
		RETVAL


PG_conn
setdb(pghost, pgport, pgoptions, pgtty, dbname)
	char *	pghost
	char *	pgport
	char *	pgoptions
	char *	pgtty
	char *	dbname
	PROTOTYPE: $$$$$
	CODE:
		RETVAL = PQsetdb(pghost, pgport, pgoptions, pgtty, dbname);
	OUTPUT:
		RETVAL







MODULE = Pg		PACKAGE = PG_conn		PREFIX = PQ


void
DESTROY(conn)
	PG_conn	conn
	PROTOTYPE: $
	CODE:
		/* printf("DESTROY connection\n"); */
		PQfinish(conn);


void
PQreset(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQdb(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQuser(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQhost(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQoptions(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQport(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQtty(conn)
	PG_conn	conn
	PROTOTYPE: $


ConnStatusType
PQstatus(conn)
	PG_conn	conn
	PROTOTYPE: $


char *
PQerrorMessage(conn)
	PG_conn	conn
	PROTOTYPE: $


void
PQtrace(conn, debug_port)
	PG_conn	conn
	FILE *	debug_port
	PROTOTYPE: $$


void
PQuntrace(conn)
	PG_conn	conn
	PROTOTYPE: $



PG_result
PQexec(conn, query)
	PG_conn	conn
	char *	query
	PROTOTYPE: $$
	CODE:
		RETVAL = PQexec(conn, query);
                if (! RETVAL) { RETVAL = (PGresult *)calloc(1, sizeof(PGresult)); }
	OUTPUT:
		RETVAL


int
PQgetline(conn, string, length)
	PROTOTYPE: $$$
	PREINIT:
		SV *sv_buffer = SvROK(ST(1)) ? SvRV(ST(1)) : ST(1);
	INPUT:
		PG_conn	conn
		int	length
		char *	string = sv_grow(sv_buffer, length);
	CODE:
		RETVAL = PQgetline(conn, string, length);
	OUTPUT:
		RETVAL
		string


int
PQendcopy(conn)
	PG_conn	conn
	PROTOTYPE: $


void
PQputline(conn, string)
	PG_conn	conn
	char *	string
	PROTOTYPE: $$


void
PQnotifies(conn)
	PG_conn	conn
	PROTOTYPE: $
	PREINIT:
		PGnotify *notify;
	PPCODE:
		notify = PQnotifies(conn);
		if (notify) {
			XPUSHs(sv_2mortal(newSVpv((char *)notify->relname, 0)));
			XPUSHs(sv_2mortal(newSViv(notify->be_pid)));
			free(notify);
		}


int
lo_open(conn, lobjId, mode)
	PG_conn	conn
	Oid	lobjId
	int	mode
	PROTOTYPE: $$$


int
lo_close(conn, fd)
	PG_conn	conn
	int	fd
	PROTOTYPE: $$


int
lo_read(conn, fd, buf, len)
	PROTOTYPE: $$$$
	PREINIT:
		SV *sv_buffer = SvROK(ST(2)) ? SvRV(ST(2)) : ST(2);
	INPUT:
		PG_conn	conn
		int	fd
		int	len
		char *	buf = sv_grow(sv_buffer, len + 1);
	CLEANUP:
		if (RETVAL >= 0) {
			SvCUR(sv_buffer) = RETVAL;
			SvPOK_only(sv_buffer);
			*SvEND(sv_buffer) = '\0';
			if (tainting) {
				sv_magic(sv_buffer, 0, 't', 0, 0);
			}
		}


int
lo_write(conn, fd, buf, len)
	PG_conn	conn
	int	fd
	char *	buf
	int	len
	PROTOTYPE: $$$$


int
lo_lseek(conn, fd, offset, whence)
	PG_conn	conn
	int	fd
	int	offset
	int	whence
	PROTOTYPE: $$$$


Oid
lo_creat(conn, mode)
	PG_conn	conn
	int	mode
	PROTOTYPE: $$


int
lo_tell(conn, fd)
	PG_conn	conn
	int	fd
	PROTOTYPE: $$


int
lo_unlink(conn, lobjId)
	PG_conn	conn
	Oid	lobjId
	PROTOTYPE: $$


Oid
lo_import(conn, filename)
	PG_conn	conn
	char *	filename
	PROTOTYPE: $$


int
lo_export(conn, lobjId, filename)
	PG_conn	conn
	Oid	lobjId
	char *	filename
	PROTOTYPE: $$$




MODULE = Pg		PACKAGE = PG_result		PREFIX = PQ


void
DESTROY(res)
	PG_result	res
	PROTOTYPE: $
	CODE:
		/* printf("DESTROY result\n"); */
		PQclear(res);


ExecStatusType
PQresultStatus(res)
	PG_result	res
	PROTOTYPE: $


int
PQntuples(res)
	PG_result	res
	PROTOTYPE: $


int
PQnfields(res)
	PG_result	res
	PROTOTYPE: $


char *
PQfname(res, field_num)
	PG_result	res
	int	field_num
	PROTOTYPE: $$


int
PQfnumber(res, field_name)
	PG_result	res
	char *	field_name
	PROTOTYPE: $$


Oid
PQftype(res, field_num)
	PG_result	res
	int	field_num
	PROTOTYPE: $$


int2
PQfsize(res, field_num)
	PG_result	res
	int	field_num
	PROTOTYPE: $$


char *
PQcmdStatus(res)
	PG_result	res
	PROTOTYPE: $


char *
PQoidStatus(res)
	PG_result	res
	PROTOTYPE: $
	PREINIT:
		const char *GAGA;
	CODE:
		GAGA = PQoidStatus(res);
		RETVAL = (char *)GAGA;
	OUTPUT:
		RETVAL


char *
PQgetvalue(res, tup_num, field_num)
	PG_result	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


int
PQgetlength(res, tup_num, field_num)
	PG_result	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


int
PQgetisnull(res, tup_num, field_num)
	PG_result	res
	int	tup_num
	int	field_num
	PROTOTYPE: $$$


void
PQprintTuples(res, fout, printAttName, terseOutput, width)
	PG_result	res
	FILE *	fout
	int	printAttName
	int	terseOutput
	int	width
	PROTOTYPE: $$$$$


void
PQprint(res, fout, header, align, standard, html3, expanded, pager, fieldSep, tableOpt, caption, ...)
	FILE *	fout
	PG_result	res
	bool	header
	bool	align
	bool	standard
	bool	html3
	bool	expanded
	bool	pager
	char *	fieldSep
	char *	tableOpt
	char *	caption
	PROTOTYPE: $$$$$$$$$$$;@
	PREINIT:
		PQprintOpt ps;
		int i;
	CODE:
		ps.header    = header;
		ps.align     = align;
		ps.standard  = standard;
		ps.html3     = html3;
		ps.expanded  = expanded;
		ps.pager     = pager;
		ps.fieldSep  = fieldSep;
		ps.tableOpt  = tableOpt;
		ps.caption   = caption;
		Newz(0, ps.fieldName, items + 1 - 11, char*);
		for (i = 11; i < items; i++) {
			ps.fieldName[i - 11] = (char *)SvPV(ST(i), na);
		}
		PQprint(fout, res, &ps);
		Safefree(ps.fieldName);

