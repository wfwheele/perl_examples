use Mojolicious::Validator;
use feature qw/say/;
use Data::Dumper;

#general validation
my $validator  = Mojolicious::Validator->new();
my $validation = $validator->validation;
$validation->input( { emplid => '12345678', foo => 'bar' } );
$validation->required('emplid')->like(qr/^\d{8}/mx);
$validation->required('type')->in( 'thematic', 'global' );
$validation->optional('foo')->like(qr/^baz/mx);
say "Why did type fail?\n" . Dumper $validation->error('type');
say "Why did foo fail?\n" . Dumper $validation->error('foo');
say "Validation output\n" . Dumper $validation->output;
say "List of failed params:\n" . Dumper $validation->failed;
say "Does it have an error? " . ( $validation->has_error() ? 'true' : 'false' );

say "custom check here";

#use custom check (check = constraint in DFV)
$validator = Mojolicious::Validator->new();
$validator->add_check(
    foo => sub {
        my ( $validation, $name, $value, @args ) = @_;
        return 1 if $value eq 'bar';
        return undef;
    }
);
$validation = $validator->validation;
$validation->input( { biz => 'bar' } );
$validation->required('biz');
$validation->check( 'foo', 'biz' );
say "What failed the custom check?\n" . Dumper $validation->failed;

#try filtering
say "lets filter!";
$validator = Mojolicious::Validator->new();
$validator->add_filter(
    upper => sub {
        my ( $validation, $name, $value ) = @_;
        return uc $value;
    }
);
$validator->add_filter(
    kill_spaces => sub {
        my ( $validation, $name, $value ) = @_;
        return join( '', split( ' ', $value ) );
    }
);
$validation = $validator->validation;
say 'before filters: foo bar';
$validation->input( { thing => 'foo bar' } );
$validation->required( 'thing', 'kill_spaces', 'upper' );
say "after filters: " . $validation->param('thing');

#try the reason I hate DFV
say "does it handle an array of hashes?";
$validator = Mojolicious::Validator->new();
$validator->add_check(
    'valid_course_object',
    sub {
        my ( $validation, $name, $value, @args ) = @_;
        $validation->error( 'id' => "course id should be a digit" );
        say "from add_check";
        say Dumper $value;
        $validation->input($value);
        $validation->required('id')->like(qr/\d+/mx);
        return $validation->has_error()
            ? $validation->error('id')
            : undef;
    }
);
$validation = $validator->validation();
$validation->input( { courses => [ { id => 1 }, { id => 'foo' } ] } );
say "Input:\n" . Dumper $validation->input;
$validation->required('courses')->check( 'valid_course_object', 'courses' );
say "Did it fail? " . ( $validation->has_error() ? 'true' : 'false' );
say "Why\n" . Dumper $validation->error('courses') if $validation->has_error();
