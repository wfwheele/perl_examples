use strict;
use warnings;
use TAP::Harness;
use Data::Dumper;
use feature qw/say/;

my $harness = TAP::Harness->new( { color => 1 } );
$harness->rules(
    {   seq => [
            { seq => 't/setup/*.t' },
            { par => 't/*.t' },
            { seq => 't/setup/*.t' },
        ]
    }
);

my $setup_dir = 't/setup';

my @files;

push @files, read_dir_with_path('t/setup/');
push @files, read_dir_with_path('t/');
push @files, read_dir_with_path('t/teardown/');

$harness->runtests(@files);

sub read_dir_with_path {
    my $dir = shift;
    opendir my $dh, $dir or die 'Could not open dir ' . $dir;
    my @files = map { $dir . $_ } grep {/.*\.t$/} readdir $dh;
    closedir $dh;
    return \@files;
}
