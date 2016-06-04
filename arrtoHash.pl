use strict;
use warnings;
use Data::Dumper;

my $hash = { a => 'b', c => 'd' };
my $arr = [%$hash];

print Dumper $arr;

my @arr2 = ( 'a', 'b', 'c' );
my %hash2 = @arr2;

print Dumper \%hash2;
