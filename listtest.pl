#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my @list = (1 , 2, 3);
my @l2 = ( 4, 5, @list, 6);
print Dumper \@l2;