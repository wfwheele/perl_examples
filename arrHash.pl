#!/usr/bin/perl
use strict;
use warnings;
use Mojo::JSON qw/encode_json/;
my $object = { foo => 'bar', foo2 => undef, poop => { pooper => 'poopest' }, };

print encode_json($object) . "\n";

my $arr_ref = [1, 2, 3, 4, 5, 6];
print $#$arr_ref . "\n";
print 'HASH TEST' . "\n";
my $e_arr_ref = [];
my $hash = { v => 'v1', v2 => undef };
my $e_hash_ref = {};
my %e_hash = ();
print 'exists: ' . exists($hash->{v}) . "\n";
print 'on empty hash_ref : ' . ( not @{$e_arr_ref} or exists($e_hash_ref->{v})) . "\n";
print 'on empty hash : ' . exists($e_hash{v}) . "\n";
if(not @{$e_arr_ref} or exists($e_hash_ref->{v})){
	print 'statement was true' . "\n";
}else{
	print 'was false' . "\n";
}
