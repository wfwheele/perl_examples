use strict;
use warnings;
use feature qw/say/;

my $string = 'a string';
if(ref $string){
  say 'ref $string true';
}else {
  say 'ref $string false';
}
