use strict;
use warnings;
use ExtUtils::Installed;
use Data::Dumper;
my $inst = ExtUtils::Installed->new();
my @modules = $inst->modules();
for my $module (@modules) {
	print $module . "\n" unless $module eq 'Perl';
}
