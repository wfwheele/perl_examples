use strict;
use warnings;
use Data::Dumper;
use feature qw/say/;

my $hash_ref = { ( foo => 'bar' ), ( bar => 'foo' ) };
say Dumper $hash_ref;
