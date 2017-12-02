use utf8;

package Poloniex::API;

use Time::HiRes qw(time);
use English;
use strict;
use warnings;
use Digest::SHA qw(hmac_sha512_hex);
use LWP::UserAgent;
use HTTP::Request;
use JSON::XS;

use constant URL_PUBLIC_API  => "https://poloniex.com/public?command=%s";
use constant URL_TRADING_API => "https://poloniex.com/tradingApi";

# singleton and accessor
{
    eval { require LWP::UserAgent };
    my $lwp = LWP::UserAgent->new();
    sub _lwp_agent { return $lwp }
}

sub new {
    my ( $class, %options ) = @ARG;
    my $object;

    $object->{APIKey} = $options{APIKey} || undef;
    $object->{Secret} = $options{Secret} || undef;
    $object->{json}   = JSON::XS->new;

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
    my $http = HTTP::Request->new( 'POST', URL_TRADING_API );

    $http->content_type('application/x-www-form-urlencoded');
    $http->header(%header);
    $http->content($param);
    my $respons = $self->_lwp_agent->request($http);

    my $json = $self->_retrieve_json( $respons->{'_content'} );

    return
      wantarray ? ( $json, $self->error( $respons->{'_content'} ) ) : $json;
}

sub api_public {
    my ( $self, $method, $req ) = @_;

    my @request;
    for my $value ( keys %{$req} ) {
        push @request, "$value=$$req{$value}";
    }

    my $params;
    $params = sprintf "$method&%s", join( '&', @request )
      if (@request);

    my $requst = $self->_lwp_agent->get(
        sprintf( $self->URL_PUBLIC_API, ($params) ? $params : $method ) );
    my $json = $self->_retrieve_json( $requst->{'_content'} );
    return wantarray ? ( $json, $self->error( $requst->{'_content'} ) ) : $json;
}

sub error {
    my ( $self, $requst ) = @ARG;

    my $msg = ( $requst =~ m{"error":"([^"])*"}igm );
    return unless defined $msg;
    return $msg;
}

sub _retrieve_json {
    my ( $self, $data ) = @ARG;

    return $self->{json}->utf8(1)->decode($data);
}

sub _croak {
    require Carp;
    Carp::croak(@ARG);
}

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

    Poloniex::API - Poloniex API wrapper.

=head1 SYNOPSIS

	use Poloniex::API; 
	
	my $api = Poloniex::API->new(
		APIKey => 'your-api-key',
		Secret => 'your-secret-key'
	);

=head1 DESCRIPTION

=head1 CONSTRUCTORS

=head2 new

    my $iterator = Poloniex::API->new(%hash);
    Return a Poloniex::API for C<hash>

=head1 METHODS

=over

=back

=head2 api_trading

    my $returnCompleteBalances = $api->api_trading('returnCompleteBalances');
	my ($returnTradeHistory, $err) = $api->api_trading('returnTradeHistory', {
		currencyPair => 'BTC_ZEC'
	});
	
	if ($err) {
		say $returnTradeHistory->{error};
	}
TODO: this description function

=head2 api_public

	my $Ticker = $api->api_public('returnTicker');
	
	my $ChartData    = $api->api_public('returnChartData', {
		currencyPair => 'BTC_XMR',
		start        => 1405699200,
		end          => 9999999999,
		period       => 14400
	});
TODO: this description function

=head1 AUTHOR

vlad mirkos, E<lt>vladmirkos@sd.apple.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by vlad mirkos
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=encoding UTF-8

=cut
