use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;
use Crypt::JWT qw/encode_jwt decode_jwt/;
use MIME::Base64 qw(encode_base64url decode_base64url);

my $jwt = encode_jwt(
    payload => { career => 'UGRD', sequence => 1 },
    alg     => 'HS256',
    key     => 'p'
);

say "my jwt:\n" . $jwt;

my $data = decode_jwt( token => $jwt, key => 'p' );
say "my data:\n" . Dumper $data;

say "base64 encoding of UGRD-1:\n" . encode_base64url('GRAD:2');
