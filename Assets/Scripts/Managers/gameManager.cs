using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class gameManager : MonoBehaviour
{
    public static gameManager instance;
    public static WeaponSwapping instanceGuns;
    public static MeleeSwapping instanceMelee;
    [Header("----- Player -----")]
    public GameObject player;
    public PlayerController playerScript;
    public GameObject meleeContainer;
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
    public GameObject instruction;
    public GameObject trapsFullInstruction;
    public Animator anim;
    public TextMeshProUGUI shopEcto;
    public TextMeshProUGUI shopAntler;
    public TextMeshProUGUI heldEcto;
    public TextMeshProUGUI heldAntlers;
    public GameObject reloadText;
    public GameObject interactText;
    public GameObject notEnoughText;
    //  public GameObject menuCurrentlyOpen;
    //  public GameObject playerDamageFlash;
    public Image playerHPBar;
    public Image fire;
    //  public Image ammo;
    //  public Image traps;
    //  public Image boards;
    //  public Image bandages;
    //  public TextMeshProUGUI fireHealthText;
    public TextMeshProUGUI ammoTracker;
    //  public TextMeshProUGUI boardsTracker;
    //  public TextMeshProUGUI trapsTracker;
    //  public TextMeshProUGUI bandageTracker;
    public bool isPaused;

    void Awake()
    {
        instanceGuns = new WeaponSwapping();
        instanceMelee = new MeleeSwapping();
        instance = this;
        player = GameObject.FindGameObjectWithTag("Player");
        playerScript = player.GetComponent<PlayerController>();
        gunContainer = GameObject.FindGameObjectWithTag("Gun Contain");
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
        if (Input.GetButtonDown("Melee"))
        {
            
            gunContainer.SetActive(false);
            meleeContainer.SetActive(true);
            instanceMelee.SelectMelee();
        }

        if (Input.GetButtonDown("Guns"))
        {
            
            gunContainer.SetActive(true);
            meleeContainer.SetActive(false);
            instanceGuns.SelectGun();
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

    public void UpdatePlayerHUD()
    {
        // ammo, bandages, boards, traps, fire health, anything else? night time left? 
        ammoTracker.text = WeaponSwapping.instance.weapon.GetComponent<Gun>().bullets + " / " + WeaponSwapping.instance.weapon.GetComponent<Gun>().reserveAmmo;
        heldEcto.text = "Ectoplasm: " + playerScript.ectoplasm;
        heldAntlers.text = "Antlers: " + playerScript.antlers;
    }

    public void ShopUI()
    {
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
}
