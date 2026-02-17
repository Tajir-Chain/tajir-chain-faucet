package main

import (
	"github.com/Tajir-Chain/tajir-chain-faucet/cmd"
)

//go:generate npm run build
func main() {
	cmd.Execute()
}
