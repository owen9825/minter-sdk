{-# OPTIONS_GHC -Wno-redundant-constraints #-}

module Test.Marketplace.Util
  ( originateMarketplaceAllowlisted
  , originateMarketplaceAllowlistedToken
  , originateMarketplaceTezAllowlisted
  , originateMarketplaceTezAllowlistedToken
  ) where

import Lorentz.Value
import Morley.Nettest

import Lorentz.Contracts.AllowlistSimple as AllowlistSimple
import Lorentz.Contracts.AllowlistToken as AllowlistToken
import Lorentz.Contracts.Marketplace.FA2
import Lorentz.Contracts.Marketplace.Tez
import Lorentz.Contracts.MinterSdk
import qualified Lorentz.Contracts.PausableAdminOption as PausableAdminOption

originateMarketplaceAllowlisted
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
       (MarketplaceEntrypoints AllowlistSimple.Entrypoints)
       (MarketplaceStorage AllowlistSimple.Allowlist)
originateMarketplaceAllowlisted admin = do
  originateSimple "marketplace"
    (initMarketplaceStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "fixed_price_sale_market_allowlisted.tz")

originateMarketplaceAllowlistedToken
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
       (MarketplaceEntrypoints AllowlistToken.Entrypoints)
       (MarketplaceStorage AllowlistToken.Allowlist)
originateMarketplaceAllowlistedToken admin = do
  originateSimple "marketplace"
    (initMarketplaceStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "fixed_price_sale_market_allowlisted_token.tz")

originateMarketplaceTezAllowlisted
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
       (MarketplaceTezEntrypoints AllowlistSimple.Entrypoints)
       (MarketplaceTezStorage AllowlistSimple.Allowlist)
originateMarketplaceTezAllowlisted admin = do
  originateSimple "marketplace-tez"
    (initMarketplaceTezStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "fixed_price_sale_market_tez_allowlisted.tz")

originateMarketplaceTezAllowlistedToken
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
       (MarketplaceTezEntrypoints AllowlistToken.Entrypoints)
       (MarketplaceTezStorage AllowlistToken.Allowlist)
originateMarketplaceTezAllowlistedToken admin = do
  originateSimple "marketplace-tez"
    (initMarketplaceTezStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "fixed_price_sale_market_tez_allowlisted_token.tz")
