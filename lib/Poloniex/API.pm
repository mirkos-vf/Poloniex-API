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

use constant {
  URL_PUBLIC_API  => "https://poloniex.com/public?command=%s",
  URL_TRADING_API => "https://poloniex.com/tradingApi"
};

# singleton and accessor
{
  eval { require LWP::UserAgent };
  my $lwp = LWP::UserAgent->new();
  sub _lwp_agent { return $lwp }
}

sub new {
  my ( $class, %options ) = @ARG;
  my $object;

  $object->{APIKey}  = $options{APIKey} || undef;
  $object->{Secret}  = $options{Secret} || undef;
  $object->{json}    = JSON::XS->new;

  return bless $object, $class;
}

sub AUTOLOAD {
  my $self = shift;
  our $AUTOLOAD;
  (my $method = $AUTOLOAD) =~ s/.*:://;
  $self->api_request ($method, @ARG);
}

sub api_request {
  my ( $self, $method ) = splice @ARG, 0, 2;

  Carp::croak("new() requires key-value pairs")
    unless @ARG % 2 == 0;

  my (@query, $key, $values);
  while (@ARG) {
    $key    = shift @ARG;
    $values = shift @ARG;
    push @query, "$key=$values";
  }

  my $requst;
  if ( $self->{type_url} eq 'public') {
    $requst = $self->_lwp_agent->get(
      sprintf URL_PUBLIC_API, $method
    );
  }
  elsif ($self->{type_url} eq 'trading') {
    my $nonce = time() =~ s/\.//r;
    my $params = "nonce=$nonce&command=$method";
    if (@query) {
      $params .= '&' . _prepair_params(@query)
    }
    my $req = HTTP::Request->new( 'POST', URL_TRADING_API );

    $req->content_type('application/x-www-form-urlencoded');
    $req->header( Key  => $self->{APIKey} );
    $req->header( Sign => hmac_sha512_hex( $params, $self->{Secret}) );
    $req->content( $params );
    $self->_lwp_agent->agent("Mozilla/5.0 (Windows NT 6.3; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0");
    $requst = $self->_lwp_agent->request($req);
  }
  return $self->_retrieve_json($requst->{_content});
}

sub public  { shift->{type_url} = 'public' }
sub trading { shift->{type_url} = 'trading'}

sub _prepair_params {
  return join ( '&', @ARG );
}

sub _retrieve_json {
  my ( $self, $data ) = @ARG;

  return $self->{json}->utf8(1)->decode($data);
}

sub _croak ($) {
  require Carp;
  Carp::croak(@ARG);
}

1;

__END__

