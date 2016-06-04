#!/usr/bin/env perl
use Mojolicious::Lite;
use Data::Dumper;
use Benchmark::Timer;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

app->config(
    {   hypnotoad => {
            listen => ['http://*:19000'],

        }
    }
);

# hook before_render => sub {
#     my ( $c, $args ) = @_;
#     $args->{json} = { message => 'Resource Not Found' }
#         if $c->accepts('json')
#         and $args->{status} == 404;
#     return;
# };
# app->renderer->default_format('json');
hook before_render => sub {
    my ( $c, $args ) = @_;
    my $format = $c->accepts( 'html', 'json' );
    $c->app->log->debug( 'before_render args: ' . $c->dumper($args) );
    $c->app->log->debug( $c->dumper($format) );
    $args->{format} = $format if not $c->accepts($args->{format});
};

hook before_dispatch => sub {
  my ($c) = @_;
  my $format = $c->accepts('html', 'json');
  $c->app->log->debug("before dispatch accepts: " . $format);
  if(not $format){
    $c->stash({accept_header => $c->req()->headers()->accept()});
    $c->render(template => 'not_acceptable', format => 'html', status => 406);
  }
};

get '/' => sub {
    my $c = shift;
    $c->render( template => 'index' );
};

# get '/' => sub {
#     my $c = shift;
#     $c->respond_to(
#         json => { template => 'index' },
#         html => { template => 'index' }
#     );
# };

get '/json' => sub {
    my $c = shift;
    $c->render( json => { msg => 'json' } );
};

get '/test/:param' => [ param => qr/\d{3}/ ] => sub {
    my $c = shift;
    $c->stash({format => 'json'});
    $c->respond_to(
      json => {json => {msg => "three digit number"}},
      html => {template => 'test_param'},
    );
};

my $mayge = app->routes()->under()->to(
    cb => sub {
        my $c = shift;
        $c->app()->log()->debug('first chain');
        return 1;
    }
);

$mayge->get('/wait/:time')->to(
    cb => sub {
        my $c = shift;
        Mojo::IOLoop->timer(
            $c->param('time') => sub {
                $c->render( text => 'waited' );
            }
        );
    }
);

get '/get' => sub {
    my $c = shift;
    $c->delay(
        sub {
            my $delay = shift;
            $c->ua->get( 'http://httpbin.org/get' => $delay->begin() );
        },
        sub {
            my ( $delay, $tx ) = @_;
            if ( my $err = $tx->error() ) {
                $c->render( json => $err, status => $err->{code} );
            }
            else {
                $c->render( json => $tx->res->json );
            }
        },
    );
};

get '/request' => sub {
    my $c = shift;
    $c->render( text => $c->req->to_string() );
    return;
};

get '/server-error' => sub {
    my $c = shift;
    $c->reply()->exception();
    return;
};

get '/get-and-user-agent' => sub {
    my $c = shift;
    $c->delay(
        sub {

            my $delay   = shift;
            my $get_url = $c->url_for('/get');
            $c->ua->get( 'http://httpbin.org/user-agent' => $delay->begin() );
            $c->ua->get( 'http://httpbin.org/user-agent' => $delay->begin() );
        },
        sub {
            my ( $delay, @txs ) = @_;
            my @returns;
            for my $tx (@txs) {
                if ( my $err = $tx->error() ) {
                    push @returns, $err;
                }
                else {
                    push @returns, $tx->res->json();
                }
            }
            $c->render( json => \@returns );
        }
    );
};

app->start;
__DATA__
@@ not_found.json.ep
{
  "error":"resource not found"
}

@@ not_acceptable.json.ep
{
	"error":"<%= $accept_header %> cannot be generated"
}

@@ not_acceptable.html.ep
<!DOCTYPE html>
<html>
	<body>
		<h1>406</h1>
		<h2><%= $accept_header %> Not Acceptable</h2>
	</body>
</html>

@@ index.json.ep
{
	"message":"Welcome to the Mojolicious real-time web framework!"
}

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to the Mojolicious real-time web framework!

@@ test_param.html.ep
 % layout 'default';
 % title 'Test Param';
 Three digit param

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
