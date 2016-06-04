#!/usr/bin/perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::IOLoop;

my $ua = Mojo::UserAgent->new();
Mojo::IOLoop->delay(
	sub {
		my $delay = shift;
		for ( 1 .. 5 ) {
			$ua->get('https://acsdev.acsu.buffalo.edu:19000/users?name=wfwheele' => $delay->begin);
		}
	},
	sub {
		my $delay = shift;
		my @txs = @_;
		for my $tx (@txs){
			print $tx->res->body . "\n\n";
		}
	},
)->wait;
print "done\n";
