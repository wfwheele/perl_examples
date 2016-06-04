use Mojo::UserAgent;
use Mojo::IOLoop;
use Data::Dumper;
use DateTime;
use DateTime::Format::Duration;
use feature qw/say/;

my $ua = Mojo::UserAgent->new();
my $tx = $ua->get('http://mockbin.com/request');
say $tx->res->to_string;
