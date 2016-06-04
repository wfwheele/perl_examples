#!/usr/bin/perl
use warnings;
use strict;
use XML::LibXML;

my $document = XML::LibXML->createDocument();
my $soap_ns = 'https://schemas.xmlsoap.org/soap/envelope/';

my $root = $document->createElementNS($soap_ns, 'Envelope');
my $n = $document->createElement('getFoo');
$n->appendTextNode('bar');
$root->appendChild($n);
$document->setDocumentElement($root);

print $document->toString() . "\n";
print $document->is_valid() . "\n";
$document->validate();
