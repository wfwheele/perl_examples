use 5.18.2;
use Swagger2::Client;
use Data::Dumper;
use Mojo::IOLoop::Delay;

my $ua
    = Swagger2::Client->generate('http://petstore.swagger.io/v2/swagger.json');

Mojo::IOLoop::Delay->new()->steps(
    sub {
        my $delay = shift;
        $ua->get_inventory( $delay->begin() );
        return;
    },
    sub {
        my ( $delay, $err, $res ) = @_;
        die $err if $err;
        say $res->to_string();
    },
    )->catch(
    sub {
        my ( $delay, $error ) = @_;
        say "Whoops, $error";
    }
    )->wait;
