package SwaggerApp;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin(Swagger2 => { url => $self->home->rel_file("swaggerapp.yaml") });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  $r->get('/home')->to(
  cb => sub {
    my $c = shift;
    $c->render(json => {home => $c->app()->home()});
  }
  );
}

1;
