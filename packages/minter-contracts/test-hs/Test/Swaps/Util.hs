{-# OPTIONS_GHC -Wno-redundant-constraints #-}

module Test.Swaps.Util
  ( originateFA2
  , originateWithAdmin
  , originateSwap
  , originateAllowlistedSwap
  , originateAllowlistedSwapWithAdmin
  , mkFA2Assets
  ) where

import qualified Lorentz.Contracts.Spec.FA2Interface as FA2
import Lorentz.Value
import Morley.Nettest

import Lorentz.Contracts.MinterSdk
import Lorentz.Contracts.Swaps.Allowlisted
import Lorentz.Contracts.Swaps.Basic
import Test.Util

-- | Originate the swaps contract.
originateSwap
  :: MonadNettest caps base m
  => m (ContractHandler SwapEntrypoints SwapStorage)
originateSwap =
  originateSimple "swaps" initSwapStorage
    =<< importContract (inBinFolder "fa2_swap.tz")

-- | Originate the allowlisted swaps contract.
originateAllowlistedSwap
  :: MonadNettest caps base m
  => Address
  -> m (ContractHandler AllowlistedSwapEntrypoints AllowlistedSwapStorage)
originateAllowlistedSwap admin =
  originateSimple "swaps"
    (initAllowlistedSwapStorage admin)
    =<< importContract (inBinFolder "fa2_allowlisted_swap.tz")

-- | Originate the allowlisted swaps contract and admin for it.
originateAllowlistedSwapWithAdmin
  :: MonadNettest caps base m
  => m (ContractHandler AllowlistedSwapEntrypoints AllowlistedSwapStorage, Address)
originateAllowlistedSwapWithAdmin =
  originateWithAdmin originateAllowlistedSwap

-- | Construct 'FA2Assets' from a simplified representation.
mkFA2Assets :: ContractHandler fa2Param fa2Storage -> [(FA2.TokenId, Natural)] -> FA2Assets
mkFA2Assets addr tokens =
  FA2Assets (toAddress addr) (uncurry FA2Token <$> tokens)
