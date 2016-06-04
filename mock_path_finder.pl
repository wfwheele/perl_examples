use Mojo::Base -strict;

#use Local::Mojo::EAS::UserAgent::EASAPI;
use Mojo::IOLoop::Delay;
use Mojo::UserAgent;

#my $ua Local::Mojo::EAS::UserAgent::EASAPI->new();
my $ua = Mojo::UserAgent->new;
Mojo::IOLoop::Delay->new()->steps(
    sub {
        my $delay = shift;
        $ua->get( 'http://httpbin.org/get' => $delay->begin() );
        my @txs;
        for ( 0 .. 10 ) {
            push @txs, $ua->get('http://httpbin.org/get');
        }
        $delay->pass(@txs);
    },
    sub {
        my ( $delay, @txs ) = @_;
        for my $tx (@txs) {
            say "ERROR" unless $tx->success();
						say "Success" unless $tx->error();
        }
    }
)->wait();
