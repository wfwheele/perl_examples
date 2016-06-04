use strict;
use warnings;
use Data::Dumper;
use feature qw/say/;

my %hash = map { $_ => undef } ( 1 .. 1 );
say Dumper \%hash;
