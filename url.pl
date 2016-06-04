use Mojo::URL;
use Mojo::Path;
use MooseX::Params::Validate;
use Data::Dumper;

sub append_path_to_url {
    print Dumper \@_;

    return;
}

my $url  = Mojo::URL->new('https://poop.com/stuff')->userinfo('foo:nar');
my $url2 = Mojo::URL->new($url);
print $url->userinfo() . "\n";
print $url->authority() . "\n";
print $url->to_string() . "\n";
delete $url->{userinfo};
print $url->userinfo() . "\n";
print $url->authority() . "\n";
print $url->to_string() . "\n";

print "trailing_slash(1)\n";
$url->path()->trailing_slash(1);
print $url->to_string() . "\n";
print "changing path\n";
$url->path->merge('some/path');
print $url . "\n";

print "path object\n";
my $path = Mojo::Path->new('more/path');
$url->path->merge($path);

append_path_to_url( url => $url, path => Mojo::Path->new('/bull/shit') );

print $url->to_string . "\n";
print "url2\n";
print $url2->userinfo() . "\n";
print $url2->authority() . "\n";
print $url2->to_string() . "\n";
