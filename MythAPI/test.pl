#!/usr/bin/perl

use MythAPI;
use Data::Dumper;

my $mythAPI = MythAPI->new(server=>'localhost');
my $data = $mythAPI->GetUpcomingList();
print Dumper($data);
