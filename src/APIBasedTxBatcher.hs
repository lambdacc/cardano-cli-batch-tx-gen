{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module APIBasedTxBatcher
  (main) where

import Data.Aeson
import Control.Exception          (throwIO)
import qualified Data.ByteString.Lazy as B
import FileBasedTxBatcher (createBatchedScript)
import GHC.Generics (Generic)
import Network.HTTP.Conduit (simpleHttp)
import System.Environment         (getArgs)
import Text.Printf                (printf)

data ApiResponse =
  ApiResponse { filePath :: String
               } deriving (Show, Generic)

instance FromJSON ApiResponse
instance ToJSON ApiResponse


defaultURL :: String
defaultURL = "http://127.0.0.1:8066/api/cli-batch-tx/get-data-file?pageNo=0&pageSize=100"

getJSON :: String -> IO B.ByteString
getJSON url = simpleHttp url

setUrl :: String -> String
setUrl "--" = defaultURL
setUrl (x:xs) = (x:xs)
setUrl _ = defaultURL

main :: IO ()
main = do
    [fqEndpoint] <- getArgs
    printf "Input arg: %s\n" (show fqEndpoint)

    let ep = setUrl fqEndpoint
    printf "Running api based tx batcher with params \n%s\n"
     (show ep)
    fetchAndProcessData ep
    return ()

fetchAndProcessData :: String -> IO ()
fetchAndProcessData ep = do
  printf "Invoking API\n"
  d <- (eitherDecode <$> (getJSON ep)) :: IO (Either String ApiResponse)
  case d of
    Left e   -> printf "Unexpected response from REST call:: %s" (show e)
    Right o -> do
      printf "API response %s\n" $ show o
      createBatchedScript (filePath o)
