# Tajir Faucet Configuration Parameters

This document lists all configuration parameters sent from the Go backend to the frontend (via the `/api/info` endpoint) and how they are utilized within the application.

## Parameters Analysis (`faucetInfo` object)

| Parameter | Key in `faucetInfo` | Usage in UI / Logic | Description |
| :--- | :--- | :--- | :--- |
| **Network Name** | `network` | Header, Subtitles, Help Tips | Dynamically replaces "Testnet" or "Devnet" nomenclature. Used in titles like `Tajir {network} Faucet`. |
| **Token Symbol** | `symbol` | Payouts, Balance, Description | Displays the native token ticker (e.g., `TJR`, `ETH`). Used in balance badges and policy displays. |
| **Faucet Balance** | `balance` | Floating Status Badge | Shows the current available funds in the faucet wallet in the bottom-right corner. |
| **Logo URL** | `logo_url` | Navigation Bar | Source URL for the brand logo image in the top-left header. |
| **Explorer URL** | `explorer_url` | Header Links, Tx Success | Target for "Explorer" link and dynamic transaction success links (`/tx/{hash}`). |
| **Bridge URL** | `bridge_url` | Navigation Bar | Link for the "Bridge" button in the header (with devnet fallback). |
| **Payout Amount** | `payout` | Rate Limit Policy | Displays the amount of tokens disbursed (converted from Gwei to Eth/TJR). |
| **Interval** | `interval` | Rate Limit Policy | Configuration for the cooldown period (minutes converted to human-readable hours/days). |
| **Faucet Account** | `account` | Identity Display | The wallet address of the faucet itself, shown in the connection status field. |
| **hCaptcha Key** | `hcaptcha_sitekey` | Security/Verification | Used to initialize the hCaptcha bot protection widget. |
| **Customer Type** | `paid_customer` | Branding Logic | Toggles specific branding modes or removals based on customer tier. |
| **Frontend Type** | `frontend_type` | Component Routing | Switches between `Redesign.svelte` and `BaseDesign.svelte` templates. |

## Rationale
By utilizing these dynamic parameters, the faucet remains entirely network-agnostic. All branding, link destinations, and network-specific terminology are controlled purely by the Go server configuration (flags or environment variables), requiring zero code changes or rebuilds of the frontend when switching between Devnet, Testnet, or Mainnet environments.
