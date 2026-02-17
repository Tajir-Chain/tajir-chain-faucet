
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
   export WEB3_PROVIDER=http://localhost:8545
   export PRIVATE_KEY=your_private_key_here
   export EXPLORER_URL=https://explorer.devnet.tajirchain.com # Optional
   export BRIDGE_URL=https://bridge.devnet.tajirchain.com # Optional
   export FAUCET_NAME=Devnet # Optional
   export FAUCET_SYMBOL=TJR # Optional
   export FRONTEND_LOGO=/logo.svg # Optional
   export HCAPTCHA_SITEKEY=your_site_key # Optional
   ```

   *Note: For testing without a real node, you can mock or just ensure the flags are passed.*

## Running the Application

### 1. Run the Backend (Go)
The backend serves the API at `http://localhost:8080`.
From the project root:

```bash
# Example running with flags (replace with your actual provider/key)
go run main.go -wallet.provider https://ethereum-sepolia.publicnode.com -wallet.privkey f9c40c9e559be901fb2342089b45b34666843ae1d5ecdc133ceddbedc3dc6281 -faucet.name sepolia -faucet.symbol TJR -faucet.amount 100000000 -faucet.minutes 1 -frontend.logo /logo.svg -faucet.paidcustomer=true -faucet.explorer https://explorer.devnet.tajirchain.com -faucet.bridge https://bridge.devnet.tajirchain.com -hcaptcha.sitekey your_site_key -frontend.type redesign
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
