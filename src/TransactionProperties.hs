module TransactionProperties where

cardanoNetwork = "testnet"
minUtxoLovelace = 1700000
batchLimit = 100 :: Int
targetFileName = "batched-tx.sh"

{-This is the address where your tokens to be sent are stored-}
storageAddress = "addr_test1vrw8rs5ax3fc88uf0zrtpjj029crhtzwj6y27paqcfledjg4xw3h9"

{-The tx in should contain tx-ins of all native tokens at the storage address and tx-in for sufficient ADA-}
txInCsv = "d44e1a25223891739ae138c1d16465ffac4cfd2e51dea84922ea5a159de36a4b#1,f2fe6f3d4e226bef7aae18560adf97b100170f12b216077d5fc3cccf4a57b293#1,e47e22d8fbd94ecd783e04b420eb68728d4045cd9a0eb7eba7ac9a1373454fa1#1"

{-This is the comma separated list of policy id, asset name and total quantity at the storage address -}
assetInfo = [ "129ad21322dc33d4c9daa1002b0d92ca5d8da22d84977c7d7970165a,PapayaToken,1000000"
            , "cf91095d40729f784dcfe0ab63480f53f5762ea233120de7ad7da0b8,MangoToken,1000000"
            ]

