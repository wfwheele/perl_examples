package Parser::SOAP;
#use base qw(XML::SAX::Base);
use Moose;
use MooseX::NonMoose;
extends 'XML::LibXML::SAX';

sub new{
	my $class = shift;
	my %options = @_;
	return bless \%options, $class;
}

sub start_element {
	my $self = shift;
	my $data = shift;
	#do something
	#strip prefix
	my ($prefix, $base_name) = split ':', $data->{Name};
	$data->{Name} = $base_name ? $base_name : $prefix;
	$data->{Prefix} = '';
	#strip attributes
	$data->{Attributes} = {};
	#strip namespaces
	$data->{NamespaceURI} = '';
	$self->SUPER::start_element($data);
	return;
}
no Moose;
__PACKAGE__->meta->make_immutable;
