#!/usr/bin/perl

use strict;
use lib "$ENV{GUS_HOME}/lib/perl";

use GUS::Supported::GusConfig;
use GUS::ObjRelP::DbiDatabase;

use File::Find;
use File::Basename;

my ($userDatasetId, $geneListFile, $projectId) = @ARGV;

usage() unless scalar(@ARGV) == 3;

my $gusconfig = GUS::Supported::GusConfig->new("$ENV{GUS_HOME}/config/$projectId/gus.config");

my $db = GUS::ObjRelP::DbiDatabase->new($gusconfig->getDbiDsn(),
                                        $gusconfig->getDatabaseLogin(),
                                        $gusconfig->getDatabasePassword(),
                                        0,0,1,
                                        $gusconfig->getCoreSchemaName());

my $dbh = $db->getQueryHandle(0);
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
  die "
Install a Gene List user dataset in the user dataset schema.
Usage installGeneListUserDataset user_dataset_id gene_list_file project_id
Where:
  user_dataset_id:  a user dataset id
  gene_list_file:   a txt file with one column per line, a gene source id
  project_id:       PlasmoDB, etc.
Finds gus.config in \$GUS_HOME/config/project_id/gus.config
";
}
