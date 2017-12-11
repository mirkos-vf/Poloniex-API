use utf8;

package Poloniex::API;

use Time::HiRes qw(time);
use English qw( -no_match_vars );
use strict;
use warnings;
use Digest::SHA qw(hmac_sha512_hex);
use HTTP::Request;

use constant {
    URL_PUBLIC_API     => "https://poloniex.com/public?command=%s",
    URL_TRADING_API    => "https://poloniex.com/tradingApi",
    DEBUG_API_POLONIEX => $ENV{DEBUG_API_POLONIEX} || 0,
};

BEGIN {
    eval { require LWP::UserAgent, 1; }
      || _croak('LWP::UserAgent package not found');

    eval { require JSON::XS, 1; }
      || _croak('JSON::XS package not found');
}
our $VERSION = '0.001';

# singleton and accessor
{
    my $lwp = LWP::UserAgent->new();
    sub _lwp_agent { return $lwp }

    my $json = JSON::XS->new();
    sub _json { return $json }
}

sub new {
    my ( $class, %options ) = @ARG;
    my $object;

    $object->{APIKey} = $options{APIKey} || undef;
    $object->{Secret} = $options{Secret} || undef;
    $object->{_json}  = _json;
    $object->{_agent} = _lwp_agent;

    return bless $object, $class;
}

sub api_trading {
    my ( $self, $method, $req ) = @ARG;
    $$req{nonce}   = time() =~ s/\.//r;
    $$req{command} = $method;

    my @post_data;
    for ( keys %{$req} ) {
        push @post_data, "$_=$$req{$_}";
    }

    my $param = join( '&', @post_data );
    my $sign = hmac_sha512_hex( $param, $self->{Secret} );
    my %header = (
        Key  => $self->{APIKey},
        Sign => $sign
    );
    my $http = HTTP::Request->new( 'POST', $self->URL_TRADING_API );

    $http->content_type('application/x-www-form-urlencoded');
    $http->header(%header);
    $http->content($param);
    my $respons = $self->{_agent}->request($http);

    my $json = $self->_retrieve_json( $respons->{'_content'} );
    return $json;
}

sub api_public {
    my ( $self, $method, $req ) = @ARG;

    my @request;
    for my $value ( keys %{$req} ) {
        push @request, "$value=$$req{$value}";
    }

    my ( $params, $json );
    $params = sprintf "$method&%s", join( '&', @request )
      if (@request);

    my $requst = $self->{_agent}
      ->post( sprintf( URL_PUBLIC_API, ($params) ? $params : $method ) );

    if (   ( $requst->is_success )
        && ( !$self->parse_error( $requst->decoded_content ) ) )
    {
        return $json = $self->_retrieve_json( $requst->decoded_content );
    }
}

sub parse_error {
    my ( $self, $msg ) = @ARG;
    my $error = { type => 'unknown', $msg => $msg || $EVAL_ERROR };

    return
      unless $error->{msg} =~ m/"error":"(?<MSG_ERROR>[^"]*)"/;

    $self->{msg}  = $LAST_PAREN_MATCH{MSG_ERROR};
    $self->{type} = 'api';
}

sub _retrieve_json {
    my ( $self, $data ) = @ARG;

    return $self->{_json}->utf8(1)->decode($data);
}

sub _croak {
    require Carp;
    Carp::croak(@ARG);
}

1;

__END__

=head1 NAME

    Poloniex::API - Poloniex API wrapper.

=head1 SYNOPSIS

	use Poloniex::API; 
	
	my $api = Poloniex::API->new(
		APIKey => 'your-api-key',
		Secret => 'your-secret-key'
	);

=head1 DESCRIPTION

    API DOCUMENTATION https://poloniex.com/support/api/

=head1 CONSTRUCTORS

=head2 new

    my $iterator = Poloniex::API->new(%hash);

Creates a new L<Poloniex::API> instance.

=head1 METHODS

=over

=back

=head2 api_trading

    my $returnCompleteBalances = $api->api_trading('returnCompleteBalances');
    $api->api_trading('returnTradeHistory', {
        currencyPair => 'BTC_ZEC'
    });

This method performs a query on a private API. The request uses the api key and the secret key
(L<here's a list|https://poloniex.com/support/api/>).

=head2 api_public

	my $Ticker = $api->api_public('returnTicker');
	
	my $ChartData    = $api->api_public('returnChartData', {
		currencyPair => 'BTC_XMR',
		start        => 1405699200,
		end          => 9999999999,
		period       => 14400
	});

This method performs an API request. The first argument must be the method name
(L<here's a list|https://poloniex.com/support/api/>).

=head2 parse_error

    $result = $api->api_public('fake', { map { $_ => $_ } 'a'..'d' })

    if (!$result) {
        say sprintf('%s: %s', $api->{type}, $api->{msg});
    }

=head1 AUTHOR

vlad mirkos, E<lt>vladmirkos@sd.apple.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by vlad mirkos
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=encoding UTF-8

=cut
