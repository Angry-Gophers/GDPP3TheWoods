using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class gameManager : MonoBehaviour
{
    public static gameManager instance;
    public static WeaponSwapping instanceGuns;
    [Header("----- Player -----")]
    public GameObject player;
    public PlayerController playerScript;
    public GameObject gunContainer;
    // public GameObject spawnPosition;

    [Header("----- UI -----")]
    public GameObject pauseMenu;
    public GameObject shopWindow;
    public GameObject gunShopWindow;
    public GameObject playerDeadMenu;
    public TextMeshProUGUI deadText;
    public GameObject nextWaveText;
    public TextMeshProUGUI waveText;
    public GameObject newWaveText;
    public GameObject instruction;
    //public GameObject trapsFullInstruction;
    public Animator anim;
    public TextMeshProUGUI shopEcto;
    public TextMeshProUGUI shopAntler;
    public TextMeshProUGUI heldEcto;
    public TextMeshProUGUI heldAntlers;
    public GameObject reloadText;
    public GameObject interactText;
    public GameObject notEnoughText;
    public GameObject healingText;
    public GameObject menuCurrentlyOpen;
    //  public GameObject playerDamageFlash;
    public Image playerHPBar;
    public Image fire;
    public TextMeshProUGUI ammoTracker;
    //  public TextMeshProUGUI boardsTracker;
    public TextMeshProUGUI trapsTracker;
    public TextMeshProUGUI bandageTracker;
    public Image shopHealthBar;
    public bool shopAlive;
    public bool isPaused;
    [SerializeField] Color fireFlashColor;
    [SerializeField] Color shopFlashColor;

    [Header("---- Other components ----")]
    public GameObject fireplace;
    public GameObject shop;
    public ShopHealth shopScript;

    bool interact;
    bool reload;
    bool notEnough;
    bool healing;
    Color fireColor;
    Color shopColor;


    void Awake()
    {
        instanceGuns = new WeaponSwapping();
        instance = this;
        player = GameObject.FindGameObjectWithTag("Player");
        playerScript = player.GetComponent<PlayerController>();
        gunContainer = GameObject.FindGameObjectWithTag("Gun Contain");
        fireplace = GameObject.FindGameObjectWithTag("Fire");
        shop = GameObject.FindGameObjectWithTag("Shop Car");
        shopScript = shop.GetComponent<ShopHealth>();
        Time.timeScale = 1;
        shopColor = shopHealthBar.color;
        fireColor = fire.color;

        StartCoroutine(BeginningText());
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Cancel") && menuCurrentlyOpen == pauseMenu || Input.GetButtonDown("Cancel") && menuCurrentlyOpen == null) // check for deadMenu and shopMenu
        {
            isPaused = !isPaused;
            pauseMenu.SetActive(isPaused);

            if (isPaused)
            {
                menuCurrentlyOpen = pauseMenu;
                cursorLockPause();
            }
            else
            {
                menuCurrentlyOpen = null;
                cursorUnlockUnpause();
            }
        }
    }

    public void cursorLockPause()
    {
        Time.timeScale = 0;
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.Confined;
        ClearHud();
    }
    public void cursorUnlockUnpause()
    {
        Time.timeScale = 1;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        RestoreHud();
    }

    public void UpdatePlayerHUD()
    {
        // ammo, bandages, boards, traps, fire health, anything else? night time left? 
        ammoTracker.text = WeaponSwapping.instance.weapon.GetComponent<Gun>().bullets + " / " + WeaponSwapping.instance.weapon.GetComponent<Gun>().reserveAmmo;
        heldEcto.text = "Ectoplasm: " + playerScript.ectoplasm;
        heldAntlers.text = "Antlers: " + playerScript.antlers;
        trapsTracker.text = playerScript.trapsHeld.ToString();
        bandageTracker.text = playerScript.bandagesHeld.ToString();

    }

    public void ShopUI()
    {
        menuCurrentlyOpen = shopWindow;
        cursorLockPause();

        shopEcto.text = "Ectoplasm: " + playerScript.ectoplasm;
        shopAntler.text = "Antlers: " + playerScript.antlers;

        shopWindow.SetActive(true);
    }

    public IEnumerator NotEnough()
    {
        notEnoughText.SetActive(true);

        yield return new WaitForSeconds(2);

        notEnoughText.SetActive(false);
    }

    public void ClearHud()
    {
        if (interactText.activeSelf == true)
        {
            interact = true;
            interactText.SetActive(false);
        }

        if (reloadText.activeSelf == true)
        {
            reload = true;
            reloadText.SetActive(false);
        }

        if (notEnoughText.activeSelf == true)
        {
            notEnough = true;
            notEnoughText.SetActive(false);
        }

        if(healingText.activeSelf == true)
        {
            healing = true;
            healingText.SetActive(false);
        }
    }

    public void RestoreHud()
    {
        interactText.SetActive(interact);
        reloadText.SetActive(reload);
        notEnoughText.SetActive(notEnough);
        healingText.SetActive(healing);

        interact = false;
        reload = false;
        notEnough = false;
        healing = false;
    }

    public IEnumerator NewWave()
    {
        newWaveText.SetActive(true);
        yield return new WaitForSeconds(6);
        newWaveText.SetActive(false);
    }

    public IEnumerator BeginningText()
    {
        instruction.SetActive(true);
        yield return new WaitForSeconds(10);
        instruction.SetActive(false);
    }

    public IEnumerator FireFlash()
    {
        fire.color = fireFlashColor;
        yield return new WaitForSeconds(0.2f);
        fire.color = fireColor;
    }

    public IEnumerator ShopFlash()
    {
        shopHealthBar.color = shopFlashColor;
        yield return new WaitForSeconds(0.2f);
        shopHealthBar.color = shopColor;
    }
}
