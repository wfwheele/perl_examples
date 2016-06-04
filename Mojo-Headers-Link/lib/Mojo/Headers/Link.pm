package Mojo::Headers::Link;

use Mojo::Base '-base';

our $VERSION = '0.01';

has _values_ref => sub {
    return [];
};

sub parse {
    my ( $self, $link_string ) = @_;
    return if not $link_string;
    my @values = split ',', $link_string;
    for my $value (@values) {
        push @{ $self->_values_ref },
            Mojo::Headers::Link::Value->new()->parse($value);
    }
    return $self;
}

sub to_string {
    my $self = shift;
    return join ', ', map { $_->to_string() } @{ $self->_values_ref() };
}

sub to_array {
    my $self = shift;
    return $self->_values_ref();
}

sub to_hash {
    my $self = shift;
    my %hash = map { $_->rel => $_ } @{ $self->_values_ref() };
    return \%hash;
}

sub next {
    my $self = shift;
    state $next;
    return $next > $#{ $self->_values_ref() }
        ? undef
        : $self->_values_ref()->[ $next++ ];
}

=head1 NAME

Mojo::Headers::Link - Mojo based Link Header object!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS
Parses link header into digestable objects and offers methods to iterate through
and manipulate link values.

Perhaps a little code snippet.

    use Mojo::Headers::Link;

    my $link = Mojo::Headers::Link->new;
		$link->parse($res->headers->link);
    ...

=head ATTRIBUTES

=head2 link

=head1 SUBROUTINES/METHODS

=head2 parse
Parses the value of the link header into the Object
	my $link_header = Mojo::Headers::Link->new->parse($res->headers->link);

=head2 next
An iterator over the links, as there could be multiple link_values in the header
	while (my $link_value = $link_header->next){
		# do some stuff
	}

=head2 to_string
Stringifies the Link Headers
	say $link_header->to_string;
	$res->headers->link($link_header->to_string);

=head1 AUTHOR

William Frank Wheeler II, C<< <wfwheele at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojo-headers-link at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojo-Headers-Link>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojo::Headers::Link


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

__PACKAGE__;    # End of Mojo::Headers::Link
