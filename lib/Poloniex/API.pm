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

  $object->{APIKey}  = $options{APIKey} || undef;
  $object->{Secret}  = $options{Secret} || undef;
  $object->{json}    = JSON::XS->new;

  return bless $object, $class;
}

sub api_trading {
  my ( $self, $method, $req ) = @ARG;
  $$req{nonce} = time() =~ s/\.//r;
  $$req{command} = $method;

  my @post_data;
  for ( keys %{$req}) {
    push @post_data, "$_=$$req{$_}"
  }

  my $param = join('&', @post_data);
  my $sign = hmac_sha512_hex( $param, $self->{Secret});
  my %header = (
    Key  => $self->{APIKey},
    Sign => $sign
  );
  my $http = HTTP::Request->new('POST', URL_TRADING_API);

  $http->content_type('application/x-www-form-urlencoded');
  $http->header(%header);
  $http->content($param);
  my $respons = $self->_lwp_agent->request($http);

  my $json = $self->_retrieve_json($respons->{'_content'});

  return wantarray ? ($json, $self->error($respons->{'_content'})) : $json;
}

sub api_public {
  my ( $self, $method, $req )= @_;

  my @request;
  for my $value ( keys %{$req} ) {
    push @request, "$value=$$req{$value}";
  }

  my $params;
  $params = sprintf "$method&%s", join('&',@request)
    if (@request);

  my $requst = $self->_lwp_agent->get(
    sprintf($self->URL_PUBLIC_API, ($params) ? $params : $method));
  my $json = $self->_retrieve_json($requst->{'_content'});
  return wantarray ? ($json, $self->error($requst->{'_content'})) : $json;
}

sub error {
  my ($self, $requst) = @ARG;

  my $msg = ($requst =~ m{"error":"([^"])*"}igm);
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

