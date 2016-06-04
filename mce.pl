use strict;
use warnings;
use feature qw/say/;
use MCE::Loop;
use Benchmark::Timer qw//;
use Data::Dumper;

my $max   = 20000;
my $timer = Benchmark::Timer->new();
$timer->start('mce');
my @results = mce_loop {
    my ( $mce, $chunk_ref, $chunk_id ) = @_;
    my @numbers;
    for ( @{$chunk_ref} ) {
        push @numbers, $_;
    }
    MCE->gather(@numbers);
}
0 .. 1000;
$timer->stop('mce');

my @other_results;
$timer->start('loop');
for my $number ( 0 .. $max ) {
    push @other_results, $number;
}
$timer->stop('loop');
my %results = $timer->results();
say Dumper \%results;
my $winner = $results{loop} < $results{mce} ? 'loop' : 'mce';

say "winner is $winner";
