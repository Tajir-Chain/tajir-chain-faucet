<script>
  import CopyButton from './CopyButton.svelte';
  import Navigation from './Navigation.svelte';
  import networkIcon from './../assets/networkIcon.svg';
  import arrowRight from './../assets/arrowRight.svg';
  import logo from './../assets/logo.svg';

  export let faucetInfo;
  export let input;
  export let handleRequest;
  export let gweiToEth;


  const openMessageWindow = (subject, email) => {
    const emailSupport = 'support+presto@gateway.fm';
    const mailtoLink = `mailto:${emailSupport}?subject=${encodeURIComponent(subject)}`;

    window.location.href = mailtoLink;
  };

  function autoResize(event) {
    const textarea = event.target;
    textarea.style.height = 'auto'; // Reset height
    textarea.style.height = `${textarea.scrollHeight}px`; // Set new height
  }
</script>

<main>
  <section
    class="hero is-info is-fullheight"
    style="background-image: url({faucetInfo.background_url})"
  >
    <div class="hero-head">
      <nav class="navbar">
        <div class="header-container">
          <div class="navbar-brand">
            <a class="navbar-item" href="https://gateway.fm/">
              <span class="icon icon-brand">
                <img src={faucetInfo.logo_url} alt="logo" />
              </span>
            </a>
            <div class="navbar-desktop">
             sssssssssssssssssss
            </div>
          </div>
        </div>
      </nav>
    </div>

    <div class="hero-body">
      <div class="container has-text-centered">
        <div class="column is-7 is-offset-3 centered-column">
          <div class="network">
            <img src={networkIcon} alt="logo" />
            <div>{faucetInfo.network}</div>
          </div>
          <div class="title">
            Receive <div class="gas-token">
              {gweiToEth(faucetInfo.payout)}
              {faucetInfo.symbol}
            </div>
          </div>
          <div id="hcaptcha" data-size="invisible"></div>
          <div class="card">
            <div>
              <div class="subtitle">
                <div>Serving from</div>
                <div class="address-from">
                  {faucetInfo.account}
                  <CopyButton text={faucetInfo.account} />
                </div>
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
              <div class="control">
                <button
                  on:click={() => handleRequest(input)}
                  class="button is-primary is-rounded"
                >
                  Request
                </button>
              </div>
            </div>
          </div>
          
        </div>
      </div>
    </div>
  </section>
</main>

<style>
  .deploy-btn-mobile {
    display: none;
  }
  .input {
    resize: none;
    overflow: hidden;
  }
  .header-container {
    display: flex;
    width: 100%;
    padding-inline: 16px;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
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
    background-color: #f3cd52;
    gap: 16px;
  }

  .button:hover {
    opacity: 0.8;
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
    background-color: #39bc9f42;
    color: #6a6a6a;
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
    min-width: 100%;
    gap: 24px;
    box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.1);
    border-radius: 19px;
    padding: 32px;
    color: #161718;
  }

  .title {
    display: inline-flex;
    color: #161718;
    gap: 8px;
    font-weight: 500;
    font-size: 72px; /* Adjust size as needed */
    line-height: 80px;
    letter-spacing: 0px;
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
  .hero.is-info .title {
    color: #000;
  }

  .subtitle {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    letter-spacing: 0px;
    color: #161718;
  }

  .navbar-mobile {
    display: none;
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
    width: 16px;
    height: 16px;
  }

  .icon-brand {
    width: auto;
    height: 40px;
  }

  .icon-brand img {
    height: 100%;
    width: auto;
  }

  @media (max-width: 992px) {
    .subtitle {
      font-size: 12px;
    }

    .navbar-mobile {
      display: block;
    }
  }

  @media (max-width: 768px) {
    .subtitle {
      flex-direction: column;
      font-size: 16px;
      gap: 8px;
    }

    .title {
      font-size: 38px;
      line-height: 56px;
    }
    .navbar-desktop {
      display: none;
    }

    .hero-body {
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding: 1rem 1.5rem;
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
</style>
