package Test::Mojo::Mock::Server;
use Mojo::Base 'Mojolicious';
has 'mock_responses' => sub {
    return {};
};

sub startup {
    my $self = shift;

    # read files from <proj_dir>/mock_server
    # each filename is a host name
    # read the json from the file.
    for my $method (qw/get put post delete/) {
        $self->routes->$method('/*')->to(
            cb => sub {
                my $c = shift;
                $c->render( json => { path => $c->req->url->path } );
            }
        );
    }
}

1;
