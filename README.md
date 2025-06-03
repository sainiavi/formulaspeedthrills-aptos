# formulaspeedthrills-aptos


# Unity Wallet Integration for WebGL

[![Unity](https://img.shields.io/badge/Unity-2020.3+-black.svg)](https://unity3d.com/)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-yellow.svg)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![WebGL](https://img.shields.io/badge/WebGL-Compatible-green.svg)](https://www.khronos.org/webgl/)

A JavaScript bridge that enables Unity WebGL applications to seamlessly connect with popular Web3 wallet providers including Petra, Martian, Pontem, Rise, and Fewcha wallets.

## 🚀 Features

- ✅ **Multi-Wallet Support** - Works with 5 major wallet providers
- ✅ **Unity WebGL Integration** - Direct communication with Unity
- ✅ **Error Handling** - Comprehensive error management
- ✅ **Async Support** - Non-blocking wallet connections
- ✅ **Easy Integration** - Minimal setup required

## 🎯 Supported Wallets

| Wallet | Provider | Status |
|--------|----------|--------|
| [Petra](https://petra.app/) | `window.aptos` | ✅ |
| [Martian](https://martianwallet.xyz/) | `window.martian` | ✅ |
| [Pontem](https://pontem.network/) | `window.pontem` | ✅ |
| [Rise](https://risewallet.io/) | `window.rise` | ✅ |
| [Fewcha](https://fewcha.app/) | `window.fewcha` | ✅ |

## 📦 Installation

### 1. Download the Script

Copy the wallet integration JavaScript code into your WebGL project folder.

### 2. Include in HTML

Add the script to your Unity WebGL HTML template:

```html
<script src="wallet-integration.js"></script>
```

### 3. Unity Setup

Create a GameObject named `StartGameManager` with the wallet event handlers:

```csharp
using UnityEngine;

public class StartGameManager : MonoBehaviour
{
    public void OnWalletConnected(string address)
    {
        Debug.Log($"✅ Wallet connected: {address}");
        // Handle successful connection
    }

    public void OnWalletConnectFailed(string errorMessage)
    {
        Debug.LogError($"❌ Connection failed: {errorMessage}");
        // Handle connection failure
    }
}
```

## 🔧 Quick Start

### Initialize Unity Instance

After your Unity WebGL application loads:

```javascript
createUnityInstance(canvas, config).then((unityInstance) => {
    // Set the Unity instance for wallet communication
    setUnityInstance(unityInstance);
    console.log("Unity ready for wallet connections!");
});
```

### Connect a Wallet

From Unity C#:
```csharp
// Trigger wallet connection from Unity
Application.ExternalCall("connectPetraInjected");
```

From JavaScript:
```javascript
// Connect from web page
window.connectPetraInjected();
```

From HTML:
```html
<button onclick="connectPetraInjected()">Connect Petra</button>
<button onclick="connectMartianInjected()">Connect Martian</button>
```

## 📖 API Reference

### Core Functions

#### `setUnityInstance(instance)`
Assigns the Unity WebGL instance for communication.

```javascript
setUnityInstance(unityInstance);
```

#### Available Wallet Connectors

| Function | Wallet | Usage |
|----------|--------|-------|
| `connectPetraInjected()` | Petra | `window.connectPetraInjected()` |
| `connectMartianInjected()` | Martian | `window.connectMartianInjected()` |
| `connectPontemInjected()` | Pontem | `window.connectPontemInjected()` |
| `connectRiseInjected()` | Rise | `window.connectRiseInjected()` |
| `connectFewchaInjected()` | Fewcha | `window.connectFewchaInjected()` |

### Unity Events

Your `StartGameManager` will receive these callbacks:

- `OnWalletConnected(string address)` - Successful connection
- `OnWalletConnectFailed(string error)` - Connection failure

## 🔄 Connection Flow

```mermaid
graph TD
    A[User clicks connect] --> B[Check wallet availability]
    B --> C{Wallet installed?}
    C -->|Yes| D[Call wallet.connect()]
    C -->|No| E[Send error to Unity]
    D --> F{Connection successful?}
    F -->|Yes| G[Extract address]
    F -->|No| H[Send error to Unity]
    G --> I[Send address to Unity]
    H --> J[Display error message]
    I --> K[Update game state]
```

## 🛠️ Advanced Usage

### Check Wallet Availability

```javascript
function checkWalletAvailability() {
    const wallets = {
        petra: !!window.aptos,
        martian: !!window.martian,
        pontem: !!window.pontem,
        rise: !!window.rise,
        fewcha: !!window.fewcha
    };
    
    console.log('Available wallets:', wallets);
    return wallets;
}
```

### Custom Error Handling

```csharp
public void OnWalletConnectFailed(string errorMessage)
{
    if (errorMessage.Contains("User rejected"))
    {
        ShowMessage("Connection cancelled by user");
    }
    else if (errorMessage.Contains("not installed"))
    {
        ShowMessage("Please install the wallet extension");
    }
    else
    {
        ShowMessage("Connection failed. Please try again.");
    }
}
```

### Wallet State Management

```csharp
public enum WalletState
{
    Disconnected,
    Connecting,
    Connected,
    Failed
}

public class WalletManager : MonoBehaviour
{
    public WalletState currentState = WalletState.Disconnected;
    
    public void ConnectWallet(string walletType)
    {
        currentState = WalletState.Connecting;
        Application.ExternalCall($"connect{walletType}Injected");
    }
}
```

## 🐛 Troubleshooting

### Common Issues

**Problem**: Unity instance not found
```
Solution: Ensure setUnityInstance() is called after Unity loads
```

**Problem**: Wallet provider undefined
```
Solution: Check if wallet extension is installed and enabled
```

**Problem**: SendMessage fails
```
Solution: Verify GameObject "StartGameManager" exists with required methods
```

### Debug Mode

Enable debug logging:

```javascript
// Add to your integration for debugging
function debugWalletConnection(walletName) {
    console.log(`🔍 Attempting to connect ${walletName}`);
    console.log('Unity instance:', unityInstance);
    console.log(`${walletName} provider:`, window[walletName.toLowerCase()]);
}
```

## 🔒 Security Best Practices

- ✅ Never store private keys or seed phrases
- ✅ Always validate addresses received from wallets
- ✅ Use HTTPS in production
- ✅ Implement proper error boundaries
- ✅ Validate user inputs

## 🌐 Browser Compatibility

| Browser | Support | Notes |
|---------|---------|-------|
| Chrome | ✅ Full | Recommended |
| Firefox | ✅ Full | All features work |
| Safari | ⚠️ Limited | Depends on wallet extensions |
| Mobile | ⚠️ Limited | Limited wallet extension support |

## 🤝 Contributing

Want to add support for more wallets? Here's how:

1. **Fork the repository**
2. **Add wallet support:**

```javascript
window.connectNewWalletInjected = function () {
    const provider = window.newWallet;
    connectWallet(provider, "NewWallet");
};
```

3. **Update the README** with the new wallet
4. **Submit a pull request**

### Adding New Wallets

Follow this pattern:

```javascript
// 1. Check the wallet's documentation for provider object
// 2. Add connection function
window.connectYourWalletInjected = function () {
    const provider = window.yourWallet; // Provider object
    connectWallet(provider, "YourWallet"); // Display name
};
```


**Made with ❤️ for Aptos Web3 community**