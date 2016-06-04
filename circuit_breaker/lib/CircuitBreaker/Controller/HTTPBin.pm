package CircuitBreaker::Controller::HTTPBin;
use Mojo::Base 'Mojolicious::Controller';

sub wait {
  my $self = shift;
  $self->render(text => 'I lied no waiting happened here');
  return;
}
1;
