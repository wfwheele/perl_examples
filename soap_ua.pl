use strict;
use warnings;
use Mojo::UserAgent;
use SOAP::Lite;
my $ua = Mojo::UserAgent->new();
my $soap = q{<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" soapenc:arrayType="xsd:anyType[2]" xsi:type="soapenc:Array" soap:mustUnderstand="1"><wsu:Timestamp><wsu:Created>2015-06-16T15:40:10Z</wsu:Created><wsu:Expires>2015-06-16T15:45:10Z</wsu:Expires></wsu:Timestamp><wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:Username>session</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">nosession</wsse:Password></wsse:UsernameToken></wsse:Security></soap:Header><soap:Body><initialize xmlns="http://context.ws.blackboard" xsi:nil="true" /></soap:Body></soap:Envelope>};
my $tx = $ua->post('https://ublearnsqa.buffalo.edu/webapps/ws/services/Context.WS' => {Accept => '*/*'} => $soap);
print $tx->res->to_string . "\n";
