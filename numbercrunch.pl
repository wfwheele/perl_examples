use strict;
use warnings;
use Math::NumberCruncher;
my @data = (1, 1, 1, 1, 1, 1, 1, 1, 1);
print Math::NumberCruncher::StandardDeviation(\@data, 5);
print "\n";
