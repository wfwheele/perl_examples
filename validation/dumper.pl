use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new();
my $tx = $ua->post('http://httpbin.org/post' => json => {courses => [{id => 1}]});
$tx->req()->params()->append( %{ $tx->req()->json() // {} });
print Dumper $tx->req->params()->to_hash();
print Dumper $tx->req->json();
