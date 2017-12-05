# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Poloniex-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use JSON::MaybeXS qw(encode_json);
use Test::More qw(no_plan);

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Poloniex::API;

BEGIN {
    use_ok('Poloniex::API');
    eval { use Test::MockObject; 1 }
      || plan skip_all => 'Poloniex::API required for this test!';
}

my @test = (
    {
        agent  => \&lwp_mock,
        resp   => { result => 'returnTicker' },
        method => 'returnTicker',
    },
    {
        agent        => \&lwp_mock,
        resp         => { result => 'tereturnOrderBookst' },
        method       => 'returnOrderBook',
        request_args => { currencyPair => 'BTC_ZEC', depth => 10 },
    }
);

my $api = Poloniex::API->new(
    APIKey => 'YOUR-API-KEY-POLONIEX',
    Secret => 'YOUR-SECRET-KEY-POLONIEX'
);

foreach my $test (@test) {
    ++$test->{resp}{ok};

    my ( $mock_agent, $mock_response, @call_order ) =
      $test->{agent}->( $test->{resp} );
    $api->{_agent} = $mock_agent;
    my $method = $test->{method};

    my $mock_tester = sub {
        my $return_value = shift;

        is_deeply $return_value, $test->{resp},
          "return value of '$method' is as expected";
    };
    note("running tests for $test->{method}");
    $mock_tester->(
        $api->api_public( $method, $test->{request_args} || undef ) );
}

sub lwp_mock {
    my $response      = shift;
    my $mock_response = Test::MockObject->new;

    $mock_response->set_true('is_success');
    $mock_response->set_always( 'decoded_content', encode_json($response) );

    my $mock_agent = Test::MockObject->new;

    $mock_agent->set_always( 'get', $mock_response );
    $mock_agent->set_isa('LWP::UserAgent');

    ( $mock_agent, $mock_response, 'decoded_content', 'is_success' );
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

