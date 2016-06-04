use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

my $filter_value = 'Spring 2017';

my ( $operator, $season, $year )
    = $filter_value =~ /^ ( > | < | >= | <= ) ? ( [ a-zA-Z ] + ) \ (\d +)/mx;

say Dumper [ $operator, $season, $year ];
say Dumper [ $1,        $2,      $3 ];
