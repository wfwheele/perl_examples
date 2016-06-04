use strict;
use warnings;
use Mojo::JSON qw/decode_json/;
use Data::Dumper;

my $json = q/{"foo":false, "bar":true}/;
my $decoded = decode_json $json;
print "is true" if $decoded->{foo};
print "is false" if not $decoded->{foo};
