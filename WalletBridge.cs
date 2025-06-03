using System.Runtime.InteropServices;
using UnityEngine;

public class WalletBridge : MonoBehaviour
{
#if UNITY_WEBGL && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void connectAptosWallet();

    [DllImport("__Internal")]
    private static extern void connectPontemWallet();

    [DllImport("__Internal")]
    private static extern void connectPetraWallet();

    [DllImport("__Internal")]
    private static extern void connectRiseWallet();

    [DllImport("__Internal")]
    private static extern void connectFewchaWallet();

    [DllImport("__Internal")]
    private static extern void connectMartianWallet();  // <-- Added Martian here
#endif

    public void ConnectWallet(string walletName)
    {
#if UNITY_WEBGL && !UNITY_EDITOR
        switch(walletName.ToLower())
        {
            case "aptos":
                connectAptosWallet();
                break;
            case "pontem":
                connectPontemWallet();
                break;
            case "petra":
                connectPetraWallet();
                break;
            case "rise":
                connectRiseWallet();
                break;
            case "fewcha":
                connectFewchaWallet();
                break;
            case "martian":  // <-- Added case here
                connectMartianWallet();
                break;
            default:
                // Debug.LogError("Wallet " + walletName + " is not supported");
                break;
        }
#else
        // Debug.LogWarning("Wallet connect only works in WebGL builds");
#endif
    }

    // Called by JS when wallet connection succeeds
    public void OnWalletConnected(string walletAddress)
    {
        // Debug.Log("Wallet connected: " + walletAddress);
        // Add your logic here (e.g., update UI, start game, etc.)
    }

    // Called by JS when wallet connection fails
    public void OnWalletConnectFailed(string message)
    {
        // Debug.LogError("Wallet connection failed: " + message);
        // Add your logic here (e.g., show error UI)
    }
}
