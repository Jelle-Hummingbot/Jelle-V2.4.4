# distutils: language=c++
# distutils: sources=hummingbot/core/cpp/OrderBookEntry.cpp

import warnings
from decimal import Decimal
from typing import Tuple
import logging
import pandas as pd
import os

import numpy as np
from scipy.optimize import curve_fit
from scipy.optimize import OptimizeWarning

from hummingbot.core.data_type.common import (
    PriceType,
)
from hummingbot.core.data_type.order_book import OrderBook
from hummingbot.core.event.event_listener cimport EventListener
from hummingbot.core.event.events import OrderBookEvent
from hummingbot.strategy.asset_price_delegate import AssetPriceDelegate

cdef class TradesForwarder(EventListener):
    def __init__(self, indicator: 'TradingIntensityIndicator'):
        self._indicator = indicator

    cdef c_call(self, object arg):
        self._indicator.c_register_trade(arg)

pmm_logger = None

cdef class TradingIntensityIndicator:

    def __init__(self, order_book: OrderBook, price_delegate: AssetPriceDelegate, sampling_length: int = 30):
        self._trade_samples = {}
        self._current_trade_sample = []
        self._trades_forwarder = TradesForwarder(self)
        self._order_book = order_book
        self._order_book.c_add_listener(OrderBookEvent.TradeEvent.value, self._trades_forwarder)
        self._price_delegate = price_delegate


        self._last_quotes = []

        self._current_timestamp = 0

        warnings.simplefilter("ignore", OptimizeWarning)



    cdef c_calculate(self, timestamp):
        self._current_timestamp = timestamp
        #current mid_price
        price = self._price_delegate.get_price_by_type(PriceType.MidPrice)
        # Descending order of price-timestamp quotes of the incomming trades
        self._last_quotes = [{'timestamp': timestamp, 'price': price}] + self._last_quotes

        latest_processed_quote_idx = None
        for trade in self._current_trade_sample: #for each trade in the unprocessed trade sample list
            for i, quote in enumerate(self._last_quotes):
                if quote["timestamp"] < trade.timestamp: # only do this for trades that happened after the last mid_price recording
                    if latest_processed_quote_idx is None or i < latest_processed_quote_idx: #to keep track if all trades hae been processed
                        latest_processed_quote_idx = i
                    #here is where we can store the data
                    trade_price = trade.price
                    side = trade.type
                    amount = trade.amount
                    price_level = abs(trade.price - float(quote["price"]))


                    trade = {"price_level": abs(trade.price - float(quote["price"])), "amount": trade.amount} #absolute difference between the mid_price and the trade amount

                    if quote["timestamp"] + 1 not in self._trade_samples.keys(): #if timestamp +1 not in the trades yet, add the current trade data
                        self._trade_samples[quote["timestamp"] + 1] = []

                    self._trade_samples[quote["timestamp"] + 1] += [trade]

                    timestamp = quote["timestamp"]
                    timestamp_plus = quote["timestamp"] + 1
                    mid_price = quote["price"]


                    if os.path.exists('/Users/jellebuth/Documents/tradeinfo_hotcross.csv'):
                      pass
                    else:
                        df_header = pd.DataFrame([('timestamp',
                                                    'trade_price',
                                                    'side',
                                                    'mid_price',
                                                    'price_level',
                                                    'amount')])
                        df_header.to_csv('/Users/jellebuth/Documents/tradeinfo_hotcross.csv', mode='a', header=False, index=False)

                    df = pd.DataFrame([(timestamp,
                                        trade_price,
                                        side,
                                        mid_price,
                                        price_level,
                                        amount)])

                    df.to_csv('/Users/jellebuth/Documents/tradeinfo_hotcross.csv', mode='a', header=False, index=False)

        # THere are no trades left to process
        self._current_trade_sample = []
        # Store quotes that happened after the latest trade + one before

    def register_trade(self, trade):
        """A helper method to be used in unit tests"""
        self.c_register_trade(trade)


    cdef c_register_trade(self, object trade):
        self._current_trade_sample.append(trade)
