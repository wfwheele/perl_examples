use strict;
use warnings;
use WebService::Slack::WebApi;
use Data::Dumper;

my $slack = WebService::Slack::WebApi->new(
    token => 'xoxp-10750426769-10746196325-18674058803-a42c1083ce' );

my $user = $slack->users->info(user => 'U0AMY5S9K');
print Dumper $user;
