use strict;
use warnings;
use Data::Dumper;
my $string = "one\non\neach\nline";
my @arr = split /\n/, $string;
print Dumper \@arr;
