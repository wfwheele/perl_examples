package DoubleDelay::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
    my $self = shift;

    # Render template "example/welcome.html.ep" with message
    $self->render(
        msg => 'Welcome to the Mojolicious real-time web framework!' );
}

sub first_delay {
    my $self = shift;
    $self->delay(
        sub {
            my $delay = shift;
            $self->second_delay( $delay->begin() ); #offset is 0, see line 52
        },
        sub {
            my ( $delay, $is_valid ) = @_;
            $self->app->log->debug( $self->dumper( \@_ ) );
            #$self->render( json => { returns => $is_valid } );
            $self->ua->get('http://httpbin.org/get' => $delay->begin()) if $is_valid;
        },
        sub {
          my ($delay, $tx) = @_;
          #process them
					$self->render(data => $tx->res->body, format => 'json');
        }
    );
}

sub second_delay {
    my ($self, $cb) = @_;
    $self->reply->exception('no callback found in second_delay')
        if not defined $cb;
    my $value;
    $self->delay(
        sub {
            my $delay = shift;
            $self->ua->get( 'http://httpbin.org/get' => $delay->begin() );
        },
        sub {
            my ( $delay, $tx ) = @_;
            if ( $tx->success ) {
                $self->app->log->debug("second_delay was success");
                $self->app->log->debug( $self->dumper( $tx->res->json ) );
                #offset has to be 0 to call like this
                $cb->( undef, "true" );
            }
            else {
                $self->render( json => { error => "error" } );
            }
        }
    );
    $self->app->log->debug('done with second_delay sub');
    return;
}

1;
