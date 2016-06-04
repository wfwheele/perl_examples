package Mojo::Headers::Link::Value;

use Mojo::Base '-base';

our $VERSION = '0.01';

has qw/url rel anchor rev hreflang media title title* type/;

has link_extensions => sub {
    return {};
};

sub parse {
    my ( $self, $link_value_string ) = @_;
    my @parts = split ';', $link_value_string;
    my $url = shift @parts =~ /^ < ( .* ) > ?/mx;
    $self->url( Mojo::URL->new($url) );
    for my $part (@parts) {
        my ( $key, $value ) = split '=', $part;
        if ( $self->can($key) ) {
            $self->$key($value);
        }
        else {
            $self->link_extensions()->{$key} = $value;
        }
    }
    return $self;
}

sub to_string {
    my $self       = shift;
    my $link_value = '';

    # url
    $link_value .= $self->url()->to_string();

    for $link_param (qw/url rel anchor rev hreflang media title title* type/) {
        $link_value .= '; ' . $link_param . '=' . $self->$link_param()
            if $self->$link_param;
    }

    #link extensions
    for my $link_extension ( keys %{ $self->link_extension() } ) {
        $link_value
            .= '; '
            . $link_extension . '='
            . $self->link_extenentioms()->{$link_extension};
    }

    return $link_value;

}

=head1 NAME

Mojo::Headers::Link::Value - A Mojo based object that represents Link-Values!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

A representation of a Link-Value.  Meant to be used in conjunction with
Mojo::Headers::Link.  Based on https://tools.ietf.org/html/rfc5988.

Perhaps a little code snippet.

    use Mojo::Headers::Link::Value;

    my $link_value = Mojo::Headers::Link::Value->new()->parse($string);
		my $link_value_string = $link_value->to_string();
    ...

=head1 SUBROUTINES/METHODS

=head2 parse
Parses a link-value string and populates the objects attributes
	my $link_value = Mojo::Headers::Link::Value->new->parse($string);

=head2 to_string
Retuns a string representation of the link value

=head1 AUTHOR

William Frank Wheeler II, C<< <wfwheele at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojo-headers-link at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojo-Headers-Link>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojo::Headers::Link::Value


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojo-Headers-Link>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojo-Headers-Link>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojo-Headers-Link>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojo-Headers-Link/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 William Frank Wheeler II.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;    # End of Mojo::Headers::Link::Value
