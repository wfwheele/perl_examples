use Mojo::UserAgent;
use Mojo::IOLoop;
use Data::Dumper;
use DateTime;
use DateTime::Format::Duration;

my $ua = Mojo::UserAgent->new();
my $begin_time = DateTime->now();
my $number_of_calls = 200;
Mojo::IOLoop->delay(
	sub {
		my $delay = shift;
		
		for (1 .. $number_of_calls){
			$ua->get('http://128.205.133.160:3000/get-and-user-agent' => $delay->begin);
		}
	},
	sub {
		my ($delay, @txs) = @_;
		my $errors = 0;
		for my $tx (@txs) {
			print $tx->res->to_string() . "\n";
			print Dumper($tx->error()) . "\n" if $tx->error();
			$errors++ if $tx->error();
		}
		print 'number of errors: ' . $errors . "\n";
		print 'number of success: ' . ($number_of_calls - $errors) . "\n";
		my $end_time = DateTime->now();
		my $d = DateTime::Format::Duration->new(
			pattern => '%Y years, %m month, %e days, %h hours, %M minutes, %S seconds'
		);
		print 'elapsed time: ' . $d->format_duration($end_time->subtract_datetime($begin_time)) . "\n";
	},
)->wait;
