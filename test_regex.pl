use strict;
use warnings;
use Test::More;

like('text/html:charset=UTF-8', qr/text\/html/);
done_testing();
