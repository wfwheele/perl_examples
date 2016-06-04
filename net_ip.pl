use strict;
use warnings;
use Net::IP;
use feature qw/say/;

if ( my $ip = Net::IP->new('10.255.255.255') and $ip->iptype eq 'PRIVATE' ) {
	say "was ip";
	say $ip->iptype;
}
