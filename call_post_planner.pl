use strict;
use warnings;

use Mojo::UserAgent;
use Data::Dumper;
use feature qw/say/;
use Time::HiRes qw(time);
use Mojo::IOLoop::Delay;

my $body = {
    'thematic' => {
        'short_description' => '52',
        'report_description' =>
            'Screen Cultures --- COM 240LEC, ENG 380LEC, DMS 411SEM',
        'courses' => [
            {   'course_effective_date' => '1989-08-15',
                'course_offer_number'   => 1,
                'list_id'               => 1,
                'enrollment_status'     => 'n/a',
                'course_id'             => '002294',
                'course_title'          => 'Survey of Mass Communication'
            },
            {   'course_effective_date' => '2013-03-01',
                'course_offer_number'   => 1,
                'list_id'               => 2,
                'enrollment_status'     => 'n/a',
                'course_id'             => '015913',
                'course_title'          => 'New Media'
            },
            {   'course_effective_date' => '2016-03-01',
                'course_offer_number'   => 1,
                'list_id'               => 3,
                'enrollment_status'     => 'n/a',
                'course_id'             => '010176',
                'course_title'          => 'Film and Media Theory'
            }
        ],
        'description' => 'Thematic'
    },
    'global' => {
        'short_description' => '55',
        'report_description' =>
            'Business, Economy and Society --- ECO 182LD, GEO 330LEC, IE 409LEC',
        'courses' => [
            {   'course_effective_date' => '2013-08-15',
                'course_offer_number'   => 1,
                'list_id'               => 1,
                'enrollment_status'     => 'n/a',
                'course_id'             => '005812',
                'course_title'          => 'Introduction to Microeconomics'
            },
            {   'course_effective_date' => '1990-08-15',
                'course_offer_number'   => 1,
                'list_id'               => 2,
                'enrollment_status'     => 'n/a',
                'course_id'             => '001324',
                'course_title'          => 'Dynamics of International Business'
            },
            {   'course_effective_date' => '2011-03-01',
                'course_offer_number'   => 1,
                'list_id'               => 3,
                'enrollment_status'     => 'n/a',
                'course_id'             => '018782',
                'course_title'          => 'Six Sigma Quality'
            }
        ],
        'description' => 'Global'
    }
};

my $ua = Mojo::UserAgent->new();

$ua->on(
    start => sub {
        my ( $ua, $tx ) = @_;
        $tx->on(
            connection => sub {
                my $connection_time = time();
                $tx->attr('connection_start_time')
                    if not $tx->can('connection_start_time');
                $tx->connection_start_time($connection_time);
                return;
            }
        );
        $tx->on(
            finish => sub {
                my $finish_time = time();
                $tx->attr('finish_time')
                    if not $tx->can('finish_time');
                $tx->finish_time($finish_time);
                $tx->attr('elapsed_time')
                    if not $tx->can('elapsed_time');
                $tx->elapsed_time(
                    $finish_time - $tx->connection_start_time() );
                return;
            }
        );
    }
);

my @students = (
    '50180353', '50183966', '50173724', '50185817', '50182836', '50180242',
    '50177863', '50185613', '50203920', '50197984', '50181709', '50061336',
    '50185622', '50190489', '50150659', '50174499', '50187199', '50192737',
    '50198682', '50182073', '50196000', '50177955', '50194860', '50171895',
    '50176716',
);

Mojo::IOLoop::Delay->new->steps(
    sub {
        my $delay = shift;
        for my $student (@students) {

            my $url = Mojo::URL->new(
                sprintf
                    q|https://wfwheele:(Alukwr2s)@myubqa.buffalo.edu/psapi/v1/students/%s/path-finder-exceptions|,
                $student
            );

            my $tx = $ua->put( $url => json => $body => $delay->begin() );

        }
    },
    sub {
        my ( $delay, @txs ) = @_;
        for my $tx (@txs) {
            if ( $tx->success() ) {
                say "Success";
            }
            else {
                say "ERROR:";
                say Dumper $tx->error();
            }
            say sprintf "Start: %s | End: %s | Elapsed: %s",
                $tx->connection_start_time(), $tx->finish_time(),
                $tx->elapsed_time();
            say $tx->res()->to_string;
            say "\n";
        }
    },
    )->catch(
    sub {
        my ( $delay, $err ) = @_;
        say "Something went wrong: $err";
    }
    )->wait();
