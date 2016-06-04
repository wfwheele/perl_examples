use strict;
use warnings;
use Test::More;
use File::Slurp;

pass('this test passes');

is( read_file('setup/file_made.txt'),
    'We made a pretty great file!',
    'has the right stuff'
);

done_testing();
