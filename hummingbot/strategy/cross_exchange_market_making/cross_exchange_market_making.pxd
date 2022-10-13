# distutils: language=c++

from libc.stdint cimport int64_t
from hummingbot.core.data_type.limit_order cimport LimitOrder
from hummingbot.core.data_type.order_book cimport OrderBook
from hummingbot.strategy.strategy_base cimport StrategyBase
from .order_id_market_pair_tracker cimport OrderIDMarketPairTracker

cdef class CrossExchangeMarketMakingStrategy(StrategyBase):
    cdef:
        set _maker_markets
        set _taker_markets
        bint _all_markets_ready
        bint _active_order_canceling
        bint _adjust_orders_enabled
        dict _anti_hysteresis_timers
        object _min_profitability
        object _third_market
        object _order_size_taker_volume_factor
        object _balance_fix_maker
        object _order_size_taker_balance_factor
        object _order_size_portfolio_ratio_limit
        object _order_size_maker_balance_factor
        object _triangular_switch
        object _order_amount
        object _target_base_balance
        object _maker_order_update
        object _top_maker_cancel_seconds
        object _top_maker_cancel_timer
        object _slippage_buffer_fix
        object _waiting_time
        object _fix_counter
        bint _keep_target_balance
        bint _filled_order_delay
        object _filled_order_delay_seconds
        object _filled_order_delay_timer
        object _cancel_order_threshold
        object _triangular_arbitrage
        object _top_depth_tolerance
        object _top_depth_tolerance_taker
        double _anti_hysteresis_duration
        double _status_report_interval
        double _last_timestamp
        object _cancel_timer
        double _limit_order_min_expiration
        object _counter
        object _restore_timer
        bint _cancel_order_timer
        object _cancel_order_timer_seconds
        dict _order_fill_buy_events
        dict _order_fill_sell_events
        dict _suggested_price_samples
        dict _market_pairs
        int64_t _logging_options
        OrderIDMarketPairTracker _market_pair_tracker
        bint _use_oracle_conversion_rate
        object _taker_to_maker_base_conversion_rate
        object _taker_to_maker_quote_conversion_rate
        object _slippage_buffer
        object _min_order_amount
        bint _hb_app_notification
        list _maker_order_ids
        double _last_conv_rates_logged
        object _taker_perpetual
        object _maker_perpetual
        object _use_min_profit_for_taker_price

    cdef c_process_market_pair(self,
                               object market_pair,
                               list active_ddex_orders)
    cdef c_check_and_hedge_orders(self,
                                  object market_pair)
    cdef object c_get_order_size_after_portfolio_ratio_limit(self,
                                                             object market_pair)
    cdef object c_get_adjusted_limit_order_size(self,
                                                object market_pair)
    cdef object c_get_market_making_size(self,
                                         object market_pair,
                                         bint is_bid)
    cdef object c_get_market_making_price(self,
                                          object market_pair,
                                          bint is_bid,
                                          object size)
    cdef object c_calculate_effective_hedging_price(self,
                                                    object market_pair,
                                                    bint is_bid,
                                                    object size)
    cdef bint c_check_if_still_profitable(self,
                                          object market_pair,
                                          LimitOrder active_order,
                                          object current_hedging_price)
    cdef bint c_check_if_sufficient_balance(self,
                                            object market_pair,
                                            LimitOrder active_order)

    cdef bint c_check_if_price_has_drifted(self,
                                           object market_pair,
                                           LimitOrder active_order)

    cdef tuple c_get_top_bid_ask(self,
                                 object market_pair)
    cdef tuple c_get_top_bid_ask_from_price_samples(self,
                                                    object market_pair)
    cdef tuple c_get_suggested_price_samples(self,
                                             object market_pair)
    cdef c_take_suggested_price_sample(self,
                                       object market_pair)

    cdef c_balance_fix_fix(self, market_pair)

    cdef c_check_and_create_new_orders(self,
                                       object market_pair,
                                       bint has_active_bid,
                                       bint has_active_ask)

    cdef c_cancel_all_maker_limit_orders(self, market_pair)

    cdef c_place_top_maker(self, market_pair)

    cdef c_cancel_all_taker_limit_orders(self, market_pair)


    cdef c_balance_fix_check(self, market_pair)

    cdef c_check_available_balance(self, is_buy: bool, market_pair)

    cdef c_place_fixing_order(self, is_maker: bool, is_buy: bool, market_pair)

    cdef str c_place_order(self,
                           object market_pair,
                           bint is_buy,
                           market,
                           bint record_maker,
                           object amount,
                           object price)
