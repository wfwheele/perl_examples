use strict;
use warnings;
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new();
my $tx = $ua->post('https://acsdev.acsu.buffalo.edu:19000/external_messages' => json => { PersonNumber => 36107056, Term => 2091, PropertyName => 'EvalStatus', PropertyValue => 'HD', } );
print $tx->res->to_string;
