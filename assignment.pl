use strict;
use warnings;
use feature qw/say/;

my $some_value = undef;
my $string = $some_value || 'default';

say $string;
