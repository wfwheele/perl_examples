package Parser::P2;
#use base qw(XML::SAX::Base);
use Moose;
use MooseX::NonMoose;
use Data::Dumper;
use Carp;
extends 'XML::LibXML::SAX';
#sub new{
#        my $class = shift;
#        my %options = @_;
#        return bless \%options, $class;
#}

sub start_document{
        #initialize variables
        my ($self, $document) = @_;
        $self->{keys} = [];
        $self->{vals} = [];
        $self->{objs} = [];
        $self->{obj_names} = [];        
}

sub start_element{
        my ($self, $element) = @_;
	#print "start element : $element->{Name} \n";
        #if there are keys then the current key is an obj which this element is part of
	#print "    last element is an object \n" if @{$self->{keys}};
	if (@{$self->{keys}}) {
		push( @{$self->{obj_names}}, pop @{$self->{keys}}) if @{$self->{keys}};
		push @{$self->{objs}}, {};
	}
        push(@{$self->{keys}}, $element->{Name});
        $self->SUPER::start_element($element);
        return;
}

sub characters{
        my ($self, $characters) = @_;
        push @{$self->{vals}}, $characters->{Data};
        $self->SUPER::characters($characters);
        return;
}

sub end_element{
        my ($self, $element) = @_;
	
	#print "end element : $element->{Name} \n";
	#print "Current Status: \n" . Dumper($self->{objs}) . "\n\n" . Dumper($self->{keys}) . "\n\n" . Dumper($self->{obj_names});
        if (@{$self->{keys}}) {
                #this element is not an object
		#print "    this element is not an object \n";
                my $key = pop @{$self->{keys}};
                my $curr_obj_name = $self->_get_curr_obj_name();
                my $curr_obj = $self->_get_curr_obj();
                if ( not @{$self->{objs}} or exists($curr_obj->{$curr_obj_name})) {
                        #make new obj
			#print "        make new obj \n";
                        my $new_obj = { $key => pop @{$self->{vals}}};
                        push @{$self->{objs}}, $new_obj;
                }else{
                        #add to current object
			#print "        add to current object \n";
                        $curr_obj->{$key} = pop @{$self->{vals}};
                }
        }else{
                #this element is an object
		#print "    this element is an object \n";
                my $obj = pop @{$self->{objs}};
                my $obj_name = pop @{$self->{obj_names}};
                if (not @{$self->{objs}}) {
                        #make new object and add this obj to it
			#print "        make new object and add this obj to it \n";
                        my $new_obj = { $obj_name => $obj};
                        push @{$self->{objs}}, $new_obj;
                }elsif(exists($self->_get_curr_obj->{$obj_name})){
                        #this is part of an array, make one if it isn't or push it
                        my $parent = pop @{$self->{objs}};
                        if (ref($parent->{$obj_name}) eq 'ARRAY') {
                                push @{$parent->{$obj_name}}, $obj;
                        }else{
                                my $o2 = $parent->{$obj_name};
                                $parent->{$obj_name} = [$o2, $obj];
                        }
                        push @{$self->{objs}}, $parent;
                }else{
                        #just add it to the next obj
			#print "    just add it to the next obj \n";
                        my $parent = pop @{$self->{objs}};
                        $parent->{$obj_name} = $obj;
                        push @{$self->{objs}}, $parent;
                }
                
        }
        
        
        $self->SUPER::end_element($element);
        return;
}

sub end_document{
        my ($self, $document) = @_;
        $self->SUPER::end_document($document);
        return pop @{$self->{objs}};
}

sub _should_make_obj{
        my $self = shift;
        
        
}

sub _get_curr_obj_name{
        my $self = shift;
        my $name = pop @{$self->{obj_names}};
        push @{$self->{obj_names}}, $name;
        return $name;
}

sub _get_curr_obj{
        my $self = shift;
        my $obj = pop @{$self->{objs}};
        push @{$self->{objs}}, $obj if $obj;
        return $obj if $obj;
        return {};
}

sub _add_as_array{
        my ($self, $obj, $key, $val) = @_;
        if (ref $obj->{$key} eq 'ARRAY') {
                #can add to the array
                push @{$obj->{$key}}, $val;
        }else {
                #must build an array first
                my @new_array = ( $obj->{$key}, $val );
                $obj->{$key} = \@new_array;
        }
        return;
}
no Moose;
__PACKAGE__->meta->make_immutable;
