// === Unity Wallet Integration for WebGL ===

let unityInstance = null;

// Called by Unity loader to assign the Unity instance
function setUnityInstance(instance) {
  unityInstance = instance;
  console.log("✅ Unity instance assigned.");
}

function waitForUnityAndThen(callback) {
  if (unityInstance && typeof unityInstance.SendMessage === "function") {
    callback();
  } else {
    setTimeout(() => waitForUnityAndThen(callback), 100);
  }
}

// Helper to connect any wallet
async function connectWallet(provider, walletName) {
  try {
    const response = await provider.connect();
    const address = response.address || response.publicKey || response.account?.address;

    waitForUnityAndThen(() => {
      unityInstance.SendMessage("StartGameManager", "OnWalletConnected", address);
    });
  } catch (err) {
    waitForUnityAndThen(() => {
      unityInstance.SendMessage("StartGameManager", "OnWalletConnectFailed", walletName + " connect error: " + err.message);
    });
  }
}

// ==== Individual Wallet Injected Functions ====

window.connectPetraInjected = function () {
  const provider = window.aptos;
  connectWallet(provider, "Petra");
};

window.connectMartianInjected = function () {
  const provider = window.martian;
  connectWallet(provider, "Martian");
};

window.connectPontemInjected = function () {
  const provider = window.pontem;
  connectWallet(provider, "Pontem");
};

window.connectRiseInjected = function () {
  const provider = window.rise;
  connectWallet(provider, "Rise");
};

window.connectFewchaInjected = function () {
  const provider = window.fewcha;
  connectWallet(provider, "Fewcha");
};
