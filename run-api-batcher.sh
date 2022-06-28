#!/usr/bin/env bash

#Clean output from previous run
rm runtime/batched-tx.sh

ep="--"
if [ -z "$1" ]
  then
    echo "No endpoint supplied. Default will be used to fetch data."
  else
    ep= $1
fi

#Run the api based tx batcher with the supplied endpoint (or default)
cabal run api-tx-batcher -- $ep

#Sign and submit the tx
runtime/execute-transaction.sh


