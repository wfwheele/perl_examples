package MyMod;
use strict;
use warnings;
use Mojo::Base 'Mojo::Base';
use Data::Dumper;
use Mojo::JSON qw/true false/;
use Exporter 'import';

has 'is_eop' => sub { return false; };

has 'is_athlete' => (
	is	=> 'rw',
	isa	=> 'Bool',
	Default	=> false,
);

1;
