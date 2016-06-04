use strict;
use warnings;
use Mojo::UserAgent;
use feature qw/say/;

my $ua = Mojo::UserAgent->new();
$ua->on(start => sub {
  my ($ua, $tx) = @_;
  say 'ua started';
  $tx->on(connection => sub {
    say 'tx connected';
  });
  $tx->on(finish => sub {
    say 'tx finished';
  });
  $tx->on(request => sub {
    my ($tx) = @_;
    say 'on request';
  });
});
my $tx = $ua->get('http://httpbin.org/get');
say $tx->res()->to_string();
