use strict;
use warnings;
use JSON;
use Carp;
use File::Slurp;
use Data::Dumper;
use feature qw/say/;

confess 'no file given' if not defined $ARGV[0];
my $topics        = decode_json( read_file( $ARGV[0] ) )->{data};
my %global_topics = (
    "ASL 101: Introductory American Sign Language" => 1,
    "CHI 101: Introductory Chinese"                => 1,
    "Ancient Civilizations"                        => 1,
    "Spectacular Worlds"                           => 1,
    "Business, Economy and Society"                => 1,
);
my %thematic_topics = (
    "Cities and Societies"                => 1,
    "Understanding Racism"                => 1,
    "Design & The Built Environment"      => 1,
    "Health, Medicine, and Society"       => 1,
    "Media, Innovation, Entrepreneurship" => 1,
);
my @sparse_topics;

for my $topic ( @{$topics} ) {
    push @sparse_topics, $topic
        if exists $global_topics{ $topic->{topic_name} }
        or exists $thematic_topics{ $topic->{topic_name} };
}
say encode_json \@sparse_topics;
