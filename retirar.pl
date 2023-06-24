#!/usr/bin/perl
use DBI;
use JSON;
# use strict;

#teste de entrada
open(ARQUIVO_X, 'entrada_retirar.json');
my $json =<ARQUIVO_X>;
my $text = decode_json($json);
my $id = $text->{id};
my $dr = $text->{dr};#data da retirada
my $do = $text->{do};#data do investimento
my $saldo = $text->{saldo};

###############
my $driver = "SQLite";
my $database = "registro.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
   or die $DBI::errstr;
print "database aberto com sucesso\n";

my $stmt = qq(SELECT invest, data_opera from INVESTIMENTO WHERE id = ($id) AND data_opera LIKE ('$do'););
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;
my @row = $sth->fetchrow_array();

if($rv < 0) {
   print $DBI::errstr; #printa o erro
}

print "DATA_OPERA = ". $row[1] ."\n";
print "VALOR_INVEST =  ". $row[0] ."\n\n";

sub data
{  
   my @dat = split('/' , $row[1]);
   my @datr = split('/' , $dr);
   my $ano = $datr[2] - $dat[2];
   my $mes = $datr[1] - $dat[1];
   my $dia = $datr[0] - $dat[0];
   if($ano == 0 && $dia == 0 && $mes > 0)
   {
      return $mes;
   }
   elsif($ano == 0 && $dia < 0)
   {
      return 0;
   }
   elsif($ano > 0 && $ano < 2 && $mes < 0 && $dia < 0)
   {
      return 11 - $mes;
   }
   elsif($ano == 1 && $mes < 0 && $dia < 0)
   {
      return 12 - ($mes * -1) -1;
   }
   elsif($ano == 1 && $mes < 0 && $dia > 0)
   {
      return 12 - ($mes * -1);
   }
   elsif($ano == 1 && $mes > 0 && $dia >= 0 )
   {
      return 12 + $mes;
   }
   elsif($ano == 1 && $mes > 0 && $dia < 0 )
   {
      return 12 + $mes - 1;
   }
   elsif($ano > 1 && $mes < 0 && $dia >= 0)
   {
      return (12 * $ano) - ($mes * -1);
   }
   elsif($ano > 1 && $mes < 0 && $dia <= 0)
   {
      return (12 * $ano) - ($mes * -1)-1;
   }
   elsif($ano > 1 && $mes > 0 && $dia >= 0)
   {
      return (12 * $ano) + $mes;
   }
   elsif($ano > 1 && $mes > 0 && $dia <= 0)
   {
      return (12 * $ano) + $mes -1;
   }
}
print data . "\n";

sub rendimento
{
   my $tempo = data;
   my $valor_i = $row[0];
   while($tempo > 0)
   {
      $valor_i += ($valor_i * 0.006501);
      $tempo--;
   }
   
   my $nov_saldo = $valor_i + $saldo;
   return $nov_saldo;

}

sub alteracao
{
   my $valor_i = rendimento;
   my $do = $row[1];
   my $stmt = qq(INSERT INTO RETIRADA (ID,DATA_OPERA,DATA_RETIRADA,INVEST)
               VALUES ($id, '$do', '$dr', $valor_i));
   my $rv = $dbh->do($stmt) or die $DBI::errstr;

   my $stmt = qq(DELETE FROM INVESTIMENTO WHERE ID = $id AND DATA_OPERA = '$do');
   my $rv = $dbh->do($stmt) or die $DBI::errstr;
   #$dbh->disconnect();
   return 0;
}
my %rec_hash = ('novo_saldo' => rendimento);
my $novo_saldo = encode_json \%rec_hash;
alteracao;
my $p = $novo_saldo;
open(ARQUIVO_X, '>' , 'retirar.json');

print ARQUIVO_X "$p";
close ARQUIVO_X