use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new();
$ua->transactor()->add_generator('query' => sub {
		my ($self, $tx, $data ) = @_;
		$tx->req->url->query($data);

	});
	
my $tx = $ua->get( 'https://easapi:UpHQjuRn8twbIW4t43RvgftSKb3-SZ@ib.hubdev.buffalo.edu/PSIGW/RESTListeningConnector/UB_WS_APPLICATION.v1' => form => {admit_term => 2151, emplid => 36320503, institution => 'UBFLO' } );
print $tx->req->url->path_query . "\n";
print $tx->req->url->to_string . "\n";
print $tx->req->to_string . "\n";
print $tx->res->to_string . "\n";
