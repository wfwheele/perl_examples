use strict;
use warnings;
use Mojo::UserAgent;
use feature qw/say/;

my $ua = Mojo::UserAgent->new();
my $tx = $ua->post('https://httpbin.org/post' => {'Content-Type' => 'application/json'} => q/{"foo":"bar"}/);
say $tx->res->to_string;
