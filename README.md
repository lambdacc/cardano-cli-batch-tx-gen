# cardano-cli-batch-tx-gen
### Batch tx generator for cardano-cli

Batching transactions is a pertinent use case as it has a direct impact on transaction fees that are paid. Teams devise their own approaches to batch transactions when using the cardano-cli. This is an source repository that can be used by teams for batching transactions easily by just configuration of properties.

### How it works:
The transaction generator (haskell component) will receive data from the data source integration service about receiving addresses as well as the native assets and their amounts that need to be transferred.
The generator will read the configuration properties and generate commands that create a batched transaction, signs and submits it to the Cardano blockchain.  The configuration among other parameters will include the signing keys for the address/wallet being used with the CLI. 
Simple shell scripts are used to orchestrate the various steps that need to occur sequentially.

![Batched-tx-generator-c8d883](https://user-images.githubusercontent.com/5955141/174313084-356d6907-24cb-44f7-a7fb-ef3133dff61b.jpg)


**An example:**

Here is a batched transaction created with this tool in testnet to observe the reduction in transaction fee. To test tx sends 2 native tokens to 30 different receive addresses in one transaction. The total transaction fees turned out to be just ~ 0.29 ADA whereas if the transactions were not batched, the total cost would have been 30 x ~0.17 = ~ 5.1 ADA. 

Tx on cardanoscan: https://testnet.cardanoscan.io/transaction/2ce2a8933d8384d6716e2ac964e8074deeb65c2161b988acad44ba8e1b0ffb42

A reduction in fees is roughly by 17 times.

### Benefits

Teams do not have to invest time and effort in developing batching mechanisms when using cardano-cli.
Reduction in cost when transferring native assets to multiple addresses. 
Configurability of data source will allow this code base to cater to various project teams and scenarios.
Automated approach to building batched transactions. It is possible to manually create batched transactions using the cardano-cli’s transaction build command. But the manual approach is not scalable and this provides a programmable way for creating batched txs.
Demonstration of this solution will highlight the advantage that Cardano EUTXO model has over other blockchains in terms of fees. Cardano's low tx fees is widely quoted. This solution of batching will allow development teams to readily harness it.

### Use cases:
**NFT drops** : NFT drops require native assets to be sent to multiple addresses as part of the drop. 
**Token sales and faucets** : Sale of tokens or a faucets depending on cardano-cli can make use of this tool.

### Environment required
- GHC
- cabal
- If `http-conduit` is not resolved then add it via 
`cabal new-install --lib http-conduit`

## How to run


#### 1. Start your cardano-node

#### 2. Set properties

You need to set the following values in `/src/Properties.hs`

- `cardanoNetwork` : testnet or mainnet
- `storageAddress` : This is the address where your tokens to be sent are stored
- `txInList`: The tx in should contain tx-ins of all native tokens at the storage address and tx-in for sufficient ADA
- `assetInfo` : This is the comma separated list of policy id, asset name and total quantity at the storage address. 

Place the signing key for the address holding your tokens under `/resources` directory


#### 3. Build the executables
```
cabal build file-tx-batcher api-tx-batcher
```

#### 4. Run the executable (using file or api based datasource):

This tool expects a tabular data with columns `slno,address,assetId,assetName,amount` to create batched transactions.


 **a. File based batcher:**

Prepares and submits batch tx from tabular data in a csv
You should place the list of addresses and tokens in a csv file under resources directory by the name `datasource.csv`.
Take a look at the sample file `datasource-sample.csv` to see the format of the file.

To run, execute
```
run-file-batcher.sh
```


 **b. API based batcher:**

The idea is to abstract data fetch logic with a REST API interface. This allows to integrate the Haskell component further downstream datasources connected by the REST interface. The tool accepts any fully qualified endpoint for sourcing data. 

The rest interface creates an intermediary csv file of the required format and provides the file path back to the haskell component. It then processes that file for generating batched tx. 

To run, execute
```
run-api-batcher.sh {endpoint}
```

For demo purpose a REST server has been provided at this repo:
`https://github.com/lambdacc/cli-batch-gen-rest-interface`

This gives a REST API running on a spring boot server. This server has a set of data stored in an in memory database. The API provides a paginated response of records that need to be batched. Pagination allows for choosing the batch size that the end user wants to batch in one transaction. This batch size is limited primarily by max block size set by the Cardano network and also the transaction size depending on the length of asset names. The endpoint exposed is 
`http://127.0.0.1:8066/api/cli-batch-tx/get-data-file?pageNo=0&pageSize=100`
This is also the default endpoint set for the API based batcher, in case you do not specify the endpoint.

### Support
Feel free to provide feedback or raise bugs by creating issues on this repo. 
