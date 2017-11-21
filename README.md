# Poloniex-API

**Poloniex API wrapper for perl**

**API DOCUMENTATION**
https://poloniex.com/support/api/

![perl](https://img.shields.io/cpan/l/Config-Augeas.svg)

## Usage:
```perl
	use Poloniex::API; 
	
	my $api = Poloniex::API->new(
		APIKey => '3318B9SG-8UXSJ3VW-LG25QCU4-FHFDLPNF',
		Secret => '6cea63996301a82821ad5d0b1026a7f5a8fsd76748ab7058005f96f3f8df1fc9074e1ba785c2b6a8ede6ff691a253e64cb55b478c7ba56edd26e74d83005b76c9c'
	);
```

**public api**
```perl
	my $Ticker = $api->api_public('returnTicker');
	
	my $ChartData    = $api->api_public('returnChartData', {
		currencyPair => 'BTC_XMR',
		start        => 1405699200,
		end          => 9999999999,
		period       => 14400
	});
```

**trading api**
```perl
	my $returnCompleteBalances = $api->api_trading('returnCompleteBalances');
	my ($returnTradeHistory, $err) = $api->api_trading('returnTradeHistory', {
		currencyPair => 'BTC_ZEC'
	});
	
	if ($err) {
		say $returnTradeHistory->{error};
	}
```