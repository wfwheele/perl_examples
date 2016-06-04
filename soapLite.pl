use strict;
use warnings;
use SOAP::Lite;
use XML::LibXML;
use Data::Dumper;
my $xml = q{<?xml version='1.0' encoding='UTF-8'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns:initializeResponse xmlns:ns="http://context.ws.blackboard"><ns:return>fe4b8a8183e94fee812de19d399e64ea</ns:return></ns:initializeResponse></soapenv:Body></soapenv:Envelope>};

my $des = SOAP::Deserializer->new();
my $parser = $des->parser(XML::LibXML->new());
my $som = $des->deserialize($xml);
print Dumper $som->body;
