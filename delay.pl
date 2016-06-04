use strict;
use warnings;
use Mojo::IOLoop::Delay;
use Data::Dumper;

my $to_repeat = 3;

sub get_repeat_sub {
	return sub {
		my $delay = shift;
		my $cb = $delay->begin();
		print ' counter is at ' . $delay->{counter} . "\n";
		$cb->();
		return;
	}
}

sub get_handler_sub {
	return sub {
		my $delay = shift;
		if ($to_repeat > 0){
			$delay->steps(get_repeat_sub(), get_handler_sub());
			$to_repeat--;
			$delay->pass();
		}
		print 'sub handled' . "\n";
		return;
	}
}

Mojo::IOLoop->delay(
	get_repeat_sub(),
	get_handler_sub(),
)->wait();
