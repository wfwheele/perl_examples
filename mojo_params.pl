use Mojo::Parameters;
use Mojo::URL;
use Data::Dumper;

my $params = Mojo::Parameters->new();
my $param_hash = {
  p1 => 'follow_redirects',
  p2 => 'other value',
  p3 => [
  {
    foo => 'bar',
  },
  {
    foo => 'baz',
  },
  ],
  p4 => [ "one", "two", "three"]
};
$params->append(%{$param_hash});

print $params . "\n";

print Dumper $params->to_hash();

print '===================== Params array ====================' . "\n";
$params = Mojo::Parameters->new();
my @ids = (0 .. 9);
$params->append(id => \@ids);
my $url = Mojo::URL->new('http://example.com/things');
$url->query(id => \@ids);
print $url . "\n";
print "deleteing query\n";

$url->query('');
print $url . "\n";
