use 5.22.0;
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;

my %options;
GetOptions( 'foo=s@' => \$options{foo} );

say Dumper \%options;
