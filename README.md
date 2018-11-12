# Poloniex-API

**Poloniex API wrapper for perl**

**API DOCUMENTATION**
https://poloniex.com/support/api/

![perl](https://img.shields.io/cpan/l/Config-Augeas.svg)


## SYNOPSIS

```perl
use Poloniex::API; 

my $api = Poloniex::API->new(
	APIKey => 'your-api-key',
	Secret => 'your-secret-key'
);
```

### new

```perl
my $iterator = Poloniex::API->new(%hash);
```

Creates a new <Poloniex::API> instance.

### api_trading

```perl
my $returnCompleteBalances = $api->api_trading('returnCompleteBalances');
$api->api_trading('returnTradeHistory', {
    currencyPair => 'BTC_ZEC'
});
```

This method performs a query on a private API. The request uses the api key and the secret key
[here's a list](https://poloniex.com/support/api/)

### api_public

```perl
my $Ticker = $api->api_public('returnTicker');

my $ChartData    = $api->api_public('returnChartData', {
    currencyPair => 'BTC_XMR',
    start        => 1405699200,
    end          => 9999999999,
    period       => 14400
});
```

This method performs an API request. The first argument must be the method name
[here's a list](https://poloniex.com/support/api/)

### parse_error

```perl
handle_api_error($api, $api->api_public('fake'))

sub handle_api_error {
    my ( $api, $retval ) = @_;
    unless ( $retval ) {
        die sprintf("Error: %s; type: %s", $api->{msg}, $mapi->{type});
    }
}
```

**AUTHOR**

    vlad mirkos, vladmirkos@sd.apple.com

**COPYRIGHT AND LICENSE**

    Copyright (C) 2017 by vlad mirkos
    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself, either Perl version 5.18.2 or,
    at your option, any later version of Perl 5 you may have available.
