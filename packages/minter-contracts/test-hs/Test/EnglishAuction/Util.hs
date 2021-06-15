{-# OPTIONS_GHC -Wno-redundant-constraints #-}

module Test.EnglishAuction.Util
  ( originateAuctionFA2Allowlisted
  , originateAuctionFA2AllowlistedToken
  , originateAuctionTezAllowlisted
  , originateAuctionTezAllowlistedToken
  , originateAuctionTezPermitAllowlisted
  , originateAuctionTezPermitAllowlistedToken
  ) where

import Lorentz.Contracts.MinterSdk
import Lorentz.Value
import Morley.Nettest

import Lorentz.Contracts.AllowlistSimple as AllowlistSimple
import Lorentz.Contracts.AllowlistToken as AllowlistToken
import qualified Lorentz.Contracts.EnglishAuction.FA2 as AuctionFA2
import qualified Lorentz.Contracts.EnglishAuction.Tez as AuctionTez
import qualified Lorentz.Contracts.EnglishAuction.TezPermit as AuctionPermitTez
import qualified Lorentz.Contracts.PausableAdminOption as PausableAdminOption

originateAuctionFA2Allowlisted
  :: MonadNettest caps base m
  => AuctionFA2.BidCurrency
  -> Address
  -> m $ ContractHandler
       (AuctionFA2.AuctionEntrypoints AllowlistSimple.Entrypoints)
       (AuctionFA2.AuctionStorage AllowlistSimple.Allowlist)
originateAuctionFA2Allowlisted bidCurrency admin = do
  originateSimple "auction-fa2"
    (AuctionFA2.initAuctionStorage
      (PausableAdminOption.initAdminStorage admin)
      bidCurrency
    )
    =<< importContract (inBinFolder "english_auction_fa2_allowlisted.tz")

originateAuctionFA2AllowlistedToken
  :: MonadNettest caps base m
  => AuctionFA2.BidCurrency
  -> Address
  -> m $ ContractHandler
        (AuctionFA2.AuctionEntrypoints AllowlistToken.Entrypoints)
        (AuctionFA2.AuctionStorage AllowlistToken.Allowlist)
originateAuctionFA2AllowlistedToken bidCurrency admin = do
  originateSimple "auction-fa2"
    (AuctionFA2.initAuctionStorage
      (PausableAdminOption.initAdminStorage admin)
      bidCurrency
    )
    =<< importContract (inBinFolder "english_auction_fa2_allowlisted_token.tz")

originateAuctionTezAllowlisted
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
        (AuctionTez.AuctionEntrypoints AllowlistSimple.Entrypoints)
        (AuctionTez.AuctionStorage AllowlistSimple.Allowlist)
originateAuctionTezAllowlisted admin = do
  originateSimple "auction-tez"
    (AuctionTez.initAuctionStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "english_auction_tez_allowlisted.tz")

originateAuctionTezAllowlistedToken
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
        (AuctionTez.AuctionEntrypoints AllowlistToken.Entrypoints)
        (AuctionTez.AuctionStorage AllowlistToken.Allowlist)
originateAuctionTezAllowlistedToken admin = do
  originateSimple "auction-tez"
    (AuctionTez.initAuctionStorage (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "english_auction_tez_allowlisted_token.tz")

originateAuctionTezPermitAllowlisted
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
        (AuctionPermitTez.PermitAuctionEntrypoints AllowlistSimple.Entrypoints)
        (AuctionPermitTez.PermitAuctionStorage AllowlistSimple.Allowlist)
originateAuctionTezPermitAllowlisted admin = do
  originateSimple "auction-permit-tez"
    (AuctionPermitTez.initPermitAuctionStorage
       (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "english_auction_tez_permit_allowlisted.tz")

originateAuctionTezPermitAllowlistedToken
  :: MonadNettest caps base m
  => Address
  -> m $ ContractHandler
        (AuctionPermitTez.PermitAuctionEntrypoints AllowlistToken.Entrypoints)
        (AuctionPermitTez.PermitAuctionStorage AllowlistToken.Allowlist)
originateAuctionTezPermitAllowlistedToken admin = do
  originateSimple "auction-permit-tez"
    (AuctionPermitTez.initPermitAuctionStorage
      (PausableAdminOption.initAdminStorage admin))
    =<< importContract (inBinFolder "english_auction_tez_permit_allowlisted_token.tz")
