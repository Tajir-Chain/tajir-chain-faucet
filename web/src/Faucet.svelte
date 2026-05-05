<script>
  // @ts-nocheck

  import { onMount } from 'svelte';
  import { getAddress } from '@ethersproject/address';
  import { CloudflareProvider } from '@ethersproject/providers';
  import { setDefaults as setToast, toast } from 'bulma-toast';

  import BaseDesign from './components/BaseDesign.svelte';
  import Redesign from './components/Redesign.svelte';

  let input = null;

  let faucetInfo = {
    account: '0x0000000000000000000000000000000000000000',
    network: 'Devnet',
    chain_id: '21519080',
    rpc_url: 'https://rpc.devnet.tajirchain.com',
    payout: 1000000000,
    symbol: 'tTJR',
    balance: '0',
    hcaptcha_sitekey: '',
    logo_url: '/logo.svg',
    background_url: 'background.jpg',
    frontend_type: 'redesign',
    public_rpc_url: 'https://rpc.devnet.tajirchain.com',
    paid_customer: false,
    bridge_url: 'https://bridge.devnet.tajirchain.com/',
    explorer_url: 'https://explorer.devnet.tajirchain.com/',
    website_url: 'https://www.tajirchain.com/',
    twitter_url: 'https://x.com/tajirchain?s=21',
    interval: 2
  };

  let mounted = false;
  let hcaptchaLoaded = false;

  function gweiToEth(gwei) {
    let str = gwei.toString();
    let len = str.length;

    // Add leading zeros if necessary
    if (len <= 9) {
      str = '0'.repeat(9 - len) + str;
      len = str.length;
    }

    // Insert decimal point
    str = str.slice(0, len - 9) + '.' + str.slice(len - 9);

    // Add leading zero if necessary
    if (str.startsWith('.')) {
      str = '0' + str;
    }

    // Remove trailing zeros
    str = str.replace(/0+$/, '');

    // Remove trailing decimal point
    if (str.endsWith('.')) {
      str = str.slice(0, -1);
    }

    return str;
  }

  let userBalance = null;
  let isWrongNetwork = false;
  let showWalletModal = false;
  let currentProvider = null;

  async function getProvider(type) {
    if (!window.ethereum && !window.phantom?.ethereum) return null;

    if (type === 'metamask') {
      // If multiple providers exist, look for MetaMask specifically
      if (window.ethereum?.providers?.length) {
        return window.ethereum.providers.find(p => p.isMetaMask && !p.isPhantom) || 
               window.ethereum.providers.find(p => p.isMetaMask);
      }
      
      // If window.ethereum is Phantom, and there's no other provider, 
      // then MetaMask is either not installed or not exposed.
      if (window.ethereum?.isPhantom && !window.ethereum?.isMetaMask) return null;
      if (window.ethereum?.isPhantom && window.ethereum?.isMetaMask) {
        // This is Phantom in compatibility mode. If we want REAL MetaMask, this isn't it.
        // But we check if there are other providers.
        return null; 
      }

      return window.ethereum?.isMetaMask ? window.ethereum : null;
    }
    
    if (type === 'phantom') {
      return window.phantom?.ethereum || (window.ethereum?.isPhantom ? window.ethereum : null);
    }
    
    return window.ethereum;
  }

  async function checkNetwork(provider = currentProvider || window.ethereum) {
    if (provider) {
      try {
        const chainId = await provider.request({ method: 'eth_chainId' });
        isWrongNetwork = parseInt(chainId, 16).toString() !== faucetInfo.chain_id;
        return !isWrongNetwork;
      } catch (e) {
        console.error("Failed to get chainId", e);
      }
    }
    return false;
  }

  async function addNetwork(provider = currentProvider || window.ethereum) {
    if (!provider) return;
    const chainIdHex = '0x' + Number(faucetInfo.chain_id).toString(16);
    try {
      await provider.request({
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
      return await checkNetwork(provider);
    } catch (error) {
      console.error("Failed to add network", error);
      return false;
    }
  }

  async function fetchUserBalance(address, provider = currentProvider || window.ethereum) {
    if (provider && address) {
      try {
        const balance = await provider.request({
          method: 'eth_getBalance',
          params: [address, 'latest']
        });
        const wei = BigInt(balance);
        const eth = Number(wei) / 1e18;
        userBalance = eth.toFixed(4);
      } catch (e) {
        console.error("Failed to fetch balance", e);
      }
    }
  }

  async function connectWallet(type) {
    const provider = await getProvider(type);
    if (provider) {
      currentProvider = provider;
      try {
        const isCorrectNetwork = await checkNetwork(provider);
        if (!isCorrectNetwork) {
          const added = await addNetwork(provider);
          if (!added) {
            toast({ message: 'Please switch to the correct network', type: 'is-warning' });
            return;
          }
        }

        const accounts = await provider.request({ method: 'eth_requestAccounts' });
        input = accounts[0];
        await fetchUserBalance(input, provider);
        toast({ message: 'Wallet Connected', type: 'is-success' });
        showWalletModal = false;
      } catch (error) {
        toast({ message: error.message || 'Connection failed', type: 'is-warning' });
      }
    } else {
      const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
      if (isMobile) {
        const dappUrl = window.location.href.replace(/^https?:\/\//, '');
        const metamaskAppDeepLink = `https://metamask.app.link/dapp/${dappUrl}`;
        window.open(metamaskAppDeepLink, '_blank');
      } else {
        toast({ message: `${capitalize(type || 'Wallet')} not found. Please install it to connect.`, type: 'is-warning' });
      }
    }
  }

  function openWalletModal() {
    showWalletModal = true;
  }


  onMount(async () => {
    try {
      const res = await fetch('/api/info');
      if (res.ok) {
        try {
          const data = await res.json();
          faucetInfo = { ...faucetInfo, ...data };
        } catch (jsonErr) {
          console.error('Failed to parse info JSON:', jsonErr);
        }
      } else {
        console.error('Info API returned status:', res.status);
      }
    } catch (fetchErr) {
      console.error('Failed to fetch info:', fetchErr);
    } finally {
      mounted = true;
      if (window.ethereum) {
        checkNetwork();
        window.ethereum.on('chainChanged', () => {
          checkNetwork();
          if (input) fetchUserBalance(input);
        });
        window.ethereum.on('accountsChanged', (accounts) => {
          if (accounts.length > 0) {
            input = accounts[0];
            fetchUserBalance(input);
          } else {
            input = null;
            userBalance = null;
          }
        });
      }
    }
  });

  window.hcaptchaOnLoad = () => {
    hcaptchaLoaded = true;
  };

  $: baseFrontendType = faucetInfo.frontend_type === 'base';
  $: redesignFrontendType = faucetInfo.frontend_type === 'redesign';

  let widgetID;
  $: if (mounted && hcaptchaLoaded) {
    widgetID = window.hcaptcha.render('hcaptcha', {
      sitekey: faucetInfo.hcaptcha_sitekey,
    });
  }

  setToast({
    message: '',
    position: 'bottom-center',
    dismissible: true,
    pauseOnHover: true,
    closeOnClick: false,
    animate: { in: 'fadeIn', out: 'fadeOut' },
  });

  async function handleRequest(input, silenceToast = false) {
    let address = input;
    if (address === null) {
      if (!silenceToast) toast({ message: 'input required', type: 'is-warning' });
      return { ok: false, msg: 'input required' };
    }
    if (address.endsWith('.eth')) {
      try {
        const provider = new CloudflareProvider();
        address = await provider.resolveName(address);
        if (!address) {
          if (!silenceToast) toast({ message: 'invalid ENS name', type: 'is-warning' });
          return { ok: false, msg: 'invalid ENS name' };
        }
      } catch (error) {
        if (!silenceToast) toast({ message: error.reason, type: 'is-warning' });
        return { ok: false, msg: error.reason };
      }
    }

    try {
      address = getAddress(address);
    } catch (error) {
      if (!silenceToast) toast({ message: error.reason, type: 'is-warning' });
      return { ok: false, msg: error.reason };
    }

    try {
      let headers = {
        'Content-Type': 'application/json',
      };

      if (hcaptchaLoaded) {
        const { response } = await window.hcaptcha.execute(widgetID, {
          async: true,
        });
        headers['h-captcha-response'] = response;
      }

      const res = await fetch('/api/claim', {
        method: 'POST',
        headers,
        body: JSON.stringify({
          address,
        }),
      });

      let msg = '';
      let ok = res.ok;
      
      try {
        const data = await res.json();
        msg = data.msg || (ok ? 'Success' : 'Request failed');
      } catch (e) {
        msg = ok ? 'Success (no detail)' : 'Error: Server returned invalid response';
      }

      let type = ok ? 'is-success' : 'is-warning';
      if (!silenceToast) toast({ message: msg, type });
      if (ok && input) fetchUserBalance(input);
      return { ok, msg };
    } catch (err) {
      console.error(err);
      return { ok: false, msg: err.message };
    }
  }
  function disconnectWallet() {
    input = null;
    toast({ message: 'Wallet Disconnected', type: 'is-success' });
  }
  function capitalize(str) {
    const lower = str.toLowerCase();
    return str.charAt(0).toUpperCase() + lower.slice(1);
  }
</script>

<svelte:head>
  {#if mounted && faucetInfo.hcaptcha_sitekey}
    <script
      src="https://hcaptcha.com/1/api.js?onload=hcaptchaOnLoad&render=explicit"
      async
      defer
    ></script>
  {/if}
</svelte:head>

{#if baseFrontendType}
  <BaseDesign {faucetInfo} {input} {handleRequest} {gweiToEth} />
{:else if redesignFrontendType}
  <Redesign 
    {faucetInfo} 
    {input} 
    {handleRequest} 
    {gweiToEth} 
    {connectWallet} 
    {disconnectWallet} 
    {userBalance} 
    {isWrongNetwork} 
    {addNetwork} 
    bind:showWalletModal
    {openWalletModal}
  />
{/if}
