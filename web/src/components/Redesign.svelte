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
          rpcUrls: [faucetInfo.public_rpc_url],
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

  let isMenuOpen = false;
  const toggleMenu = () => isMenuOpen = !isMenuOpen;

  // Animation variants or helper states could go here if needed
</script>

<svelte:head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</svelte:head>

<main>
  <section class="hero faucet-bg">
    <div class="bg-container">
      <div class="blob blob-primary blob-1"></div>
      <div class="blob blob-secondary blob-2"></div>
      <div class="blob blob-accent blob-3"></div>
      <div class="mesh-overlay"></div>
    </div>
    <nav class="navbar">
      <div class="nav-glass-pill">
        <div class="nav-left">
          <a href="https://www.tajirchain.com/" class="logo-wrapper">
            <img src={faucetInfo.logo_url} alt="Tajir Logo" class="brand-logo" />
          </a>
        </div>

        <div class="nav-center">
          <div class="nav-links">
            <a href="https://www.tajirchain.com/" target="_blank" class="nav-link">Website</a>
            <a href={faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"} target="_blank" class="nav-link">Explorer</a>
            <a href={faucetInfo.bridge_url || "https://bridge.devnet.tajirchain.com/"} target="_blank" class="nav-link">Bridge</a>
            <a href="https://x.com/tajirchain?s=21" target="_blank" class="nav-link twitter">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
            </a>
          </div>
        </div>

        <div class="nav-mobile-toggle">
          <button class="btn-hamburger" on:click={toggleMenu} aria-label="Toggle Menu">
            {#if isMenuOpen}
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            {:else}
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            {/if}
          </button>
        </div>

        <div class="nav-right">
          {#if !input}
            <button on:click={connectWallet} class="btn-connect">
              Connect Wallet
            </button>
          {:else}
            <div class="wallet-status">
              <div class="wallet-info">
                <div class="addr-wrapper">
                  <span class="addr">{shortenAddress(input)}</span>
                  <div class="addr-tooltip">{input}</div>
                </div>
                <span class="net">{capitalize(faucetInfo.network)}</span>
              </div>
              
              {#if isWrongNetwork && window.ethereum}
                <button class="btn-add-chain" on:click={addNetwork} title="Add Tajir {capitalize(faucetInfo.network)}">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                </button>
              {/if}

              <div class="live-indicator">
                <span class="dot"></span>
              </div>
              
              <button class="btn-disconnect" on:click={disconnectWallet} title="Disconnect Wallet">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
              </button>
            </div>
          {/if}
        </div>
      </div>

      {#if isMenuOpen}
        <div class="mobile-menu-overlay" on:click={toggleMenu}>
          <div class="mobile-menu-content" on:click|stopPropagation>
            <div class="mobile-nav-links">
              <a href="https://www.tajirchain.com/" target="_blank" class="mobile-nav-link" on:click={toggleMenu}>
                <span class="m-icon">🏠</span>
                Official Website
              </a>
              <a href={faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"} target="_blank" class="mobile-nav-link" on:click={toggleMenu}>
                <span class="m-icon">🔍</span>
                Block Explorer
              </a>
              <a href={faucetInfo.bridge_url || "https://bridge.devnet.tajirchain.com/"} target="_blank" class="mobile-nav-link" on:click={toggleMenu}>
                <span class="m-icon">🔗</span>
                Token Bridge
              </a>
              <a href="https://x.com/tajirchain?s=21" target="_blank" class="mobile-nav-link" on:click={toggleMenu}>
                <span class="m-icon">𝕏</span>
                Follow Twitter
              </a>
            </div>
          </div>
        </div>
      {/if}
    </nav>

    <div class="hero-body">
      <div class="container">
        <div class="faucet-header has-text-centered">
          <h1 class="faucet-title">Tajir <span class="network-badge">{capitalize(faucetInfo.network)}</span> Faucet</h1>
          <p class="faucet-subtitle">Get Free {faucetInfo.symbol} Tokens to test the Tajir blockchain</p>
          <div class="description-container">
            <p class="faucet-description">
              {faucetInfo.symbol} is the native token of Tajir Blockchain. 
              Use it to pay gas fees and test smart contracts on our {faucetInfo.network}.
            </p>
          </div>
        </div>

        <div class="columns desktop-columns">
          
          <!-- Left Column: Info & Details -->
          <div class="column is-6">
            <div class="how-it-works">
              <h3 class="hiw-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>
                Execution Guide
              </h3>
              <div class="hiw-steps">
                <div class="hiw-step">
                  <div class="step-visual">
                    <div class="step-icon-box">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 0 0-2 2c0 1.1.9 2 2 2h4v-4h-4z"/></svg>
                    </div>
                    <div class="step-line"></div>
                  </div>
                  <div class="step-content">
                    <p class="step-text">Connect Wallet</p>
                    <p class="step-subtext">Link your provider to automatically fetch your address.</p>
                  </div>
                </div>
                
                <div class="hiw-step">
                  <div class="step-visual">
                    <div class="step-icon-box">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 2a2 2 0 0 0-2 2v5H4a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h5v5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2v-5h5a2 2 0 0 0 2-2v-2a2 2 0 0 0-2-2h-5V4a2 2 0 0 0-2-2h-2z"/></svg>
                    </div>
                    <div class="step-line"></div>
                  </div>
                  <div class="step-content">
                    <p class="step-text">Request {faucetInfo.symbol}</p>
                    <p class="step-subtext">Claim test tokens for development and contract deployment.</p>
                  </div>
                </div>

                <div class="hiw-step">
                  <div class="step-visual">
                    <div class="step-icon-box">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    </div>
                  </div>
                  <div class="step-content">
                    <p class="step-text">Build on Tajir</p>
                    <p class="step-subtext">Start deploying smart contracts and testing your applications.</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="network-details {isWrongNetwork ? 'is-highlighted-warning' : 'is-highlighted-info'}">
              <div class="nd-header">
                <div class="nd-title-group">
                  <div class="title-icon-box">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                  </div>
                  <h3 class="nd-title">Network Configuration</h3>
                </div>
                {#if isWrongNetwork}
                  <span class="warning-badge">Wrong Network</span>
                {/if}
              </div>

              <div class="nd-grid-compact">
                <div class="nd-cell full">
                  <div class="cell-label">
                    <span>RPC Endpoint</span>
                    <CopyButton text={faucetInfo.public_rpc_url} />
                  </div>
                  <div class="cell-value mono">{faucetInfo.public_rpc_url}</div>
                </div>
                
                <div class="nd-row-compact">
                  <div class="nd-cell">
                    <div class="cell-label">
                      <span>Chain ID</span>
                      <CopyButton text={faucetInfo.chain_id} />
                    </div>
                    <div class="cell-value mono">{faucetInfo.chain_id}</div>
                  </div>
                  <div class="nd-cell">
                    <div class="cell-label">
                      <span>Currency</span>
                    </div>
                    <div class="cell-value highlight">{faucetInfo.symbol}</div>
                  </div>
                </div>

                <div class="nd-cell full">
                  <div class="cell-label">
                    <span>Block Explorer</span>
                    <CopyButton text={faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"} />
                  </div>
                  <div class="cell-value link-style mono">{faucetInfo.explorer_url || "https://explorer.devnet.tajirchain.com/"}</div>
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
            <div class="token-info-section" style="margin-top: 1.25rem;">
              <div class="token-box is-highlighted-info">
                <div class="token-header">
                  <div class="title-icon-box">
                    <img src={faucetInfo.logo_url} alt="Token" class="token-logo-small" />
                  </div>
                  <h3 class="token-box-title">Asset Intelligence</h3>
                </div>
                
                <div class="token-desc-container">
                  <p class="token-box-desc">
                    {faucetInfo.symbol} is the native utility asset of Tajir, essential for resource allocation and network security.
                  </p>
                </div>

                <div class="token-feature-grid-compact">
                  <div class="feat-cell">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>Gas Fees</span>
                  </div>
                  <div class="feat-cell">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>Smart Contracts</span>
                  </div>
                  <div class="feat-cell">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>Network Testing</span>
                  </div>
                  <div class="feat-cell">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>System Staking</span>
                  </div>
                </div>
              </div>
            </div>

           
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
  :root {
    --primary: #F3CD52; /* Yellow */
    --primary-glow: rgba(243, 205, 82, 0.4);
    --secondary: #39bc9f; /* Green */
    --secondary-glow: rgba(57, 188, 159, 0.4);
    --dark: #1F1F37;
    --dark-muted: #5A5A75;
    --light-muted: #7E7E91;
    --glass-bg: rgba(255, 255, 255, 0.7);
    --glass-border: rgba(255, 255, 255, 0.4);
    --card-shadow: 0 20px 40px rgba(0, 0, 0, 0.06);
    --font-main: 'Outfit', sans-serif;
  }

  /* ===== Global Reset & Base ===== */
  main {
    font-family: var(--font-main);
    color: var(--dark);
    -webkit-font-smoothing: antialiased;
  }

  /* ===== Premium Background ===== */
  .faucet-bg {
    position: relative;
    background-color: #fcfcfd;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    overflow-x: hidden;
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

  .mesh-overlay {
    position: absolute;
    inset: 0;
    background-image: 
      radial-gradient(at 0% 0%, rgba(243, 205, 82, 0.05) 0px, transparent 50%),
      radial-gradient(at 100% 0%, rgba(57, 188, 159, 0.05) 0px, transparent 50%);
    opacity: 0.8;
  }

  .blob {
    position: absolute;
    filter: blur(80px);
    border-radius: 50%;
    opacity: 0.4;
    transition: transform 10s ease-in-out;
  }

  .blob-primary { background: var(--primary); width: 600px; height: 600px; }
  .blob-secondary { background: var(--secondary); width: 500px; height: 500px; }
  .blob-accent { background: #6366f1; width: 400px; height: 400px; opacity: 0.1; }

  .blob-1 { top: -10%; left: -10%; animation: float 20s infinite alternate; }
  .blob-2 { bottom: -10%; right: -10%; animation: float 25s infinite alternate-reverse; }
  .blob-3 { top: 40%; left: 30%; animation: pulse-opacity 15s infinite alternate; }

  @keyframes float {
    0% { transform: translate(0, 0) scale(1) rotate(0deg); }
    100% { transform: translate(60px, 40px) scale(1.1) rotate(15deg); }
  }

  @keyframes pulse-opacity {
    0% { opacity: 0.1; transform: scale(1); }
    100% { opacity: 0.25; transform: scale(1.2); }
  }

  /* ===== Professional Header & Navbar ===== */
  .navbar {
    position: sticky;
    top: 1rem;
    z-index: 1000;
    width: 100%;
    display: flex;
    justify-content: center;
    padding: 0 1rem;
    margin-bottom: 3rem;
  }

  .nav-glass-pill {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    align-items: center;
    width: 100%;
    max-width: 1240px;
    padding: 0.6rem 2rem;
    background: rgba(255, 255, 255, 0.75);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.45);
    box-shadow: 
      0 4px 6px -1px rgba(0, 0, 0, 0.05),
      0 10px 15px -3px rgba(0, 0, 0, 0.03),
      inset 0 0 0 1px rgba(255, 255, 255, 0.5);
  }

  .nav-left {
    display: flex;
    align-items: center;
  }

  .logo-wrapper {
    display: flex;
    align-items: center;
    transition: transform 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
  }

  .logo-wrapper:hover {
    transform: scale(1.02);
  }

  .brand-logo {
    height: 44px;
    width: auto;
    object-fit: contain;
  }

  .nav-center {
    display: flex;
    justify-content: center;
  }

  .nav-links {
    display: flex;
    align-items: center;
    gap: 2.5rem;
    background: rgba(0, 0, 0, 0.03);
    padding: 0.4rem 1.75rem;
    border-radius: 100px;
    border: 1px solid rgba(0, 0, 0, 0.02);
  }

  .nav-link {
    color: var(--dark-muted);
    font-weight: 600;
    font-size: 0.875rem;
    text-decoration: none;
    transition: all 0.2s ease;
    padding: 0.25rem 0.5rem;
  }

  .nav-link:hover {
    color: var(--secondary);
  }

  .nav-link.twitter {
    display: flex;
    align-items: center;
    color: var(--dark);
    opacity: 0.7;
  }

  .nav-link.twitter:hover {
    opacity: 1;
    color: var(--dark);
  }

  .nav-right {
    display: flex;
    justify-content: flex-end;
    align-items: center;
  }

  .btn-connect {
    background: var(--secondary);
    color: white;
    font-weight: 700;
    font-size: 0.875rem;
    padding: 0.75rem 1.5rem;
    border-radius: 14px;
    border: none;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
    box-shadow: 0 4px 12px var(--secondary-glow);
  }

  .btn-connect:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px var(--secondary-glow);
    filter: brightness(1.05);
  }

  .wallet-status {
    display: flex;
    align-items: center;
    gap: 1rem;
    background: white;
    padding: 0.4rem 0.6rem 0.4rem 1rem;
    border-radius: 16px;
    border: 1px solid rgba(0, 0, 0, 0.05);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
  }

  .wallet-info {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    line-height: 1.2;
  }

  .wallet-info .addr {
    font-weight: 800;
    font-size: 0.8rem;
    color: var(--dark);
    cursor: default;
  }

  .addr-wrapper {
    position: relative;
    display: inline-block;
  }

  .addr-tooltip {
    position: absolute;
    top: calc(100% + 12px); /* Positioned below instead of above */
    left: 50%;
    transform: translateX(-50%) translateY(-10px);
    background: var(--dark);
    color: white;
    padding: 0.6rem 0.8rem;
    border-radius: 10px;
    font-size: 0.75rem;
    font-family: 'Courier New', monospace;
    font-weight: 600;
    white-space: nowrap;
    pointer-events: none;
    opacity: 0;
    visibility: hidden;
    transition: all 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
    z-index: 1001;
  }

  .addr-tooltip::after {
    content: '';
    position: absolute;
    bottom: 100%; /* Arrow points up */
    left: 50%;
    transform: translateX(-50%);
    border: 6px solid transparent;
    border-bottom-color: var(--dark);
  }

  .addr-wrapper:hover .addr-tooltip {
    opacity: 1;
    visibility: visible;
    transform: translateX(-50%) translateY(0);
  }

  .wallet-info .net {
    font-weight: 700;
    font-size: 0.65rem;
    color: var(--secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .btn-add-chain {
    background: var(--primary);
    color: var(--dark);
    border: none;
    width: 28px;
    height: 28px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-add-chain:hover {
    transform: scale(1.1);
    box-shadow: 0 4px 10px var(--primary-glow);
  }

  .live-indicator {
    display: flex;
    align-items: center;
    background: rgba(34, 197, 94, 0.08);
    padding: 6px;
    border-radius: 50%;
  }

  .live-indicator .dot {
    width: 8px;
    height: 8px;
    background: #22c55e;
    border-radius: 50%;
    box-shadow: 0 0 8px rgba(34, 197, 94, 0.6);
    animation: live-pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }

  @keyframes live-pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.5; transform: scale(0.9); }
  }

  .btn-disconnect {
    background: none;
    border: none;
    color: var(--light-muted);
    cursor: pointer;
    padding: 8px;
    border-radius: 8px;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .btn-disconnect:hover {
    background: rgba(239, 68, 68, 0.05);
    color: #ef4444;
  }

  /* Replaced old classes */
  .navbar-brand, .navbar-actions, .header-container, .navbar-divider, .navbar-menu-custom, .navbar-item-custom {
    display: none;
  }

  /* ===== Hero Styles ===== */
  .hero-body {
    padding-bottom: 4rem;
    flex-grow: 1;
  }

  .faucet-header {
    margin-bottom: 2.5rem;
    padding: 0 1rem;
  }

  .faucet-title {
    font-size: 2.5rem;
    font-weight: 800;
    color: var(--dark);
    margin-bottom: 0.75rem;
    letter-spacing: -0.04em;
    line-height: 1.1;
  }

  .network-badge {
    color: var(--secondary);
    background: rgba(57, 188, 159, 0.08);
    padding: 0.15rem 1rem;
    border-radius: 100px;
    font-size: 0.85em;
    display: inline-block;
    vertical-align: middle;
    border: 1px solid rgba(57, 188, 159, 0.15);
  }

  .faucet-subtitle {
    font-size: 0.9rem;
    color: var(--secondary);
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    opacity: 0.85;
  }

  .description-container {
    max-width: 650px;
    margin: 0 auto;
    position: relative;
    padding: 0.75rem 1.5rem;
    background: rgba(255, 255, 255, 0.4);
    backdrop-filter: blur(8px);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.5);
  }

  .faucet-description {
    font-size: 0.95rem;
    color: var(--dark-muted);
    line-height: 1.6;
    font-weight: 500;
    margin: 0;
  }

  /* ===== Content Layout ===== */
  .desktop-columns {
    display: flex;
    gap: 4rem;
    align-items: flex-start;
  }

  .column.is-6 {
    flex: 1;
    width: 50%;
  }

  /* Left Column Cards */
  .how-it-works, .network-details, .token-box {
    background: var(--glass-bg);
    backdrop-filter: blur(10px);
    border: 1px solid var(--glass-border);
    border-radius: 24px;
    padding: 2rem;
    margin-bottom: 2rem;
    box-shadow: var(--card-shadow);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }

  .how-it-works:hover, .network-details:hover {
    transform: translateY(-5px);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.08);
  }

  .hiw-title, .nd-title, .token-box-title {
    font-size: 1rem;
    font-weight: 800;
    color: var(--dark);
    margin-bottom: 2rem;
    display: flex;
    align-items: center;
    gap: 12px;
    letter-spacing: -0.02em;
  }

  .hiw-title svg {
    color: var(--secondary);
  }

  .hiw-steps {
    display: flex;
    flex-direction: column;
    padding-left: 0.5rem;
  }

  .hiw-step {
    display: flex;
    gap: 1.5rem;
    min-height: 80px;
  }

  .step-visual {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 32px;
  }

  .step-icon-box {
    width: 32px;
    height: 32px;
    background: white;
    border: 2px solid #f0f0f5;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--light-muted);
    z-index: 1;
    transition: all 0.3s ease;
  }

  .step-icon-box.active {
    border-color: var(--secondary);
    color: var(--secondary);
    background: rgba(57, 188, 159, 0.05);
  }

  .hiw-step:hover .step-icon-box {
    border-color: var(--secondary);
    color: var(--secondary);
    transform: translateY(-2px);
  }

  .step-line {
    flex-grow: 1;
    width: 2px;
    background: #f0f0f5;
    margin: 4px 0;
  }


  .hiw-step:last-child .step-content {
    padding-bottom: 0;
  }

  .step-text {
    font-weight: 700;
    margin-bottom: 4px;
    font-size: 1rem;
    color: var(--dark);
  }

  .step-subtext {
    color: var(--dark-muted);
    font-size: 0.85rem;
    line-height: 1.5;
    max-width: 280px;
  }

  /* Network Parameters Section Redesign */
  .network-details {
    margin-bottom: 1.25rem !important;
    padding: 1.25rem !important;
    border-radius: 20px !important;
  }

  .is-highlighted-info {
    background: rgba(255, 255, 255, 0.45) !important;
    border: 1px solid rgba(57, 188, 159, 0.15) !important;
    box-shadow: 0 10px 30px rgba(57, 188, 159, 0.03);
  }

  .is-highlighted-warning {
    background: rgba(255, 255, 255, 0.5) !important;
    border: 1px solid rgba(243, 205, 82, 0.3) !important;
    box-shadow: 0 10px 30px rgba(243, 205, 82, 0.05);
  }

  .nd-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .nd-title-group {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .title-icon-box {
    width: 26px;
    height: 26px;
    background: white;
    border: 1px solid rgba(0,0,0,0.05);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--secondary);
    box-shadow: 0 2px 5px rgba(0,0,0,0.02);
  }

  .nd-title {
    font-size: 1rem !important;
    font-weight: 800 !important;
    color: var(--dark) !important;
    margin: 0 !important;
    letter-spacing: -0.01em;
  }

  .warning-badge {
    font-size: 0.65rem;
    font-weight: 800;
    background: #fff5eb;
    color: #f59e0b;
    padding: 2px 8px;
    border-radius: 100px;
    text-transform: uppercase;
    border: 1px solid rgba(245, 158, 11, 0.1);
  }

  .nd-grid-compact {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .nd-row-compact {
    display: flex;
    gap: 0.5rem;
  }

  .nd-cell {
    background: rgba(255, 255, 255, 0.6);
    padding: 0.6rem 0.9rem;
    border-radius: 12px;
    border: 1px solid rgba(0,0,0,0.03);
    flex: 1;
    transition: all 0.2s ease;
  }

  .nd-cell.full {
    width: 100%;
  }

  .nd-cell:hover {
    background: white;
    border-color: rgba(57, 188, 159, 0.12);
    box-shadow: 0 4px 12px rgba(0,0,0,0.02);
  }

  .cell-label {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2px;
  }

  .cell-label span {
    font-size: 0.6rem;
    font-weight: 800;
    color: var(--light-muted);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .cell-value {
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--dark);
    word-break: break-all;
  }

  .cell-value.mono {
    font-family: 'Courier New', monospace;
  }

  .cell-value.highlight {
    color: var(--secondary);
    font-size: 0.9rem;
  }

  .cell-value.link-style {
    color: var(--secondary);
    text-decoration: underline;
    text-underline-offset: 2px;
  }

  /* Asset Intelligence Section Refined */
  .token-box {
    margin-bottom: 0 !important;
    padding: 1.25rem !important;
    border-radius: 20px !important;
  }

  .token-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 0.75rem;
  }

  .token-logo-small {
    width: 14px;
    height: 14px;
    object-fit: contain;
  }

  .token-box-title {
    font-size: 1rem !important;
    font-weight: 800 !important;
    color: var(--dark) !important;
    margin: 0 !important;
    letter-spacing: -0.01em;
  }

  .token-desc-container {
    background: rgba(255, 255, 255, 0.4);
    padding: 0.6rem 0.9rem;
    border-radius: 12px;
    border: 1px solid rgba(0,0,0,0.03);
    margin-bottom: 0.5rem;
  }

  .token-box-desc {
    font-size: 0.85rem !important;
    color: var(--dark-muted) !important;
    line-height: 1.5 !important;
    margin: 0 !important;
  }

  .token-feature-grid-compact {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 0.5rem;
  }

  .feat-cell {
    background: rgba(255, 255, 255, 0.6);
    padding: 0.5rem 0.75rem;
    border-radius: 10px;
    border: 1px solid rgba(0,0,0,0.02);
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s ease;
  }

  .feat-cell:hover {
    background: white;
    border-color: rgba(57, 188, 159, 0.12);
    transform: translateY(-1px);
  }

  .feat-cell svg {
    color: var(--secondary);
    flex-shrink: 0;
  }

  .feat-cell span {
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--dark);
  }

  .token-logo-bg {
    display: none;
  }

  /* ===== Interaction Card (Right Column) ===== */
  .card {
    background: white;
    border-radius: 32px;
    padding: 2rem;
    box-shadow: 0 30px 60px rgba(0, 0, 0, 0.08);
    border: 1px solid rgba(0,0,0,0.02);
    position: relative;
    overflow: hidden;
  }

  .card::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    width: 150px;
    height: 150px;
    background: radial-gradient(circle at 100% 0%, var(--primary-glow) 0%, transparent 70%);
    pointer-events: none;
  }

  .card .subtitle {
    font-size: 0.85rem;
    color: var(--dark-muted);
    margin-bottom: 2rem;
    font-weight: 500;
    line-height: 1.5;
  }

  .input-wrapper {
    position: relative;
    margin-bottom: 2rem;
  }

  .input {
    width: 100%;
    background: #f8f9fb;
    border: 2px solid transparent;
    border-radius: 18px;
    font-size: 1rem;
    font-weight: 500;
    color: var(--dark);
    transition: all 0.3s ease;
    resize: none;
    overflow: hidden;
  }

  .input:focus {
    background: white;
    border-color: var(--primary);
    box-shadow: 0 0 0 4px var(--primary-glow);
    outline: none;
  }

  .button.is-primary {
    width: 100%;
    background: var(--primary);
    color: var(--dark);
    font-weight: 700;
    font-size: 1rem;
    padding: 1.1rem;
    border-radius: 18px;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: 0 10px 25px var(--primary-glow);
  }

  .button.is-primary:hover:not(:disabled) {
    transform: translateY(-3px);
    box-shadow: 0 15px 35px var(--primary-glow);
  }

  .button.is-primary:active:not(:disabled) {
    transform: translateY(0);
  }

  .button.is-primary:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    filter: grayscale(0.5);
  }

  /* ===== Status & Activity ===== */
  .tx-status-container {
    margin-top: 2rem;
    padding: 1.5rem;
    background: #f8f9fb;
    border-radius: 20px;
    border: 1px dashed #e0e4e9;
  }

  .status-phase {
    display: flex;
    align-items: center;
    gap: 1rem;
    font-weight: 600;
    color: var(--dark);
  }

  .status-phase.success {
    color: var(--secondary);
  }

  .status-phase.error {
    color: #ef4444;
  }

  .hash-display {
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 8px 0;
    font-family: 'Courier New', monospace;
    font-size: 0.9rem;
    color: var(--dark-muted);
  }

  .tx-hash-code {
    background: rgba(0,0,0,0.05);
    padding: 4px 8px;
    border-radius: 6px;
  }

  /* ===== Policy Info ===== */
  .rate-limit-policy {
    margin-top: 2.5rem;
    display: flex;
    gap: 2rem;
    justify-content: center;
    padding-top: 2rem;
    border-top: 1px solid #f0f0f5;
  }

  .policy-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--dark-muted);
  }

  .policy-icon {
    color: var(--secondary);
  }

  .disclaimer {
    margin-top: 2rem;
    font-size: 0.85rem;
    color: var(--light-muted);
    text-align: center;
    line-height: 1.5;
  }

  /* ===== Wallet Status Widget ===== */
  .nav-status-widget {
    background: #f8f9fb;
    padding: 0.4rem 1rem;
    border-radius: 14px;
    display: flex;
    align-items: center;
    gap: 12px;
    border: 1px solid rgba(0,0,0,0.02);
  }

  .nav-address {
    font-weight: 700;
    font-size: 0.85rem;
  }

  .nav-network {
    font-size: 0.75rem;
    font-weight: 700;
    color: var(--secondary);
    text-transform: uppercase;
  }

  /* ===== Mobile Nav Toggle ===== */
  .nav-mobile-toggle {
    display: none;
    justify-content: center;
    align-items: center;
  }

  .btn-hamburger {
    background: rgba(0, 0, 0, 0.05);
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--dark);
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-hamburger:hover {
    background: rgba(0, 0, 0, 0.08);
  }

  /* Mobile Menu Overlay */
  .mobile-menu-overlay {
    position: fixed;
    top: 5.5rem;
    left: 1rem;
    right: 1rem;
    z-index: 999;
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(20px) saturate(160%);
    -webkit-backdrop-filter: blur(20px) saturate(160%);
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.5);
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
    padding: 1rem;
    animation: menu-slide-down 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
  }

  @keyframes menu-slide-down {
    from { transform: translateY(-10px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
  }

  .mobile-nav-links {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .mobile-nav-link {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem 1.25rem;
    border-radius: 16px;
    color: var(--dark);
    font-weight: 700;
    font-size: 1rem;
    text-decoration: none;
    transition: all 0.2s;
  }

  .mobile-nav-link:hover {
    background: rgba(0, 0, 0, 0.04);
    color: var(--secondary);
  }

  .m-icon {
    font-size: 1.25rem;
    opacity: 0.8;
  }

  .blinking-dot {
    width: 8px;
    height: 8px;
    background: #22c55e;
    border-radius: 50%;
    box-shadow: 0 0 10px rgba(34, 197, 94, 0.5);
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0% { transform: scale(0.95); opacity: 0.8; }
    50% { transform: scale(1.05); opacity: 1; }
    100% { transform: scale(0.95); opacity: 0.8; }
  }

  /* ===== Balance Badge ===== */
  .balance-badge {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    background: rgba(31, 31, 55, 0.9);
    color: white;
    padding: 0.75rem 1.25rem;
    border-radius: 100px;
    font-weight: 700;
    font-size: 0.85rem;
    backdrop-filter: blur(8px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
    z-index: 1000;
  }

  /* ===== Mobile Responsive ===== */
  @media (max-width: 1024px) {
    .hero-body {
      padding-top: 2rem;
    }
    .desktop-columns {
      flex-direction: column;
      gap: 1.5rem;
    }
    .column.is-6 {
      width: 100%;
    }
    .faucet-title {
      font-size: 2.2rem;
    }
    .nav-glass-pill {
      padding: 0.6rem 1.25rem;
    }
  }

  @media (max-width: 768px) {
    .navbar {
      top: 0.5rem;
      padding: 0 0.75rem;
      margin-bottom: 2rem;
    }
    .nav-glass-pill {
      grid-template-columns: auto 1fr auto;
      padding: 0.5rem 1rem;
      border-radius: 18px;
    }
    .nav-center {
      display: none;
    }
    .nav-mobile-toggle {
      display: flex;
    }
    .nav-right {
      order: 3;
    }
    .nav-left {
      order: 1;
    }
    .nav-mobile-toggle {
      order: 2;
    }
    .brand-logo {
      height: 36px;
    }
    .faucet-title {
      font-size: 1.8rem;
    }
    .faucet-subtitle {
      font-size: 0.75rem;
    }
    .description-container {
      padding: 1rem;
    }
    .faucet-description {
      font-size: 0.85rem;
    }
    .card {
      padding: 1.5rem;
      border-radius: 24px;
    }
    .how-it-works, .network-details, .token-box {
      padding: 1.5rem;
    }
    .hiw-step {
      min-height: 60px;
    }
    .step-visual {
      width: 28px;
    }
    .step-icon-box {
      width: 28px;
      height: 28px;
    }
    .step-subtext {
      font-size: 0.8rem;
    }
    .nd-row-compact {
      flex-direction: column;
    }
    .balance-badge {
      bottom: 1rem;
      right: 1rem;
      padding: 0.5rem 1rem;
      font-size: 0.75rem;
    }
    .wallet-status {
      padding: 0.3rem 0.5rem 0.3rem 0.75rem;
    }
    .wallet-info .addr {
      font-size: 0.75rem;
    }
    .addr-tooltip {
      display: none;
    }
    .field.is-grouped {
      flex-direction: column;
      gap: 1rem;
    }
    .buttons-group .button {
      width: 100%;
    }
    .rate-limit-policy {
      flex-direction: column;
      gap: 1rem;
      align-items: flex-start;
      padding: 1.5rem 0.5rem 0;
    }
  }

  @media (max-width: 480px) {
    .faucet-title {
      font-size: 1.5rem;
    }
    .token-feature-grid-compact {
      grid-template-columns: 1fr;
    }
    .nav-glass-pill {
      padding: 0.5rem 0.75rem;
    }
    .wallet-info .net {
      display: none;
    }
  }

  /* Utility classes */
  .spinner {
    width: 20px;
    height: 20px;
    border: 3px solid rgba(57, 188, 159, 0.2);
    border-top: 3px solid var(--secondary);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .nav-add-icon-btn {
    background: var(--primary);
    border: none;
    width: 28px;
    height: 28px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
  }

  .nav-add-icon-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 5px 15px var(--primary-glow);
  }

  .disconnect-icon-btn {
    background: none;
    border: none;
    color: var(--light-muted);
    cursor: pointer;
    padding: 4px;
    transition: color 0.2s;
  }

  .disconnect-icon-btn:hover {
    color: #ef4444;
  }
</style>
