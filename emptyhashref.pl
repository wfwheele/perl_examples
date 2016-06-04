use strict;
use warnings;

my $ref = {};
my $bool = (%$ref and not undef);
print $bool;
print "\n";
print '%$ref: ' . %$ref . "\n";
