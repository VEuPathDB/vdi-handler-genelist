#!/usr/bin/perl

use strict;

my @envVars = ('DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_PLATFORM', 'DB_USER', 'DB_PASS');

my ($userDatasetId, $filesDir) = @ARGV;

usage() unless scalar(@ARGV) == 2;

for my $envVar @envVars { die "Missing env variable '$envVar'\n" unless $ENV{$envVar}; }

my $dbh = DBI->connect("dbi:$ENV{DB_PLATFORM'}:database=$ENV{DB_NAME};host=$ENV{DB_HOST};port=$ENV{DB_PORT}", $ENV{DB_USER}, $ENV{DB_PASS})
    || die "Couldn't connect to database: " . DBI->errstr;

$dbh->{RaiseError} = 1;

my $sth = $dbh->prepare(<<EOF);
    INSERT INTO ApiDBUserDatasets.UD_GeneId
    VALUES (?,?)
EOF

open(F, $geneListFile) || die "Can't open gene list file '$geneListFile'\n";
my $count = 0;
while(<F>) {
  chomp;
  $sth->execute($userDatasetId, $_);
   $dbh->commit if ($count++ % 1000 == 0);
}

$dbh->commit;

sub usage {

  my $envStr = join(", \$", @envVars);

  die "
Install a Gene List user dataset in the user dataset schema.

Usage: install-data user_dataset_id files_dir

Where:
  user_dataset_id:  a user dataset id
  files_dir:        a directory containing exactly one file.  This file is the gene_list_file, a txt file with one column per line containing a gene source id

Env: \$$envStr

";
}
