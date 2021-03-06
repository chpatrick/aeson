{-# LANGUAGE PackageImports #-}
module Typed.TH (benchmarks, decodeBenchmarks) where

import Prelude ()
import Prelude.Compat

import "aeson" Data.Aeson hiding (Result)
import Criterion
import Data.ByteString.Lazy as L
import Twitter.TH
import Typed.Common
import qualified "aeson-benchmarks" Data.Aeson as B

encodeDirectA :: Result -> L.ByteString
encodeDirectA = encode

encodeViaValueA :: Result -> L.ByteString
encodeViaValueA = encode . toJSON

encodeDirectB :: Result -> L.ByteString
encodeDirectB = B.encode

encodeViaValueB :: Result -> L.ByteString
encodeViaValueB = B.encode . B.toJSON

benchmarks :: Benchmark
benchmarks =
  env ((,) <$> load "json-data/twitter100.json" <*> load "json-data/jp100.json") $ \ ~(twitter100, jp100) ->
  bgroup "encodeTH" [
      bgroup "direct" [
        bench "twitter100"          $ nf encodeDirectB twitter100
      , bench "jp100"               $ nf encodeDirectB jp100
      , bench "twitter100 baseline" $ nf encodeDirectA twitter100
      , bench "jp100 baseline"      $ nf encodeDirectA jp100
      ]
    , bgroup "viaValue" [
        bench "twitter100"          $ nf encodeViaValueA twitter100
      , bench "jp100"               $ nf encodeViaValueA jp100
      , bench "twitter100 baseline" $ nf encodeViaValueB twitter100
      , bench "jp100 baseline"      $ nf encodeViaValueB jp100
      ]
    ]

decodeDirectA :: L.ByteString -> Maybe Result
decodeDirectA = decode

decodeDirectB :: L.ByteString -> Maybe Result
decodeDirectB = B.decode

decodeBenchmarks :: Benchmark
decodeBenchmarks =
  env ((,) <$> L.readFile "json-data/twitter100.json" <*> L.readFile "json-data/jp100.json") $ \ ~(twitter100, jp100) ->
  bgroup "decodeTH"
    [ bgroup "direct"
      [ bench "twitter100"          $ nf decodeDirectB twitter100
      , bench "jp100"               $ nf decodeDirectB jp100
      , bench "twitter100 baseline"  $ nf decodeDirectA twitter100
      , bench "jp100 baseline"      $ nf decodeDirectA jp100
      ]
    ]
