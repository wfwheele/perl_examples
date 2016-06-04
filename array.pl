#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my @arr = (1,2,3,4,5);
my @arr2 = @arr;
print Dumper \@arr2;

@arr = (1,2);
shift @arr;
@arr2 = @arr;
print Dumper \@arr2;
print @arr2;
