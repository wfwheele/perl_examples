use DateTime::Format::Oracle;
use DateTime;

my $timestamp = '2015-09-16-10.20.06.660110';
my $nls_timestamp_format = $ENV{'NLS_TIMESTAMP_FORMAT'};
$ENV{'NLS_TIMESTAMP_FORMAT'} = 'YYYY-MM-DD-HH24.MI.SSXFF';
my $dt = DateTime::Format::Oracle->parse_timestamp($timestamp);

$ENV{'NLS_TIMESTAMP_FORMAT'} = $nls_timestamp_format;

print $dt->iso8601();
