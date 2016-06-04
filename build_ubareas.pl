use strict;
use warnings;
use Data::Dumper;
use Mojo::JSON qw/encode_json decode_json true false/;

my $hash_ref =  { 'S' => true,
	'A' => false};

print Dumper $hash_ref;
