# Suppress R CMD check NOTEs for bare column names used in dplyr/tidyr verbs
utils::globalVariables(c(
  # get_currency_map / get_exchange_map
  "first_historical_data",
  "last_historical_data",
  # get_global_metrics
  "timestamp",
  "btc_dominance",
  "eth_dominance",
  "active_cryptocurrencies",
  "active_exchanges",
  "active_market_pairs",
  "quote.USD.total_market_cap",
  "quote.USD.total_volume_24h",
  "quote.USD.total_volume_24h_reported",
  "quote.USD.altcoin_market_cap",
  "quote.USD.altcoin_volume_24h",
  "quote.USD.altcoin_volume_24h_reported",
  # get_key_metrics
  "credit_limit_monthly",
  "rate_limit_minute",
  "minute",
  # get_token_quote
  "quote.USD.price",
  "quote.USD.volume_24h",
  "quote.USD.market_cap",
  "quote.USD.circulating_supply",
  "quote.USD.total_supply",
  # get_ohlcv / get_dex_ohlcv
  "time_open"
))
