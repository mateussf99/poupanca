#!/usr/bin/perl
use DBI;
use strict;

my $driver = "SQLite";
my $database = "registro.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
   or die $DBI::errstr;
print "database aberto com sucesso\n";

my $stmt = qq(SELECT id, data_opera, invest from INVESTIMENTO;);
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;

if($rv < 0) {
   print $DBI::errstr; #printa o erro
}

while(my @row = $sth->fetchrow_array()) {
      print "ID = ". $row[0] . "\n";
      print "DATA_OPERA = ". $row[1] ."\n";
      print "VALOR_INVEST =  ". $row[2] ."\n\n";
}

my $stmt = qq(SELECT id, data_opera, data_retirada, invest from RETIRADA;);
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;

if($rv < 0) {
   print $DBI::errstr; #printa o erro
}

while(my @row = $sth->fetchrow_array()) {
      print "ID = ". $row[0] . "\n";
      print "DATA_OPERA = ". $row[1] ."\n";
      print "DATA_RETIRADA = ". $row[2] ."\n";
      print "VALOR_INVEST =  ". $row[3] ."\n\n";
}
print "Operacao realizada com sucesso\n";
$dbh->disconnect();