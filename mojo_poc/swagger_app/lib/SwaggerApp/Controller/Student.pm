package SwaggerApp::Controller::Student;
use Mojo::Base 'Mojolicious::Controller';

sub list {
  my ($c, $args, $cb) = @_;
  $c->$cb([{name => 'Courage Coward',}]);
  return;
}

sub single {
  my ($c, $args, $cb) = @_;
  $c->$cb({ name => 'Courage Corward'});
}

1;
