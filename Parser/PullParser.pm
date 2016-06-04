package Parser::PullParser;
use XML::LibXML::Reader;

my $root = {};
my $currentNode = {};

sub get_perl{
    my $soap = shift;
    my $reader = XML::LibXML::Reader->new(string => $soap);
    while ($reader->read) {
        processNode($reader);
    }
    
    
}

sub processNode{
    my $reader = shift;
    return if $reader->depth() eq 0;
    printf "%d %d %s %d %d\n", ($reader->depth, $reader->nodeType, $reader->localName, $reader->isEmptyElement, $reader->hasValue);
    
    
    
}
1;