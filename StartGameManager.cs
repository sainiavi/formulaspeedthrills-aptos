using UnityEngine;
using System.Collections;
using TMPro;
using UnityEngine.Networking;
using System;

[Serializable]
public class NFTResponse
{
    public NFTData[] data;
}

[Serializable]
public class NFTData
{
    public string token_id;
    public string name;
    public string image;
}

public class StartGameManager : MonoBehaviour
{
    private const string mintingURL = "https://launchpad.wapal.io/nft/legendary-drivers-pass";
    private const string collectionId = "0xe874fa9302dc2bbf91016d1329bd5eb923db290b363093922a841a280e878d37";

    public TMP_Text statusText;
    public TMP_Text walletText;
    public GameManager gameManager;

    public void OnWalletConnected(string walletAddress)
    {
        // Debug.Log("Wallet Connected: " + walletAddress);
        statusText.text = "Connected: " + walletAddress;
        walletText.text = walletAddress;

        StartCoroutine(CheckNFT(walletAddress));
    }

    private IEnumerator CheckNFT(string walletAddress)
    {
        string url = $"https://aggregator-api.wapal.io/user/tokens/{walletAddress}?collectionId={collectionId}&type=show_all";

        using (UnityWebRequest req = UnityWebRequest.Get(url))
        {
            yield return req.SendWebRequest();

            if (req.result == UnityWebRequest.Result.Success)
            {
                string json = req.downloadHandler.text;
                NFTResponse response = JsonUtility.FromJson<NFTResponse>("{\"data\":" + json + "}");

                if (response != null && response.data != null && response.data.Length > 0)
                {
                    Debug.Log("✅ NFT Pass Validated — Starting Game...");
                    OnStartGame();
                }
                else
                {
                    Debug.Log("❌ NFT not found — Redirecting to minting site...");
                    Application.OpenURL(mintingURL);
                }
            }
            else
            {
                Debug.LogError("❗ API Error: " + req.error);
                Application.OpenURL(mintingURL); // Fail-safe
            }
        }
    }

    public void OnStartGame()
    {
        // Debug.Log("🚀 Start Game logic triggered!");
        if (gameManager == null)
            gameManager = GameObject.Find("GameManager")?.GetComponent<GameManager>();

        if (gameManager != null)
        {
            gameManager.OnStartGame();
            Debug.Log("🎮 Game started!");
        }
        else
        {
            Debug.LogError("❗ GameManager not found in scene.");
        }
    }
}
