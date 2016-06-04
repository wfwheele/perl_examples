use strict;
use warnings;
use Data::Dumper;
use Hash::Merge qw/merge/;

my $hash_ref = {foo => 'bar', faa => 'bor'};

my %new_hash_ref = (%{$hash_ref}, (faa => 'baa'));
print "using Hash::Merge\n" . Dumper merge($hash_ref, {faz => 'baa'});
print Dumper \%new_hash_ref;
print Dumper $hash_ref;
