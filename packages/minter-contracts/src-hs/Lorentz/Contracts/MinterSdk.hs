-- | Commons for this repository.
module Lorentz.Contracts.MinterSdk
  ( -- * Types
    FeeData(..)

    -- * Helpers
  , inBinFolder

  ) where

import Fmt (Buildable(..), genericF)
import GHC.IO.Unsafe (unsafePerformIO)
import Lorentz
import System.Environment (lookupEnv)
import System.FilePath ((</>))

----------------------------------------------------------------------------
-- Types
----------------------------------------------------------------------------

data FeeData = FeeData
  { feeAddress :: Address
  , feePercent :: Natural
  }

customGeneric "FeeData" ligoCombLayout
deriving anyclass instance IsoValue FeeData
deriving anyclass instance HasAnnotation FeeData
instance Buildable FeeData where build = genericF

----------------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------------

binFolder :: FilePath
binFolder = unsafePerformIO do
  mpath <- lookupEnv "TZ_BIN_PATH"
  return (mpath ?: "bin")
{-# NOINLINE binFolder #-}

inBinFolder :: FilePath -> FilePath
inBinFolder file = binFolder </> file
