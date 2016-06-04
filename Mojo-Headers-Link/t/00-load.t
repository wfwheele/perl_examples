#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Mojo::Headers::Link' ) || print "Bail out!\n";
    use_ok( 'Mojo::Headers::Link::Value' ) || print "Bail out!\n";
}

diag( "Testing Mojo::Headers::Link $Mojo::Headers::Link::VERSION, Perl $], $^X" );
