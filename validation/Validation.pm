use Mojolicious::Validator;
use feature qw/say/;
use Data::Dumper;

my $validator = Mojolicious::Validator->new();
my $validation = $validator->validation;
$validation->input({emplid => '12345678', foo => 'bar'});
$validation->required('emplid')->like(qr/^\d{8}/mx);
$validation->required('type')->in('thematic', 'global');
say Dumper $validation->passed();
say Dumper $validation->output;
