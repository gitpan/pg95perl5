# demo script, has been tested with:
#  - postgresql-v6.0
#  - apache_1.2b6
#  - mod_perl-0.93
#  - perl5.00317 + sfio-oct95

require Apache::CGI;
use Pg;

$| = 1; # need this for forms

my $query = new Apache::CGI;

print  $query->header,
       $query->start_html(-title=>'A Simple Example'),
       $query->startform,
       "<CENTER><H3>Testing Module Pg</H3></CENTER>",
       "Enter the database name: ",
       $query->textfield(-name=>'dbname'),
       "<P>",
       "Enter the select command: ",
       $query->textfield(-name=>'cmd', -size=>40),
       "<P>",
       $query->submit(-value=>'Submit'),
       $query->endform;

if ($query->param) {

    my $dbname = $query->param('dbname');
    my $conn = Pg::connectdb("dbname = $dbname");
    my $cmd = $query->param('cmd');
    my $result = $conn->exec($cmd);
    my $i, $j;
    print "<P><CENTER><TABLE CELLPADDING=4 CELLSPACING=2 BORDER=1>\n";
    for ($i=0; $i < $result->ntuples; $i++) {
        print "<TR>\n";
        for ($j=0; $j < $result->nfields; $j++) {
            print "<TD ALIGN=CENTER>", $result->getvalue($i, $j), "\n";
        }
    }

    print "</TABLE></CENTER><P>\n";
}

print $query->end_html;

