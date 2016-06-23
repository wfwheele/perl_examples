use strict;
use warnings;
use Data::Dumper;
use feature qw/say/;

my $hash_ref = { ( foo => 'bar' ), ( bar => 'foo' ) };
say Dumper $hash_ref;

my %hash1 = ( foo => 'bar' );
my %hash2 = ( foo => 'xap' );

my %new_hash = ( %hash1, %hash2 );
say Dumper \%new_hash;
