use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'Mojo::Headers::Link::Value'
        || BAIL_OUT('could load Mojo::Headers::Link::Value');
}

my $link_value = Mojo::Headers::Link::Value->new();
for my $attribute (qw/url rel anchor rev hreflang media title title* type/) {
    is( $link_value->$attribute(),
        undef, "Default value for $attribute is undef" );
}

$link_value->parse(
    q|<http://example.com/TheBook/chapter2>; rel="previous";
         title="previous chapter"|
);

isa_ok( $link_value->url(), 'Mojo::URL', 'url attribute isa Mojo::URL object' );
is( $link_value->rel(),   'previous',         'rel parsed correctly' );
is( $link_value->title(), 'previous chapter', 'title parse correctly' );
