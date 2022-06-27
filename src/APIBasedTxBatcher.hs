{-# LANGUAGE OverloadedStrings  #-}

module Main
    ( main
    ) where

import Control.Exception          (throwIO)
import Network.HTTP.Req
import System.Environment         (getArgs)
import Text.Printf                (printf)

main :: IO String
main = do
    [fqEndpoint, startIndex, stopIndex] <- getArgs
    printf "Running api based tx batcher with params %s\n %s\n %s\n" $ (show fqEndpoint) (show startIndex) (show stopIndex)
    resp <- fetchData ep start stop
    printf "API response %s\n" $ show resp
    return resp

fetchData :: String -> String -> String -> IO String
fetchData ep start stop = do
    v <- runReq defaultHttpConfig $ req
        GET
        (http "127.0.0.1" /: "api"  /: "cli-batch-tx" /: "get-data")
        NoReqBody
        jsonResponse
        (port 8066)
    let c = responseStatusCode v
    if c == 200
        then return $ responseBody v
        else throwIO $ userError $ printf "ERROR: %d\n" c
