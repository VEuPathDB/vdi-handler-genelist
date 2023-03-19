#!/usr/bin/perl

use strict;
use warnings;
use lib "$ENV{GUS_HOME}/lib/perl";

use GUS::Supported::GusConfig;
use GUS::ObjRelP::DbiDatabase;

my ($userDatasetId, $projectId) = @ARGV;

usage() unless $userDatasetId && $projectId;

my $gusconfig = GUS::Supported::GusConfig->new("$ENV{GUS_HOME}/config/$projectId/gus.config");

my $db = GUS::ObjRelP::DbiDatabase->new($gusconfig->getDbiDsn(),
                                        $gusconfig->getDatabaseLogin(),
                                        $gusconfig->getDatabasePassword(),
                                        0,0,1,
                                        $gusconfig->getCoreSchemaName());
my $dbh = $db->getQueryHandle(0);

my $sth = $dbh->prepare(<<EOF);
    DELETE from ApiDBUserDatasets.UD_GeneId
    WHERE user_dataset_id = ?
EOF
$sth->execute($userDatasetId);

$dbh->commit;

sub usage {
  die "
Uninstall a Gene List user dataset from the user datasets schema.
Usage:  uninstallGeneListUserDataset user_dataset_id project_id
Where:
  user_dataset_id:  a user dataset id
  project_id:       PlasmoDB, etc.
Finds gus.config in \$GUS_HOME/config/project_id/gus.config
";
}
