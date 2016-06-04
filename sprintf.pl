use strict;
use warnings;

my $str = sprintf "%s %s ", 'sat', '1030-939-92';
print $str . "\n";
$str .= sprintf "%s %u", 'total', 10;
print $str . "\n";
