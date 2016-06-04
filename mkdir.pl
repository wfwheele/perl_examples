use strict;
use warnings;
use File::Slurp;
use Cwd;
use File::Path qw/make_path remove_tree/;

remove_tree( 'perlinium');
