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
    textarea.style.borderRadius = '12px'
  }
</script>

<main>
  <section
    class="hero  is-fullheight faucet-bg"
  >
     <nav class="navbar">
  <div class="header-container">
    <div class="navbar-brand">
      <a  href="https://gateway.fm/">
        <span class="icon icon-brand">
          <img src={faucetInfo.logo_url} alt="logo"/>
        </span>
      </a>
    </div>
  </div>
</nav>


    <div class="hero-body">
      <div class="container has-text-centered">
        <div class="column is-7 is-offset-3 centered-column">
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
                <div>Enter Your Address</div>
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

/* ===== BIG Gradient Circles Background ===== */
.faucet-bg {
  position: relative;
  overflow: hidden;
  background-color: #ffffff;
}

.faucet-bg::before,
.faucet-bg::after {
  content: "";
  position: absolute;
  width: 900px;
  height: 900px;
  border-radius: 50%;
  z-index: 0;
  pointer-events: none;
}

/* Top Right – LARGE */
.faucet-bg::before {
  top: -420px;
  right: -420px;
  background: radial-gradient(
    circle,
    rgba(57, 188, 159, 0.45) 0%,
    rgba(57, 188, 159, 0.22) 45%,
    rgba(57, 188, 159, 0) 75%
  );
}

/* Bottom Left – LARGE */
.faucet-bg::after {
  bottom: -460px;
  left: -460px;
  background: radial-gradient(
    circle,
    rgba(57, 188, 159, 0.45) 0%,
    rgba(57, 188, 159, 0.22) 45%,
    rgba(57, 188, 159, 0) 75%
  );
}

/* Keep content above gradients */
.faucet-bg > * {
  position: relative;
  z-index: 1;
}

/* Mobile tuning */
@media (max-width: 768px) {
  .faucet-bg::before,
  .faucet-bg::after {
    width: 620px;
    height: 620px;
  }

  .faucet-bg::before {
    top: -300px;
    right: -300px;
  }

  .faucet-bg::after {
    bottom: -320px;
    left: -320px;
  }
}


.navbar {
  justify-content: center;
}

.header-container {
  display: flex;
  justify-content: center;
  width: 100%;
}

.navbar-brand {
  margin: 0 auto;
}
  .deploy-btn-mobile {
    display: none;
  }
  .input {
    resize: none;
    overflow: hidden;
    background: #F7F7F7;
    color: black
    border-radius: 12px !important;
    min-height: 42px;
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
    background-color: #F3CD52;
    gap: 16px;
    border-radius: 12px !important;
    color: black;
    min-height: 56px;
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
    background-color: #F7F7F7;
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
    min-width: 638px;
    max-width: 638px;
    gap: 6px;
    box-shadow: 0px 0px 16px rgba(0, 0, 0, 0.1);
    border-radius: 16px;
    padding: 32px;
  }

  .title {
    display: inline-flex;
    color: #1F1F37;
    gap: 8px;
    font-weight: 500;
    font-size: 44px; /* Adjust size as needed */
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
    align-items: flex-end;
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
    width: 243px;
    height: 62px;
  }

  .icon-brand {
    width: auto;
    height: 62px;
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