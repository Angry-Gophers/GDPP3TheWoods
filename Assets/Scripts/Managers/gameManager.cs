using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class gameManager : MonoBehaviour
{
    public static gameManager instance;
    [Header("----- Player -----")]
    public GameObject player;
    public PlayerController playerScript;
    // public GameObject spawnPosition;

    [Header("----- UI -----")]
    public GameObject pauseMenu;
    public GameObject shopWindow;
    public GameObject gunShopWindow;
    public GameObject playerDeadMenu;
    public TextMeshProUGUI deadText;
    public GameObject nextWaveText;
    public TextMeshProUGUI waveText;
    public Animator anim;
    public TextMeshProUGUI shopEcto;
    public TextMeshProUGUI shopAntler;
    //  public GameObject menuCurrentlyOpen;
    //  public GameObject playerDamageFlash;
    public Image playerHPBar;
    public Image fire;
    //  public Image ammo;
    //  public Image traps;
    //  public Image boards;
    //  public Image bandages;
    //  public TextMeshProUGUI fireHealthText;
    //  public TextMeshProUGUI ammoTracker;
    //  public TextMeshProUGUI boardsTracker;
    //  public TextMeshProUGUI trapsTracker;
    //  public TextMeshProUGUI bandageTracker;
    public bool isPaused;

    void Awake()
    {
        instance = this;
        player = GameObject.FindGameObjectWithTag("Player");
        playerScript = player.GetComponent<PlayerController>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Cancel") && playerDeadMenu.activeSelf != true && shopWindow.activeSelf != true) // check for deadMenu and shopMenu
        {
            isPaused = !isPaused;
            pauseMenu.SetActive(isPaused);

            if (isPaused)
            {
                cursorLockPause();
            }
            else
            {
                cursorUnlockUnpause();
            }
        }
    }

    public void cursorLockPause()
    {
        Time.timeScale = 0;
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.Confined;
    }
    public void cursorUnlockUnpause()
    {
        Time.timeScale = 1;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    public void updatePlayerHUD()
    {
        // ammo, bandages, boards, traps, fire health, anything else? night time left? 
    }

    public void ShopUI()
    {
        cursorLockPause();

        shopEcto.text = "Ectoplasm: " + playerScript.ectoplasm;
        shopAntler.text = "Antlers: " + playerScript.antlers;

        shopWindow.SetActive(true);
    }
}
