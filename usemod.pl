use strict;
use warnings;
use MyMod;
use Mojo::JSON qw/encode_json true false/;

my $mod = MyMod->new();
my $eop = $mod->is_eop();
print $eop . "\n";
$mod->is_eop(true);
print $mod->is_eop() . "\n";
print 'athlete ' . $mod->is_athlete() . "\n";
