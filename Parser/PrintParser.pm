package Parser::PrintParser;
use base qw(XML::SAX::Base);

sub new{
    my $class = shift;
	my %options = @_;
	return bless \%options, $class;
}

sub start_document{
    my ($self, $document) = @_;
    print "START DOCUMENT\n";
    $self->SUPER::start_document($document);
}

sub start_element{
    my ($self, $e) = @_;
    print 'START ELEMENT: ' . $e->{Name} . "\n";
    $self->SUPER::start_element($e);
    return;
}

sub characters {
    my ($self, $characters) = @_;
    print 'CHARACTERS: ' . $characters->{Data} . "\n";
    $self->SUPER::characters($characters);
    return
}

sub end_element {
    my ($self, $e) = @_;
    print 'END ELEMENT: ' . $e->{Name} . "\n";
    $self->SUPER::end_element($e);
    return;
}

sub end_document {
    my ($self, $document) = @_;
    print "END DOCUMENT\n";
}
1;