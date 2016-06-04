use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

say join(':', split('open', 'open1'));
my (undef, $number) = split('open', 'open1');
say $number;

my $ip = '127.0.0.1';
say $ip;
my @parts = split '\.', $ip;
say Dumper \@parts;
