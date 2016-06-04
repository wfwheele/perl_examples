use strict;
use warnings;
use Data::Dumper;
use feature qw/say/;

my ($input_data) = @{paths => { path => []}}{qw/data/};
say Dumper $input_data;
