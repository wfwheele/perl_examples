use strict;
use warnings;
use Data::Dumper;

my %hash;

$hash{foo}{bar} = 'foobar';
print Dumper \%hash;
