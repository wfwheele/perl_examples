use strict;
use warnings;
use List::Util qw/first/;

my $value = 'foo';
my @array = ('bar', 'baz', 'foo');

my $result = first { $_ eq $value } @array;
print $result;
print "\n";
