use Scalar::Util qw/blessed/;
use Mojo::Path;
use feature 'say';

my $scal = '/some/path';
say blessed($scal);
