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
    network: 'testnet',
    payout: 1000000000,
    symbol: 'ETH',
    balance: '0',
    hcaptcha_sitekey: '',
    logo_url: '/logo.svg',
    background_url: 'background.jpg',
    frontend_type: 'redesign',
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

  onMount(async () => {
    const res = await fetch('/api/info');
    console.log('Faucet Info Response:', res);
    faucetInfo = await res.json();
    console.log('Parsed Faucet Info:', faucetInfo);
    mounted = true;
  });

  window.hcaptchaOnLoad = () => {
    hcaptchaLoaded = true;
  };

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

  async function connectWallet() {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        input = accounts[0];
        toast({ message: 'Wallet Connected', type: 'is-success' });
      } catch (error) {
        toast({ message: error.message || 'Connection failed', type: 'is-warning' });
      }
    } else {
      toast({ message: 'MetaMask not found. Please install it to connect.', type: 'is-warning' });
    }
  }

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

      let { msg } = await res.json();
      let ok = res.ok;
      let type = ok ? 'is-success' : 'is-warning';
      if (!silenceToast) toast({ message: msg, type });
      return { ok, msg };
    } catch (err) {
      console.error(err);
      return { ok: false, msg: err.message };
    }
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
  <Redesign {faucetInfo} {input} {handleRequest} {gweiToEth} {connectWallet} />
{/if}
