module Properties where

minUtxoLovelace = 1700000 :: Int
batchLimit = 300 :: Int
targetFileName = "batched-tx.sh"

{-testnet or mainnet-}
cardanoNetwork = "testnet"

{-This is the address where your tokens to be sent are stored-}
storageAddress = "addr_test1vrw8rs5ax3fc88uf0zrtpjj029crhtzwj6y27paqcfledjg4xw3h9"

{-This is the comma separated list of policy id, asset name and total quantity at the storage address -}
assetInfo = [ "129ad21322dc33d4c9daa1002b0d92ca5d8da22d84977c7d7970165a,PapayaToken,998342"
            , "cf91095d40729f784dcfe0ab63480f53f5762ea233120de7ad7da0b8,MangoToken,998328"
            ]

{-The tx in should contain tx-ins of all native tokens at the storage address and tx-in for sufficient ADA-}
txInList = [ "2ce2a8933d8384d6716e2ac964e8074deeb65c2161b988acad44ba8e1b0ffb42#0"
           , "f13da83f7abcda2f76a2d58777eb0effad49cc350a84abda156dece308749bb6#0"
           , "2ce2a8933d8384d6716e2ac964e8074deeb65c2161b988acad44ba8e1b0ffb42#31"
           , "2ce2a8933d8384d6716e2ac964e8074deeb65c2161b988acad44ba8e1b0ffb42#32"
           ]

