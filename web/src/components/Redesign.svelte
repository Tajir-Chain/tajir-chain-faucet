<script>
  import { onMount } from 'svelte';
  import CopyButton from './CopyButton.svelte';
  export let faucetInfo;
  export let input;
  export let handleRequest;
  export let gweiToEth;
  export let connectWallet;
  export let disconnectWallet;

  function autoResize(event) {
    const textarea = event.target;
    textarea.style.height = 'auto'; // Reset height
    textarea.style.height = `${textarea.scrollHeight}px`; // Set new height
    textarea.style.borderRadius = '12px';
  }
  const shortenAddress = (address) => {
    if (!address) return '';
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const capitalize = (str) => {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  };

  const formatInterval = (minutes) => {
    if (!minutes) return '24 hours';
    const hours = minutes / 60;
    if (hours >= 1) {
      return `${hours} hour${hours > 1 ? 's' : ''}`;
    }
    return `${minutes} minute${minutes > 1 ? 's' : ''}`;
  };

  let txState = 'idle'; // idle, sending, monitoring, success, error
  let txHash = '';
  let serverMsg = '';

  async function requestTokens() {
    txState = 'sending';
    txHash = '';
    serverMsg = '';
    
    // Silence toast alerts and handle internally
    const result = await handleRequest(input, true);
    
    if (result && result.ok) {
      serverMsg = result.msg;
      // Extract hash: "Txhash: 0x..."
      const match = result.msg.match(/0x[a-fA-F0-9]{64}/);
      if (match) {
        txHash = match[0];
        txState = 'monitoring';
        
        // Simulate monitoring for 3 seconds before showing success
        setTimeout(() => {
          txState = 'success';
        }, 3000);
      } else {
        txState = 'success';
      }
    } else {
      serverMsg = result?.msg || 'Something went wrong';
      txState = 'error';
    }
  }

  let isWrongNetwork = false;
  $: chainIdHex = faucetInfo.chain_id ? '0x' + Number(faucetInfo.chain_id).toString(16) : '';

  async function checkNetwork() {
    if (window.ethereum) {
      try {
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        // Use case-insensitive comparison for hex chain IDs
        isWrongNetwork = parseInt(chainId, 16).toString() !== faucetInfo.chain_id;
      } catch (e) {
        console.error("Failed to get chainId", e);
      }
    }
  }

  async function addNetwork() {
    if (!window.ethereum) return;
    try {
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [{
          chainId: chainIdHex,
          chainName: `Tajir ${capitalize(faucetInfo.network)}`,
          rpcUrls: [faucetInfo.rpc_url],
          nativeCurrency: {
            name: 'Tajir',
            symbol: faucetInfo.symbol,
            decimals: 18,
          },
          blockExplorerUrls: [faucetInfo.explorer_url],
        }],
      });
      await checkNetwork();
    } catch (error) {
      console.error("Failed to add network", error);
    }
  }

  onMount(() => {
    checkNetwork();
    if (window.ethereum) {
      window.ethereum.on('chainChanged', checkNetwork);
      window.ethereum.on('accountsChanged', checkNetwork);
    }
  });
</script>

<main>
  <section class="hero faucet-bg">
    <div class="bg-container">
      <div class="blob-yellow blob-1"></div>
      <div class="blob-yellow blob-2"></div>
      <div class="blob-green blob-3"></div>
    </div>
    <nav class="navbar">
      <div class="header-container">
        <div class="navbar-brand">
          <a href="https://www.tajirchain.com/">
            <span class="icon icon-brand">
              <img src={faucetInfo.logo_url} alt="logo" class="brand-logo" />
            </span>
          </a>
        </div>
        <div class="navbar-menu-custom">
          <a href="https://www.tajirchain.com/" target="_blank" class="navbar-item-custom">Website</a>
          <a href={faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"} target="_blank" class="navbar-item-custom">Explorer</a>
          <a href={faucetInfo.bridge_url || "https://bridge.devnet.tajirchain.com/"} target="_blank" class="navbar-item-custom">Bridge</a>
          <a href="https://x.com/tajirchain?s=21" target="_blank" class="navbar-item-custom twitter-link">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
          </a>
        </div>
        <div class="navbar-actions">
          {#if !input}
            <button on:click={connectWallet} class="button is-secondary is-small is-rounded nav-connect-btn">
              Connect Wallet
            </button>
          {:else}
            <div class="nav-status-widget">
              <div class="nav-status-info">
                <span class="nav-address">{shortenAddress(input)}</span>
                <span class="nav-network">{capitalize(faucetInfo.network)}</span>
              </div>
              
              {#if isWrongNetwork && window.ethereum}
                <div class="nav-add-icon-wrapper">
                  <button class="nav-add-icon-btn" on:click={addNetwork}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                  </button>
                  <span class="custom-tooltip">Add Tajir {capitalize(faucetInfo.network)}</span>
                </div>
              {/if}

              <div class="nav-status-badge">
                <span class="blinking-dot"></span>
              </div>
              <button class="disconnect-icon-btn" on:click={disconnectWallet} title="Disconnect Wallet">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
              </button>
            </div>
          {/if}
        </div>
      </div>
    </nav>

    <div class="hero-body">
      <div class="container">
        <div class="faucet-header has-text-centered">
          <h1 class="faucet-title">Tajir {capitalize(faucetInfo.network)} Faucet</h1>
          <p class="faucet-subtitle">Get Free {faucetInfo.symbol} Tokens to test the Tajir blockchain</p>
          <p class="faucet-description">
            {faucetInfo.symbol} is the native token of Tajir Blockchain. 
            Use it to pay gas fees and test smart contracts on our {faucetInfo.network}.
          </p>
        </div>

        <div class="columns desktop-columns">
          
          <!-- Left Column: Info & Details -->
          <div class="column is-6">
            <div class="how-it-works">
              <h3 class="hiw-title">How It Works</h3>
              <div class="hiw-steps">
                <div class="hiw-step">
                  <span class="step-num">1</span>
                  <div class="step-content">
                    <p class="step-text">Connect your wallet</p>
                  </div>
                </div>
                <div class="hiw-step">
                  <span class="step-num">2</span>
                  <div class="step-content">
                    <p class="step-text">Request free {faucetInfo.symbol}</p>
                    <p class="step-subtext">Automatically to connected wallet or use manual address.</p>
                  </div>
                </div>
                <div class="hiw-step">
                  <span class="step-num">3</span>
                  <div class="step-content">
                    <p class="step-text">Start building on Tajir</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="network-details {isWrongNetwork ? 'is-highlighted' : ''}">
              <div class="nd-header">
                <h3 class="nd-title">Network Details</h3>
              </div>
              <div class="nd-grid">
                <div class="nd-item">
                  <div class="nd-label">RPC URL</div>
                  <div class="nd-value">
                    <span>{faucetInfo.rpc_url}</span>
                    <CopyButton text={faucetInfo.rpc_url} />
                  </div>
                </div>
                <div class="nd-item">
                  <div class="nd-label">Chain ID</div>
                  <div class="nd-value">
                    <span>{faucetInfo.chain_id}</span>
                    <CopyButton text={faucetInfo.chain_id} />
                  </div>
                </div>
                <div class="nd-item">
                  <div class="nd-label">Explorer</div>
                  <div class="nd-value">
                    <span>{faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"}</span>
                    <CopyButton text={faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"} />
                  </div>
                </div>
              </div>
            </div>

            <div class="token-info-section">
              <h2 class="creative-heading">Fuel Your Innovation on Tajir</h2>
              <div class="token-box">
                <h3 class="token-box-title">What is {faucetInfo.symbol}?</h3>
                <p class="token-box-desc">
                  {faucetInfo.symbol} is the native gas token of Tajir devnet/testnet blockchains. You can use it to:
                </p>
                <div class="token-features">
                  <div class="feature-item">
                    <span class="feature-bullet"></span>
                    <span>Deploy smart contracts</span>
                  </div>
                  <div class="feature-item">
                    <span class="feature-bullet"></span>
                    <span>Send transactions</span>
                  </div>
                  <div class="feature-item">
                    <span class="feature-bullet"></span>
                    <span>Interact with dApps</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column: Card & Action -->
          <div class="column is-6 right-sticky-column">
            <div id="hcaptcha" data-size="invisible"></div>
            

            <div class="card">
              <div>
                <div class="subtitle">
                  <div>Paste your Ethereum compatible wallet address (Tajir {faucetInfo.network} only)</div>
                
                </div>
              </div>
              <div class="field is-grouped">
                <div class="control is-expanded">
                  <textarea
                    bind:value={input}
                    class="input"
                    rows="1"
                    on:input={autoResize}
                    placeholder="Enter your address"
                  />
                </div>
                <div class="control buttons-group">
                  <button
                    on:click={requestTokens}
                    class="button is-primary is-rounded {txState === 'sending' || txState === 'monitoring' ? 'is-loading' : ''}"
                    disabled={txState === 'sending' || txState === 'monitoring'}
                  >
                    Request Free {faucetInfo.symbol}
                  </button>
                </div>
              </div>

              {#if txState !== 'idle'}
                <div class="tx-status-container">
                  {#if txState === 'sending'}
                    <div class="status-phase">
                      <div class="spinner"></div>
                      <span>Sending transaction request...</span>
                    </div>
                  {:else if txState === 'monitoring'}
                    <div class="status-phase monitoring">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F3CD52" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                      <span>Transaction hash received. Monitoring activity...</span>
                    </div>
                  {:else if txState === 'success'}
                    <div class="status-phase success">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#39bc9f" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                      <div>
                        <strong>Transaction Completed!</strong>
                        {#if txHash}
                          <div class="hash-display">
                            <span>Hash: </span>
                            <code class="tx-hash-code">{shortenAddress(txHash)}</code>
                            <CopyButton text={txHash} />
                          </div>
                        {/if}
                        {#if txHash && faucetInfo.explorer_url}
                          <a href="{faucetInfo.explorer_url.endsWith('/') ? faucetInfo.explorer_url : faucetInfo.explorer_url + '/'}tx/{txHash}" target="_blank" class="explorer-link">
                            View on Explorer
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 22 3 22 10"/><line x1="10" y1="14" x2="22" y2="2"/></svg>
                          </a>
                        {/if}
                      </div>
                    </div>

                    <div class="help-tips">
                      <div class="tip-header">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#7E7E91" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        <span>If you don't see the balance:</span>
                      </div>
                      <ul>
                        <li>Make sure you’re on Tajir {faucetInfo.network}</li>
                        <li>Try refreshing MetaMask or TajirWallet</li>
                      </ul>
                    </div>
                  {:else if txState === 'error'}
                    <div class="status-phase error">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ff5e5e" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                      <span>{serverMsg}</span>
                    </div>
                  {/if}
                </div>
              {/if}

              <div class="rate-limit-policy">
                <div class="policy-item">
                  <span class="policy-icon">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  </span>
                  <span class="policy-text"><strong>Cooldown:</strong> Once every {formatInterval(faucetInfo.interval)}</span>
                </div>
                <div class="policy-item">
                  <span class="policy-icon">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 0 0-2 2c0 1.1.9 2 2 2h4v-4h-4z"/></svg>
                  </span>
                  <span class="policy-text"><strong>Amount:</strong> {gweiToEth(faucetInfo.payout)} {faucetInfo.symbol} per request</span>
                </div>
              </div>
            </div>

            <p class="disclaimer">
              <strong>Disclaimer:</strong> This faucet sends free tokens for development and testing purposes only, and have no monetary value.
            </p>
          </div>
        </div>
      </div>
    </div>

    <div class="balance-badge">
      <span class="balance-value">{faucetInfo.balance} {faucetInfo.symbol}</span>
    </div>
  </section>
</main>

<style>

/* ===== BIG Gradient Circles Background ===== */
.faucet-bg {
  position: relative;
  background-color: #ffffff;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.bg-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}

@media (min-width: 1024px) {
  .hero-body {
    padding-top: 2rem;
    padding-bottom: 2rem;
  }

  .left-scroll-column {
    padding-right: 3rem !important;
  }

  .right-sticky-column {
    position: sticky;
    top: 4rem;
    height: fit-content;
    align-self: flex-start;
  }
}

/* Ensure the hero body can grow/shred naturally */
.hero-body {
  flex-grow: 1;
  display: flex;
  align-items: flex-start;
}

.bg-container::before,
.bg-container::after {
  content: "";
  position: absolute;
  width: 900px;
  height: 900px;
  border-radius: 50%;
  z-index: 0;
  pointer-events: none;
  opacity: 0.6;
}

/* Top Right – Green */
.bg-container::before {
  top: -420px;
  right: -420px;
  background: radial-gradient(
    circle,
    rgba(57, 188, 159, 0.4) 0%,
    rgba(57, 188, 159, 0.1) 60%,
    rgba(57, 188, 159, 0) 80%
  );
  animation: float-slow 20s infinite alternate;
}

/* Bottom Left – Green */
.bg-container::after {
  bottom: -460px;
  left: -460px;
  background: radial-gradient(
    circle,
    rgba(57, 188, 159, 0.4) 0%,
    rgba(57, 188, 159, 0.1) 60%,
    rgba(57, 188, 159, 0) 80%
  );
  animation: float-slow 25s infinite alternate-reverse;
}

.blob-yellow {
  position: absolute;
  border-radius: 50%;
  z-index: 0;
  pointer-events: none;
}

.blob-1 {
  top: 10%;
  left: -10%;
  width: 600px;
  height: 600px;
  background: radial-gradient(
    circle,
    rgba(243, 205, 82, 0.25) 0%,
    rgba(243, 205, 82, 0.1) 50%,
    rgba(243, 205, 82, 0) 70%
  );
  animation: pulse-yellow 15s infinite alternate;
}

.blob-2 {
  bottom: 10%;
  right: -5%;
  width: 500px;
  height: 500px;
  background: radial-gradient(
    circle,
    rgba(243, 205, 82, 0.2) 0%,
    rgba(243, 205, 82, 0.05) 50%,
    rgba(243, 205, 82, 0) 70%
  );
  animation: pulse-yellow 18s infinite alternate-reverse;
}

@keyframes float-slow {
  0% { transform: translate(0, 0) scale(1); }
  100% { transform: translate(50px, 40px) scale(1.1); }
}

@keyframes pulse-yellow {
  0% { transform: translate(0, 0) scale(1); opacity: 0.6; }
  50% { transform: translate(-30px, 20px) scale(1.1); opacity: 0.8; }
  100% { transform: translate(30px, -20px) scale(0.9); opacity: 0.5; }
}

/* Keep content above gradients */
.faucet-bg > * {
  position: relative;
  z-index: 1;
}

/* Mobile tuning */
@media (max-width: 768px) {
  .bg-container::before,
  .bg-container::after {
    width: 620px;
    height: 620px;
  }

  .bg-container::before {
    top: -300px;
    right: -300px;
  }

  .bg-container::after {
    bottom: -320px;
    left: -320px;
  }
}



.navbar {
  display: flex;
  width: 100%;
}

.header-container {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  width: 100%;
  padding-inline: 32px;
  align-items: center;
  gap: 16px;
  max-width: 1400px;
  margin: 0 auto;
}

.navbar-brand {
  margin: 0;
}
  .deploy-btn-mobile {
    display: none;
  }
  .input {
    resize: none;
    overflow: hidden;
    background: #F7F7F7;
    color: black;
    border-radius: 12px !important;
    min-height: 42px;
    height: 55px;
    border-radius: 13px;
    border: none;
    padding: 15px 19px; 
  }

  .hero {
    padding-top: 16px;
  }
  .box-logo {
    display: flex;
    justify-content: center;
    align-items: center;
    color: #303030;
    margin-top: 16px;
    gap: 8px;
    font-size: 14px;
    font-weight: 500;
  }
  .network {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-weight: 500;
    padding: 8px 12px;
    background-color: #39bc9f;
    border-radius: 8px;
    color: #183053;
  }
  .balance-badge {
    position: fixed;
    bottom: 24px;
    right: 24px;
    display: flex;
    padding: 6px 12px;
    border-radius: 10px;
    backdrop-filter: blur(8px);
    z-index: 100;
  }
  .balance-value {
    font-size: 10px;
    font-weight: 400;
    color: #1F1F37;
  }
  .link {
    color: #f3cd52 !important;
    text-decoration: underline;
    cursor: pointer;
  }

  .button.is-primary {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    background-color: #F3CD52;
    padding: 0 24px;
    border-radius: 12px !important;
    color: #1F1F37;
    min-height: 52px;
    font-weight: 700;
    font-size: 16px;
    border: none;
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: 0 4px 14px rgba(243, 205, 82, 0.4);
  }

  .button.is-primary:hover:not(:disabled) {
    box-shadow: 0 8px 24px rgba(243, 205, 82, 0.6);
  }

  .button.is-secondary {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    background-color: transparent;
    border: 2px solid #39bc9f;
    padding: 0 24px;
    border-radius: 12px !important;
    color: #39bc9f;
    min-height: 52px;
    font-weight: 700;
    font-size: 16px;
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: 0 4px 14px rgba(57, 188, 159, 0.2);
  }

  .button.is-secondary:hover:not(:disabled) {
    box-shadow: 0 8px 24px rgba(57, 188, 159, 0.35);
  }

  .button.is-secondary:hover {
    background-color: #39bc9f;
    color: white;
  }

  .button:hover:not(:disabled) {
    /* Lift removed as requested */
    box-shadow: 0 6px 16px rgba(0,0,0,0.12);
  }

  .button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    background-color: #f0f0f0;
    border-color: #d0d0d0;
    color: #999;
  }

  .buttons-group {
    display: flex;
    gap: 12px;
    width: 100%;
  }

  @media (max-width: 768px) {
    .buttons-group {
      flex-direction: column;
    }
  }

  .box-offer {
    font-weight: 400;
    font-size: 12px;
    line-height: 20px;
    letter-spacing: 0px;
  }
  .address-from {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 8px;
    background-color: #F7F7F7;
    font-size: 12px;
    font-weight: 400;
    color: #1F1F37;
  }
  .field {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .gas-token {
    color: #f3cd52;
  }

  .card {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-width: unset;
    max-width: 638px;
    gap: 12px;
    box-shadow: 0px 0px 16px rgba(0, 0, 0, 0.1);
    border-radius: 16px;
    padding: 32px;
  }

  .faucet-header {
    margin-bottom: 2.5rem;
    padding-top: 1rem;
  }

  @media (min-width: 1024px) {
    .faucet-header {
      margin-bottom: 2rem;
    }
  }

  .faucet-title {
    color: #1F1F37;
    font-weight: 800;
    font-size: 48px;
    line-height: 1;
    margin-bottom: 1rem;
    letter-spacing: -0.03em;
  }

  .faucet-subtitle {
    color: #39bc9f;
    font-weight: 600;
    font-size: 20px;
    margin-bottom: 1.25rem;
  }

  .faucet-description {
    color: #5A5A75;
    font-size: 16px;
    line-height: 1.6;
    max-width: 720px;
    margin-inline: auto;
    margin-bottom: 0;
  }

  /* How It Works Styles */
  .how-it-works {
    background: rgba(57, 188, 159, 0.05);
    border-radius: 16px;
    padding: 1rem;
    margin-bottom: 1.25rem;
    text-align: left;
    max-width: 100%;
    border: 1px solid rgba(57, 188, 159, 0.1);
  }

  /* Token Info Section */
  .token-info-section {
    text-align: left;
  }

  .creative-heading {
    font-size: 14px;
    font-weight: 700;
    color: #39bc9f;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    margin-bottom: 0.75rem;
  }

  .token-box {
    background: #ffffff;
    border-radius: 16px;
    padding: 1.25rem;
    border: 1px solid #f0f0f0;
    box-shadow: 0 4px 20px rgba(0,0,0,0.03);
  }

  .token-box-title {
    font-size: 18px;
    font-weight: 700;
    color: #1F1F37;
    margin-bottom: 0.5rem;
  }

  .token-box-desc {
    font-size: 14px;
    color: #5A5A75;
    line-height: 1.5;
    margin-bottom: 1rem;
  }

  .token-features {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .feature-item {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
    color: #1F1F37;
    font-weight: 600;
  }

  .feature-bullet {
    width: 6px;
    height: 6px;
    background: #39bc9f;
    border-radius: 50%;
  }

  .hiw-title {
    font-size: 18px;
    font-weight: 700;
    color: #1F1F37;
    margin-bottom: 1.25rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .hiw-steps {
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }

  .hiw-step {
    display: flex;
    gap: 1rem;
    align-items: flex-start;
  }

  .step-num {
    background: #39bc9f;
    color: white;
    width: 24px;
    height: 24px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 700;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .step-text {
    font-weight: 600;
    color: #1F1F37;
    font-size: 15px;
    margin-bottom: 2px;
  }

  .step-subtext {
    font-size: 13px;
    color: #5A5A75;
    line-height: 1.4;
  }

  /* Connection Status Styles */
  .connection-status {
    display: flex;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .status-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    background: white;
    padding: 6px 14px;
    border-radius: 100px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #f0f0f0;
  }

  .status-label {
    font-weight: 600;
    font-size: 13px;
    color: #7E7E91;
  }

  .status-value {
    font-weight: 700;
    font-size: 13px;
    color: #1F1F37;
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .blinking-dot {
    width: 8px;
    height: 8px;
    background-color: #7CB342;
    border-radius: 50%;
    display: inline-block;
    box-shadow: 0 0 0 0 rgba(124, 179, 66, 0.7);
    animation: pulse-green 2s infinite;
  }

  @keyframes pulse-green {
    0% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(124, 179, 66, 0.7);
    }
    70% {
      transform: scale(1);
      box-shadow: 0 0 0 6px rgba(124, 179, 66, 0);
    }
    100% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(124, 179, 66, 0);
    }
  }

  .status-value {
    font-weight: 700;
    font-size: 13px;
    color: #39bc9f;
  }

  /* Rate Limit Policy Styles */
  .rate-limit-policy {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 1.5rem;
    margin-top: 1.5rem;
    padding-top: 1.25rem;
    border-top: 1px solid #f0f0f0;
  }

  .policy-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: #5A5A75;
  }

  .policy-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #39bc9f;
  }

  .policy-text {
    font-size: 13px;
    line-height: 1;
  }

  .policy-text strong {
    color: #1F1F37;
  }

  @media (max-width: 600px) {
    .rate-limit-policy {
      flex-direction: column;
      gap: 0.75rem;
      align-items: flex-start;
      padding-left: 0.5rem;
    }
  }

  .disclaimer {
    margin-top: 1.5rem;
    font-size: 13px;
    color: #7E7E91;
    line-height: 1.5;
    max-width: 100%;
    text-align: left;
  }

  @media (max-width: 1023px) {
    .disclaimer {
      text-align: center;
    }
  }

  .disclaimer strong {
    color: #ff5e5e;
  }
  .hero.is-info {
    background:
      linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)),
      no-repeat center center fixed;
    -webkit-background-size: cover;
    -moz-background-size: cover;
    -o-background-size: cover;
    background-size: cover;
  }
  .hero.is-info .faucet-title {
    color: #000;
  }

  .subtitle {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    font-size: 16px;
    font-weight: 500;
    letter-spacing: 0px;
    color: #161718;
  }


  .hero .subtitle {
    line-height: 1.5;
  }
  .centered-column {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .control {
    display: flex;
    flex-direction: column;
    width: 100%;
    gap: 24px;
  }

  .navbar-item {
    color: #f3cd52 !important;
  }
  .navbar-item:hover {
    background-color: transparent !important;
    cursor: pointer;
  }

  .icon {
    width: 243px;
    height: 62px;
  }

  .icon-brand {
    width: auto;
    height: 48px;
    display: flex;
    align-items: center;
  }

  .brand-logo {
    max-height: 40px;
    width: auto;
    object-fit: contain;
  }

  .navbar-menu-custom {
    display: flex;
    align-items: center;
    gap: 2rem;
  }

  .navbar-item-custom {
    color: #1F1F37;
    font-weight: 600;
    font-size: 14px;
    text-decoration: none;
    transition: color 0.2s;
    border-bottom: 2px solid transparent;
    padding-bottom: 4px;
  }

  .navbar-item-custom:hover {
    color: #39bc9f;
    border-bottom-color: #39bc9f;
  }

  .twitter-link {
    display: flex;
    align-items: center;
    border: none !important;
  }

  .navbar-actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
  }

  .nav-connect-btn {
    width: auto !important;
    min-width: 140px;
    min-height: 40px !important;
    padding: 0 20px !important;
    font-size: 14px !important;
    transition: all 0.3s ease;
  }
  
  .nav-connect-btn:hover {
    box-shadow: 0 6px 16px rgba(57, 188, 159, 0.3) !important;
  }

  .nav-status-widget {
    display: flex;
    align-items: center;
    gap: 12px;
    background: white;
    padding: 6px 12px;
    border-radius: 12px;
    border: 1px solid #f0f0f0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }

  .nav-status-info {
    display: flex;
    flex-direction: column;
    text-align: right;
  }

  .nav-address {
    font-size: 13px;
    font-weight: 700;
    color: #1F1F37;
    line-height: 1.2;
  }

  .nav-network {
    font-size: 11px;
    font-weight: 600;
    color: #39bc9f;
    line-height: 1.2;
  }

  .nav-add-icon-btn {
    background: #F3CD52;
    border: none;
    padding: 6px;
    margin: 0 4px;
    color: #1F1F37;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    transition: all 0.2s;
    box-shadow: 0 2px 8px rgba(243, 205, 82, 0.3);
  }

  .nav-add-icon-btn:hover {
    box-shadow: 0 4px 12px rgba(243, 205, 82, 0.4);
    transform: scale(1.05);
  }

  .nav-add-icon-wrapper {
    position: relative;
    display: flex;
    align-items: center;
  }

  .custom-tooltip {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%) translateY(10px);
    background: #1F1F37;
    color: white;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    white-space: nowrap;
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    z-index: 1000;
    pointer-events: none;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
  }

  .custom-tooltip::after {
    content: '';
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    border-width: 6px;
    border-style: solid;
    border-color: transparent transparent #1F1F37 transparent;
  }

  .nav-add-icon-wrapper:hover .custom-tooltip {
    opacity: 1;
    visibility: visible;
    transform: translateX(-50%) translateY(8px);
  }

  .nav-status-badge {
    display: flex;
    align-items: center;
    gap: 6px;
    background: rgba(57, 188, 159, 0.1);
    padding: 4px 10px;
    border-radius: 20px;
  }

  .status-text {
    display: none;
  }

  .disconnect-icon-btn {
    background: none;
    border: none;
    padding: 4px;
    margin-left: 4px;
    color: #7E7E91;
    cursor: pointer;
    display: flex;
    align-items: center;
    border-radius: 6px;
    transition: all 0.2s;
  }

  .disconnect-icon-btn:hover {
    background: rgba(255, 94, 94, 0.1);
    color: #ff5e5e;
  }

  @media (max-width: 768px) {
    .navbar-menu-custom {
      display: none;
    }
    
    .header-container {
      display: flex;
      justify-content: space-between;
      padding-inline: 16px;
    }

    .navbar-actions {
      flex-shrink: 0;
    }

    .nav-status-info {
      display: none;
    }
  }

  @media (max-width: 992px) {
    .subtitle {
      font-size: 12px;
    }

  }

  @media (max-width: 768px) {
    .card {
      padding: 24px 16px;
    }

    .subtitle {
      flex-direction: column;
      align-items: center;
      text-align: center;
      font-size: 16px;
      gap: 12px;
    }

    .address-from {
      width: 100%;
      justify-content: center;
    }

    .faucet-title {
      font-size: 28px;
      line-height: 1.1;
      font-weight: 700;
    }

    .faucet-subtitle {
      font-size: 18px;
    }

    .faucet-description {
      font-size: 14px;
      padding-inline: 12px;
      margin-bottom: 1.5rem;
    }

    .connection-status {
      flex-direction: column;
      gap: 0.75rem;
      align-items: center;
    }

    .status-item {
      width: 100%;
      max-width: 280px;
      justify-content: center;
    }

    .how-it-works {
      padding: 1rem;
      margin-inline: 1rem;
    }

    .hiw-title {
      font-size: 16px;
      margin-bottom: 1rem;
    }

    .step-text {
      font-size: 14px;
    }

    .step-subtext {
      font-size: 12px;
    }
    .navbar-desktop {
      display: none;
    }

    .hero-body {
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding: 2rem 1rem;
    }
    .deploy-link-mobile {
      display: flex;
      width: 80%;
    }

    .deploy-btn-mobile {
      display: flex;
      justify-content: center;
      margin-top: 16px;
      min-width: 100%;
    }
  }

  /* Transaction Status Styles */
  .tx-status-container {
    padding: 1rem;
    background: #FAFAFA;
    border-radius: 12px;
    border: 1px solid #EDEDED;
    animation: fadeIn 0.3s ease;
    margin-top: 1rem;
  }

  .status-phase {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 14px;
    color: #5A5A75;
  }

  .status-phase.success strong {
    color: #1F1F37;
    display: block;
  }

  .explorer-link {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    color: #39bc9f;
    font-weight: 600;
    text-decoration: none;
    margin-top: 4px;
    border-bottom: 1px dashed transparent;
    transition: all 0.2s;
  }

  .explorer-link:hover {
    border-bottom-color: #39bc9f;
  }

  .hash-display {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 4px 0;
    font-size: 13px;
    color: #5A5A75;
  }

  .tx-hash-code {
    background: #F0F0F0;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: inherit;
    font-weight: 600;
  }

  .help-tips {
    margin-top: 1rem;
    padding-top: 0.75rem;
    border-top: 1px solid #EDEDED;
  }

  .tip-header {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    font-weight: 600;
    color: #7E7E91;
    margin-bottom: 6px;
  }

  .help-tips ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .help-tips li {
    font-size: 12px;
    color: #9A9AAB;
    padding-left: 22px;
    position: relative;
    margin-bottom: 4px;
    text-align: left;
  }

  .help-tips li::before {
    content: "•";
    position: absolute;
    left: 8px;
    color: #39bc9f;
  }

  .spinner {
    width: 20px;
    height: 20px;
    border: 2px solid rgba(57, 188, 159, 0.1);
    border-top-color: #39bc9f;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(5px); }
    to { opacity: 1; transform: translateY(0); }
  }

  /* Network Details Styles */
  .network-details {
    background: #ffffff;
    border-radius: 16px;
    padding: 1.25rem;
    margin-bottom: 1.5rem;
    border: 1px solid #f0f0f0;
    box-shadow: 0 4px 20px rgba(0,0,0,0.03);
    transition: all 0.3s ease;
  }

  .network-details.is-highlighted {
    border-color: #F3CD52;
    background: rgba(243, 205, 82, 0.03);
  }

  .nd-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .nd-title {
    font-size: 16px;
    font-weight: 700;
    color: #1F1F37;
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .nd-grid {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .nd-item {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .nd-label {
    font-size: 11px;
    font-weight: 700;
    color: #7E7E91;
    text-transform: uppercase;
    letter-spacing: 0.02em;
  }

  .nd-value {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #F7F7F7;
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 13px;
    color: #1F1F37;
    font-family: 'Courier New', Courier, monospace;
    word-break: break-all;
  }

</style>
