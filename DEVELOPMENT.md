
# Development Guide

This guide explains how to run the project for development with Hot Module Replacement (HMR) for the frontend and a running Go backend.

## Prerequisites

- **Go**: Version 1.17+
- **Node.js**: Version 18+ (verified with v22)
- **Yarn**: (`npm install -g yarn`)

### WSL Go Installation (Windows Users)
If you are developing on Windows, it is recommended to use WSL (Ubuntu). Follow these steps to install Go:

1. **Download Go**:
   ```bash
   wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
   ```
2. **Install Go**:
   ```bash
   sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
   ```
3. **Set Environment Variables**:
   Add these to your `~/.bashrc`:
   ```bash
   export PATH=$PATH:/usr/local/go/bin
   export GOPATH=$HOME/go
   export PATH=$PATH:$GOPATH/bin
   ```
   Then run `source ~/.bashrc`.
4. **Verify**: Run `go version`.

## Setup

1. **Install Frontend Dependencies**:
   ```bash
   cd web
   yarn install
   ```

2. **Configure Environment**:
   You will need a private key or keystore to run the faucet.
   Create a `.env` file or export variables:
   ```bash
   export WEB3_PROVIDER=https://rpc.devnet.tajirchain.com # Used for RPC URL & Chain ID detection
   export PRIVATE_KEY=your_private_key_here
   export EXPLORER_URL=https://explorer.devnet.tajirchain.com # Optional
   export BRIDGE_URL=https://bridge.devnet.tajirchain.com # Optional
   export FAUCET_NAME=Devnet # Optional
   export FAUCET_SYMBOL=TJR # Optional
   export FRONTEND_LOGO=/logo.svg # Optional
   export HCAPTCHA_SITEKEY=your_site_key # Optional
   ```

   *Note: The frontend automatically displays the `WEB3_PROVIDER` as the RPC URL and detects the Chain ID from it.*

## Running the Application

### 1. Run the Backend (Go)
The backend serves the API at `http://localhost:8080`.

**Note:** The faucet now uses **Dynamic Configuration**. The Chain ID is automatically detected from the `-wallet.provider` endpoint. The RPC URL, Explorer URL, and Network Name displayed on the frontend are all controlled by the backend flags.

From the project root:

```bash
# Example running with flags (replace with your actual provider/key)
go run main.go \
  -wallet.provider http://cdk-erigon-sequencer.tajir-l2.svc:8545 \
  -wallet.privkey 7d79a91573fddc5befe23467234656755fe5783d8c5ef89b0def19e1bd900c6b \
  -faucet.name devnet \
  -faucet.publicrpc https://rpc.devnet.tajirchain.com \
  -faucet.symbol tTJR \
  -faucet.amount 1000000000 \
  -faucet.minutes 1440 \
  -faucet.paidcustomer true \
  -faucet.explorer https://explorer.devnet.tajirchain.com \
  -faucet.bridge https://bridge.devnet.tajirchain.com \
  -faucet.website https://www.tajirchain.com/ \
  -faucet.twitter https://x.com/tajirchain?s=21 \
  -frontend.logo /logo.svg \
  -frontend.type redesign \
  -httpport 8080 \
  -proxycount 1
```

If you don't have a provider yet and just want to test the server startup, it might panic without a valid private key/provider. You can generate a random dummy private key for testing startup:
`0000000000000000000000000000000000000000000000000000000000000001`

### 2. Run the Frontend (Vite)
The frontend runs on `http://localhost:5173` (or similar) and proxies `/api` requests to the Go backend.
From the `web/` directory:

```bash
yarn dev
```

## Accessing the App
Open your browser to **http://localhost:5173**. 
- Changes to Svelte files will update automatically.
- API requests will go to your running Go server.



## Build Creation 
 docker buildx build --platform linux/amd64     --build-arg GIT_COMMIT_SHA=$(git rev-parse --short HEAD)     --build-arg GIT_TAG=tajir-v1.1.2     -t tajirchain/tajir-chain-faucet:v1.1.3     -t tajirchain/tajir-chain-faucet:latest     --push .