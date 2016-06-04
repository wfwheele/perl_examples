#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Super::Util' ) || print "Bail out!\n";
}

diag( "Testing Super::Util $Super::Util::VERSION, Perl $], $^X" );
