#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use DBI;


#####teste de entrada#######
open(ARQUIVO_X, 'entrada_extrato.json');
my $json =<ARQUIVO_X>;
my $text = decode_json($json);
my $id = $text->{id};
############

my $driver = "SQLite";
my $database = "registro.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
   or die $DBI::errstr;
print "database aberto com sucesso\n";

my $stmt = qq(SELECT data_opera, invest from INVESTIMENTO where id = $id;);
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;

if($rv < 0) {
   print $DBI::errstr; #printa o erro
}
sub limpar
{
  open(ARQUIVO_X, '>' , 'extrato.json');
  print ARQUIVO_X "";
  close ARQUIVO_X
}
limpar;
while(my @row = $sth->fetchrow_array()) {
      my %rec_hash = ('DATA_OPERA' => $row[0],
                       'VALOR_INVEST' =>  $row[1]);
      my $extrato = encode_json \%rec_hash;
      my $p = $extrato;
      open(ARQUIVO_X, '+>>' , 'extrato.json');

      print ARQUIVO_X "$p,\n";
      close ARQUIVO_X
}