use strict;
use warnings;

my $thing = '123445667';
my $bool = $thing !~ m/^[0-9]+$/;
print  $bool;

print "\n";
