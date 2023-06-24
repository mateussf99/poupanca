#!/usr/bin/perl
use DBI;
use strict;
use JSON;
#teste de entrada
open(ARQUIVO_X, 'entrada_investir.json');
my $json =<ARQUIVO_X>;
my $text = decode_json($json);
my $id = $text->{id};
my $do = $text->{do};#data da operação
my $vi = $text->{vi};#valor a investir
my $saldo = $text->{saldo};

# conectando no Banco
my $driver   = "SQLite"; 
my $database = "registro.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
   or die $DBI::errstr;#retorna o erro

print "database aberto com sucesso\n";

sub investir
{
    
    if($saldo > 0)
    {
        if($vi <= $saldo)
        {
            my $stmt = qq(INSERT INTO INVESTIMENTO (ID,DATA_OPERA,INVEST)
               VALUES ($id, '$do', $vi));
            my $rv = $dbh->do($stmt) or die $DBI::errstr;
            my $nov_saldo = $saldo - $vi;
            $dbh->disconnect();
            my %rec_hash = ('novo_saldo' => $nov_saldo);
            my $novo_saldo = encode_json \%rec_hash;
            return $novo_saldo;
        }
        else
        {
            $dbh->disconnect();
            my %rec_hash = ('novo_saldo' => 'saldo Insuficiente');
            my $novo_saldo = encode_json \%rec_hash;
            return $novo_saldo;
        }
    }
    else
    {
        $dbh->disconnect();
        my %rec_hash = ('novo_saldo' => 'saldo zerado');
        my $novo_saldo = encode_json \%rec_hash;
        return $novo_saldo;
    }

    
}
my $p = investir;
open(ARQUIVO_X, '>' , 'investir.json');
print ARQUIVO_X "$p";
close ARQUIVO_X