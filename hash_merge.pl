use strict;
use warnings;
use Data::Dumper;

my $hash_ref  = { foo => 'bar' };
my $hash_ref2 = { faa => 'bor' };
my $hash_ref3 = { foo => 'baz' };
my %hash = ( foo => 'nar' );

print Dumper { %{$hash_ref}, %{$hash_ref2} };
print Dumper { %$hash_ref, %{ { foo => 'baz' } } };

print Dumper { %hash, ( faa => 'laa' ) };
