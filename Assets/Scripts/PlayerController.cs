using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDamage
{
    [Header("---Components---")]
    [SerializeField] CharacterController playerController;
    [SerializeField] GameObject trap;
    [SerializeField] AudioClip waveAud;
    [SerializeField] float waveVol;
    AudioSource aud;
    public bool isHealing;
    
    public int maxTraps;
    public int trapsHeld;
    public int bandagesHeld;
    public int candlesHeld;

    [Header("---Player Stats---")]
    [SerializeField] int HP;
    [SerializeField] float playerSpeed;
    [SerializeField] float jumpHeight;
    [SerializeField] int maxJumps;
    [SerializeField] float gravityValue;
    [SerializeField] int hpOriginal;
    [SerializeField] int interactRange;
    [SerializeField] float healTime;
    [SerializeField] int bandageHealAmount;

    [Header("---Currency---")]
    [SerializeField] public int ectoplasm;
    [SerializeField] public int antlers;
    [SerializeField] int ammoCost;
    Vector3 playervelocity;

    int timesJumped;
    // Start is called before the first frame update
    void Start()
    {
        HP = hpOriginal;
        aud = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        movement();
        jump();
        Interact();
        BandageHeal();
        placeTrap();
        PickTrap();
    }
    
    void movement()
    {
        if (playerController.isGrounded && playervelocity.y < 0)
        {
            timesJumped = 0;
            playervelocity.y = 0;
        }

        Vector3 move = transform.right * (Input.GetAxis("Horizontal")) + transform.forward * (Input.GetAxis("Vertical"));
        playerController.Move(move * Time.deltaTime * playerSpeed);
    }

    void jump()
    {

        if(Input.GetButton("Jump")&& timesJumped < maxJumps)
        {
            timesJumped++;
            playervelocity.y = jumpHeight;
        }
        playervelocity.y -= gravityValue * Time.deltaTime;
        playerController.Move(playervelocity * Time.deltaTime);


    }
    

    public void TakeDamage(int dmg)
    {
        HP -= dmg;

        gameManager.instance.playerHPBar.fillAmount = (float)HP / (float) hpOriginal;

        if(HP <= 0)
        {
            gameManager.instance.playerDeadMenu.active = true;
            gameManager.instance.deadText.text = "You have died";
            gameManager.instance.cursorLockPause();
        }
    }

    void placeTrap()
    {
        if(Input.GetKeyDown(KeyCode.E) && trapsHeld > 0)
        {
            RaycastHit hit;
            if(Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f,0.5f)), out hit, 6.0f))
            {
                if(hit.collider.GetComponent<IDamage>() == null)
                {
                    trapsHeld--;
                    Instantiate(trap, hit.point, trap.transform.rotation);
                    
                }
            }

            gameManager.instance.UpdatePlayerHUD();
            
        }
    }

    public void pickUpTrap()
    {
        
            trapsHeld++;
      
    }

    public void pickedUp(int type)
    {
        switch (type)
        {
            case 1:
                ectoplasm++;
                break;
            case 2:
                antlers++;
                break;
        }
    }

    void BandageHeal()
    {
        if (Input.GetKeyDown(KeyCode.Q) && !isHealing && bandagesHeld >0 && HP < hpOriginal)
        {
            StartCoroutine(heal());
        }

    }
    IEnumerator heal()
    {
        isHealing = true;
        gameManager.instance.healingText.SetActive(true);

        yield return new WaitForSeconds(healTime);
        HP += bandageHealAmount;

        gameManager.instance.healingText.SetActive(false);
        bandagesHeld--;
        isHealing = false;
        gameManager.instance.UpdatePlayerHUD();
        gameManager.instance.playerHPBar.fillAmount = (float)HP / (float)hpOriginal;
    }
    public void Interact()
    {
        if (Input.GetButtonDown("Interact"))
        {

            RaycastHit hit;
            if (Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f, 0.5f)), out hit, interactRange))
            {
                if (hit.collider.CompareTag("Fire") && !spawnManager.instance.inWave)
                {
                    spawnManager.instance.startWave();
                    aud.PlayOneShot(waveAud, waveVol);
                    StartCoroutine(gameManager.instance.NewWave());
                }

                if (hit.collider.CompareTag("Shop Car") && !spawnManager.instance.inWave)
                {
                    if(hit.collider.GetComponent<ShopHealth>().HP > 0)
                        gameManager.instance.ShopUI();
                }

                if(hit.collider.CompareTag("Ammo Box"))
                {
                    if (ectoplasm >= ammoCost)
                    {
                        ectoplasm -= ammoCost;
                        WeaponSwapping.instance.Restock();
                    }
                    else
                    {
                        StartCoroutine(gameManager.instance.NotEnough());
                    }
                }
            }
        }
    }
    void PickTrap()
    {
        RaycastHit hit;
        if (Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f, 0.5f)), out hit, 6.0f))
        {
            if (hit.collider.GetComponent<pickUpTrap>())
            {
                if (gameManager.instance.playerScript.trapsHeld < gameManager.instance.playerScript.maxTraps)
                {
                    //gameManager.instance.instruction.SetActive(true);

                    if (Input.GetButton("Interact"))
                    {
                        pickUpTrap();
                        hit.collider.GetComponent<pickUpTrap>().pickedUp();
                       // gameManager.instance.trapsFullInstruction.SetActive(false);
                       // gameManager.instance.instruction.SetActive(false);



                    }

                }
                else if (gameManager.instance.playerScript.trapsHeld >= gameManager.instance.playerScript.maxTraps)
                {
                    //gameManager.instance.trapsFullInstruction.SetActive(true);

                }
            }
            else
            {
               // gameManager.instance.trapsFullInstruction.SetActive(false);
                //gameManager.instance.instruction.SetActive(false);

            }

        }

    }
}
