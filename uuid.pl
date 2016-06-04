use strict;
use warnings;
use UUID::Tiny;
use feature qw/say/;

for my $i (1 .. 10) {
    say create_UUID_as_string();
}
