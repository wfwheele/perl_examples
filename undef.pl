use strict;
use warnings;
use Data::Dumper;

my %hash;
print "hash is not defined \n" if not %hash;

my $hash_ref = { foo => 'bar'};
%hash = %{$hash_ref};
print Dumper \%hash;
