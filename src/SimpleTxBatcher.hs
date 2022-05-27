{-# LANGUAGE OverloadedStrings #-}

module SimpleTxBatcher
  (main, createSimpleBatchedScript) where

import System.IO
import System.Exit
import System.Environment
import Prelude
import Data.List.Split (splitOn)
import TransactionProperties
import Data.Time

main :: IO ()
main = do
        args <- getArgs
        case args of
          [] -> do
                  putStrLn "No input file provided"
                  exitFailure
          _ -> do
                  createSimpleBatchedScript $ head args

createSimpleBatchedScript :: String -> IO ()
createSimpleBatchedScript inFile = do
  case inFile of
    [] -> do
            putStrLn "No input file provided"
            exitFailure
    _ -> do
            records <- parseFile inFile
            if (length records > 50)
              then do
                putStrLn "More than 50 records in csv"
                exitFailure
              else do
                let combinedTxOutSegments = buildTxOutSegmentFromRecords records
                writeToOutFiles txInCsv combinedTxOutSegments

parseFile :: String -> IO [String]
parseFile f =
  do
    fileContent <- readFile f
    return $ lines fileContent

beforeTxInSegment :: String
beforeTxInSegment = "cardano-cli transaction build \\\n--alonzo-era \\\n--testnet-magic $TESTNET_MAGIC \\\n"

txInSegment :: String -> String
txInSegment txIn = "--tx-in " ++ txIn ++ " \\\n" --txHash0#$txIx0

txOutSegment :: String -> String
txOutSegment rec =
 "--tx-out " ++ (fst addrAmtPair) ++ "+" ++ (show minAssetLovelace) ++ "+" ++ "\"" ++(snd addrAmtPair) ++ " " ++ tokenPolicyId ++ "." ++ tokenName ++ "\"" ++ " \\\n"
 where
   addrAmtPair = tuplifyLastFrom3 $ splitOn "," rec

balancingTxOutSegment :: String -> String
balancingTxOutSegment rec =
 "--tx-out " ++ (fst addrAmtPair) ++ "+" ++ (show minAssetLovelace) ++ "+" ++ "\"" ++(snd addrAmtPair) ++ " " ++ tokenPolicyId ++ "." ++ tokenName ++ "\"" ++ " \\\n"
 where
   addrAmtPair = tuplifyLastFrom3 $ splitOn "," rec

tuplifyLastFrom3 :: [String] -> (String,String)
tuplifyLastFrom3 [x,y,z] = (y,z)

afterTxOutSegment :: String
afterTxOutSegment = "--change-address "++ storageAddress ++ " \\\n--out-file submit-transfer-tx.raw"

buildTxOutSegmentFromRecords :: [String] -> String
buildTxOutSegmentFromRecords l = foldl (++) [] $ map txOutSegment l

buildBalancingTxOutChangeSegmentFromRecords :: [String] -> String
buildBalancingTxOutChangeSegmentFromRecords l = foldl (++) [] $ map txOutSegment l

writeToOutFiles :: String -> String -> IO ()
writeToOutFiles txIn [] = return ()
writeToOutFiles txIn x =
  do
   timeStr <- fmap show getCurrentTime
   outh <- openFile ("create-and-sign-cli-tx-" ++ (timeStr) ++ ".txt") WriteMode
   hPutStrLn outh $ buildRawTxCommand txIn x
   hPutStrLn outh "\n\n"

   hPutStrLn outh $ buildSignTxCommand
   hClose outh


buildRawTxCommand :: String -> String -> String
buildRawTxCommand txIn longTxOut = beforeTxInSegment ++ (txInSegment txIn) ++ longTxOut ++ afterTxOutSegment

buildSignTxCommand :: String
buildSignTxCommand = "cardano-cli transaction sign  \\\n --signing-key-file sw-signing-key.skey  \\\n --testnet-magic $TESTNET_MAGIC \\\n --tx-body-file submit-transfer-tx.raw  \\\n --out-file submit-transfer-tx.signed"


