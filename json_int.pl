use Mojo::JSON qw/decode_json encode_json/;
use B;

my $obj = {
  id => 1234,
  char_field => "hello",
  mixed_field => "hello1234",
  other_int => "1234",
};

print encode_json $obj;
print "\n";

my $int_wannabe = "1";
my $actual_int = 1;
my $bool = 1;
if ( B::svref_2object(\$int_wannabe)->FLAGS & (B::SVp_IOK | B::SVp_NOK)
    && 0 + $int_wannabe eq $int_wannabe
    && $int_wannabe * 0 == 0){
      print "Number\n";
    }else{
      print "Character\n";
    }
print B::svref_2object(\$int_wannabe)->FLAGS . "\n";
print B::SVp_IOK;
print "\n";
print B::SVp_NOK;
print "\n";
print (B::SVp_IOK | B::SVp_NOK);
print "\n";
print B::svref_2object(\$int_wannabe)->FLAGS & (B::SVp_IOK | B::SVp_NOK);
