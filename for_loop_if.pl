use strict;
use warnings;

my @arr = (1, 2, 3, 4, 5, 6, 7);
my %hash = ( bar => 'bar');

if ($hash{foo}){
  for my $x (@arr) {
    print $x . ": 1\n";
  }
}
