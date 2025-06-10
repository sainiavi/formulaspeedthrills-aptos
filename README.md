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


# Gaming Leaderboard Smart Contracts

This repository contains two Move smart contracts designed for managing gaming leaderboards and top player rankings on the Aptos blockchain.

## Overview

### 1. Leaderboard Contract (`leaderboard::leaderboard`)
A comprehensive leaderboard management system that tracks player scores with historical data preservation.

### 2. Top Players Contract (`top_players`)
A badge-based system for managing the top 3 players with Gold, Silver, and Bronze designations.

---

## Contract 1: Leaderboard System

### Purpose
The Leaderboard contract provides a robust system for managing game rankings with up to 10 players, complete with historical tracking and comprehensive query capabilities.

### Key Features
- **Fixed Size Leaderboard**: Maintains exactly 10 player entries
- **Historical Preservation**: Automatically saves previous leaderboard states before updates
- **Comprehensive Queries**: Multiple view functions for retrieving current and historical data
- **Timestamp Tracking**: Records when leaderboards were last updated
- **Update Counting**: Tracks the number of leaderboard updates

### Data Structures

#### LeaderboardEntry
```move
struct LeaderboardEntry {
    user_address: address,  // Player's blockchain address
    score: u64,            // Player's score
}
```

#### Leaderboard (Main Resource)
```move
struct Leaderboard {
    entries: vector<LeaderboardEntry>,  // Current top 10 players
    last_updated: u64,                  // Timestamp of last update
    update_count: u64,                  // Number of updates performed
}
```

#### Historical Tracking
```move
struct LeaderboardHistory {
    historical_boards: vector<HistoricalBoard>,  // Past leaderboard states
}

struct HistoricalBoard {
    entries: vector<LeaderboardEntry>,  // Historical player data
    timestamp: u64,                     // When this board was active
    update_number: u64,                 // Update sequence number
}
```

### Functions

#### Administrative Functions
- **`initialize(account: &signer)`**
  - Sets up the leaderboard system for the account
  - Creates empty leaderboard and history tracking
  - Can only be called once per account

- **`upload_leaderboard(account: &signer, addresses: vector<address>, scores: vector<u64>)`**
  - Updates the leaderboard with new data
  - Requires exactly 10 addresses and 10 corresponding scores
  - Automatically saves current leaderboard to history before updating

#### View Functions
- **`get_current_leaderboard(leaderboard_owner: address)`**
  - Returns: `(addresses, scores, last_updated, update_count)`
  - Retrieves complete current leaderboard data

- **`get_user_score(leaderboard_owner: address, user_addr: address)`**
  - Returns: `u64` (score or 0 if not found)
  - Gets specific user's current score

- **`get_user_rank(leaderboard_owner: address, user_addr: address)`**
  - Returns: `u64` (1-indexed rank or 0 if not found)
  - Gets user's position in current leaderboard

- **`get_history_count(leaderboard_owner: address)`**
  - Returns: `u64`
  - Number of historical leaderboard snapshots

- **`get_historical_leaderboard(leaderboard_owner: address, index: u64)`**
  - Returns: `(addresses, scores, timestamp, update_number)`
  - Retrieves specific historical leaderboard by index

### Error Codes
- `E_INVALID_LEADERBOARD_SIZE (1)`: Input vectors don't match required size of 10
- `E_LEADERBOARD_NOT_FOUND (2)`: Leaderboard resource doesn't exist

---

## Contract 2: Top Players Badge System

### Purpose
The Top Players contract manages a simple but effective system for recognizing the top 3 performers with a badge-based hierarchy.

### Key Features
- **Three-Tier System**: Gold, Silver, and Bronze player designations
- **Admin-Controlled**: Only the admin can update player positions
- **Flexible Updates**: Update all players at once or individually
- **Badge Constants**: Predefined badge types for consistency

### Data Structures

#### Player
```move
struct Player {
    player_address: address,  // Player's blockchain address
    badge: u8,               // Badge type (1=Gold, 2=Silver, 3=Bronze)
}
```

#### TopPlayersBoard (Main Resource)
```move
struct TopPlayersBoard {
    admin: address,          // Admin who can update the board
    gold_player: Player,     // 1st place player
    silver_player: Player,   // 2nd place player
    bronze_player: Player,   // 3rd place player
}
```

### Badge Types
- **GOLD_BADGE (1)**: First place
- **SILVER_BADGE (2)**: Second place  
- **BRONZE_BADGE (3)**: Third place

### Functions

#### Administrative Functions
- **`initialize(admin: &signer, initial_gold: address, initial_silver: address, initial_bronze: address)`**
  - Sets up the top players board with initial winners
  - Can only be called once per admin account

- **`update_top_players(admin: &signer, new_gold: address, new_silver: address, new_bronze: address)`**
  - Updates all three top players simultaneously
  - Admin-only function

- **`update_player(admin: &signer, badge_type: u8, new_player: address)`**
  - Updates a single player by badge type
  - More granular control for individual updates
  - Admin-only function

#### View Functions
- **`get_all_players(admin_addr: address)`**
  - Returns: `(gold_address, silver_address, bronze_address)`
  - Gets all three top players at once

- **`get_gold_player(admin_addr: address)`**
  - Returns: `address`
  - Gets the gold badge holder

- **`get_silver_player(admin_addr: address)`**
  - Returns: `address`
  - Gets the silver badge holder

- **`get_bronze_player(admin_addr: address)`**
  - Returns: `address`
  - Gets the bronze badge holder

- **`get_player_by_badge(admin_addr: address, badge_type: u8)`**
  - Returns: `address`
  - Gets player by specific badge type

- **`is_initialized(admin_addr: address)`**
  - Returns: `bool`
  - Checks if the system has been set up

- **`get_admin(admin_addr: address)`**
  - Returns: `address`
  - Gets the admin address

### Error Codes
- `E_NOT_ADMIN (1)`: Caller is not the authorized admin
- `E_ALREADY_INITIALIZED (2)`: Contract already initialized
- `E_NOT_INITIALIZED (3)`: Contract not yet initialized

---

## Usage Examples

### Leaderboard Contract Usage

```move
// Initialize the leaderboard
leaderboard::initialize(admin_account);

// Upload new leaderboard data
let addresses = vector[0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa];
let scores = vector[1000, 950, 900, 850, 800, 750, 700, 650, 600, 550];
leaderboard::upload_leaderboard(admin_account, addresses, scores);

// Query current leaderboard
let (current_addresses, current_scores, last_update, update_count) = 
    leaderboard::get_current_leaderboard(admin_address);

// Get specific user's rank
let user_rank = leaderboard::get_user_rank(admin_address, user_address);
```

# Top Players Prize Contract

A Move smart contract on Aptos that manages a top 3 leaderboard with automatic APT coin rewards for Gold, Silver, and Bronze players.

## 🏆 Features

- **Top 3 Leaderboard**: Tracks Gold, Silver, and Bronze players
- **Automatic Rewards**: Distributes APT coins when updating leaderboard
- **Admin Controls**: Only contract admin can update players and manage funds
- **Safe Distribution**: Checks account registration before sending rewards
- **Flexible Updates**: Option to update players with or without rewards
- **Fund Management**: Deposit and withdraw capabilities for reward pool

## 💰 Reward Structure

| Position | Badge Type | Reward Amount |
|----------|------------|---------------|
| 🥇 Gold  | 1          | 0.5 APT       |
| 🥈 Silver| 2          | 0.3 APT       |
| 🥉 Bronze| 3          | 0.2 APT       |
| **Total**|            | **1.0 APT**   |


**Made with ❤️ for Aptos Web3 community**
