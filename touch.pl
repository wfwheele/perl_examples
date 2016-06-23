use strict;
use warnings;

my $file = 'file.txt';

open( my $fh, '>', $file ) or die "could not open file '$file' $!";

close $fh;
