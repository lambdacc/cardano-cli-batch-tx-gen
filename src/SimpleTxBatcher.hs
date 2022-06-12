{-# LANGUAGE OverloadedStrings #-}

module SimpleTxBatcher
  (main, createBatchedScript) where

import Data.List.Split (splitOn)
import Data.Maybe
import Data.Hex(hex)
import qualified Data.Map.Strict as SMap
import Data.Time
import Prelude
import Text.Printf (printf)
import TransactionProperties
import Types
import System.Environment
import System.Exit
import System.IO

main :: IO ()
main = do
        args <- getArgs
        case args of
          [(x:xs)] -> do
                  createBatchedScript (x:xs)
                  exitFailure
          _ -> do
                  putStrLn "Not input args provided"
                  exitFailure

createBatchedScript :: String -> IO ()
createBatchedScript inFilePath = do
  case inFilePath of
    [] -> do
            putStrLn "No input file provided"
            exitFailure
    _ -> do
            records <- tail <$> parseFile inFilePath
            if (length records > batchLimit)
              then do
                putStrLn $ printf "More than %s records in csv" (show batchLimit)
                exitFailure
              else do
                let combinedTxOutSegments = buildTxOutSegmentFromRecords records
                let changeTxOutSegment = foldr (++) [] $ buildBalanceTokenSegmentFromRecords records
                writeToOutFiles txInCsv (combinedTxOutSegments ++ changeTxOutSegment)

parseFile :: String -> IO [String]
parseFile f =
  do
    fileContent <- readFile f
    return $ lines fileContent

beforeTxInSegment :: String
beforeTxInSegment = "cardano-cli transaction build \\\n--alonzo-era \\\n" ++ networkPart ++ " \\\n"

txInSegment :: String -> String
txInSegment txIn = "--tx-in " ++ txIn ++ " \\\n" --txHash0#$txIx0

txOutSegment :: String -> String
txOutSegment rec =
  "--tx-out " ++ (cols!!1) ++ "+" ++ (show minUtxoLovelace) ++ "+" ++ "\"" ++(cols!!4) ++ " " ++ cols!!2 ++ "." ++ hex (cols!!3) ++ "\"" ++ " \\\n"
 where
   cols = split rec

changeTxOutSegment :: AssetTotal -> Int -> String
changeTxOutSegment at used =
  "--tx-out " ++ storageAddress ++ "+" ++ (show minUtxoLovelace) ++ "+" ++ "\"" ++ (show $ (total at) - used) ++ " " ++ (policyId $ assetClass at) ++ "." ++ hex (assetName $ assetClass at) ++ "\"" ++ " \\\n"

split :: String -> [String]
split rec = splitOn "," rec

carryAllChangeTxOutSegment :: String
carryAllChangeTxOutSegment = "--change-address "++ storageAddress ++ " \\\n--out-file cli-batch-tx.raw"

buildTxInSegments :: String
buildTxInSegments = foldl (++) [] $ map txInSegment $ split txInCsv

buildTxOutSegmentFromRecords :: [String] -> String
buildTxOutSegmentFromRecords recs = foldl (++) [] $ map txOutSegment recs

buildBalanceTokenSegmentFromRecords :: [String] -> [String]
buildBalanceTokenSegmentFromRecords recs = do
  let assetList = map (\r -> (AssetClass (r!!2) (r!!3), (read (r!!4) :: Int))) $ map split recs
      combinedList = SMap.toList $ SMap.fromListWith (+) assetList
      totalMap = SMap.fromList $ map (\e -> (AssetClass (e!!0) (e!!1), read (e!!2)::Int)) $ map split assetInfo
      in
        map (\e -> changeTxOutSegment
                     (AssetTotal { assetClass = fst e
                                 , total = fromJust $ SMap.lookup (fst e) totalMap
                                 }
                     )
                     (snd e)
            ) combinedList

writeToOutFiles :: String -> String -> IO ()
writeToOutFiles txIn [] = return ()
writeToOutFiles txIn x =
  do
   timeStr <- fmap show getCurrentTime
   outh <- openFile ("runtime/" ++ targetFileName) WriteMode
   hPutStrLn outh "#!/usr/bin/env bash\n"
   hPutStrLn outh $ buildRawTxCommand txIn x
   hPutStrLn outh "\n"

   hPutStrLn outh $ buildSignTxCommand
   hClose outh


buildRawTxCommand :: String -> String -> String
buildRawTxCommand txIn longTxOut = beforeTxInSegment
                                   ++ buildTxInSegments
                                   ++ longTxOut
                                   ++ carryAllChangeTxOutSegment

buildSignTxCommand :: String
buildSignTxCommand = "cardano-cli transaction sign  \\\n --signing-key-file signing-key.skey  \\\n"  ++ networkPart ++ " \\\n --tx-body-file cli-batch-tx.raw  \\\n --out-file cli-batch-tx.signed"

networkPart :: String
networkPart = case cardanoNetwork of
                "mainnet" -> "--mainnet"
                "testnet" -> "--testnet-magic $TESTNET_MAGIC"
