use strict;
use warnings;
use Mojo::JSON::Pointer;

my $bool = Mojo::JSON::Pointer->new([ 'a', 'b' ] )->contains('/');
print $bool . "\n";
