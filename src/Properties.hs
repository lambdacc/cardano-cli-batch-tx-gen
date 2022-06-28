module Properties where

{-testnet or mainnet-}
cardanoNetwork = "testnet"

{-This is the address where your tokens to be sent are stored-}
storageAddress = "addr_test1vrw8rs5ax3fc88uf0zrtpjj029crhtzwj6y27paqcfledjg4xw3h9"

{-The tx in should contain tx-ins of all native tokens at the storage address and tx-in for sufficient ADA-}
txInList = [ "757bc5d435a17dfdc6113d346eec6c5b48bd8864ffd862a2b6e61ffc874b6c26#0"
           , "757bc5d435a17dfdc6113d346eec6c5b48bd8864ffd862a2b6e61ffc874b6c26#31"
           , "757bc5d435a17dfdc6113d346eec6c5b48bd8864ffd862a2b6e61ffc874b6c26#32"
           ]

{-This is the comma separated list of policy id, asset name and total quantity at the storage address -}
assetInfo = [ "129ad21322dc33d4c9daa1002b0d92ca5d8da22d84977c7d7970165a,PapayaToken,999171"
            , "cf91095d40729f784dcfe0ab63480f53f5762ea233120de7ad7da0b8,MangoToken,999164"
            ]

minUtxoLovelace = 1700000 :: Int
batchLimit = 300 :: Int
targetFileName = "batched-tx.sh"
