#!/usr/bin/env bash

#Clean output from previous run
rm runtime/batched-tx.sh

#Prepare the required tx from your file data source
cabal run file-tx-batcher -- "resources/datasource.csv"

#Sign and submit the tx
runtime/execute-transaction.sh


