#!/usr/bin/perl
use Data::Dumper;
my %hash = ( foo => 'bar' );
my $hash_ref =  {foo => 'bar'};
delete $hash_ref->{foo};
print Dumper $hash_ref;
print Dumper \%hash;
my $str = delete ($hash{foo}) . ' was removed form my hash' . "\n";
print $str;
print Dumper \%hash;
