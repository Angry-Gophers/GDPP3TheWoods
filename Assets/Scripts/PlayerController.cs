using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDamage
{
    [Header("---Components---")]
    [SerializeField] CharacterController playerController;
    [SerializeField] GameObject trap;
    public bool isHealing;
    [SerializeField] AudioClip waveAud;
    [SerializeField] float waveVol;
    AudioSource aud;
    bool inverted;
    
    public int maxTraps;
    public int maxBoards;
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

    [Header("---Audio---")]
    [SerializeField] List<AudioClip> hurtAud;
    [Range(0f, 1f)] [SerializeField] float hurtVol;

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
        if(playerController.enabled)
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

        if(playerController.enabled)
            playerController.Move(playervelocity * Time.deltaTime);
    }
    

    public void TakeDamage(int dmg)
    {
        HP -= dmg;
        gameManager.instance.playerHPBar.fillAmount = (float)HP / (float)hpOriginal;

        if (HP <= 0)
        {
            gameManager.instance.playerDeadMenu.active = true;
            gameManager.instance.menuCurrentlyOpen = gameManager.instance.playerDeadMenu;
            gameManager.instance.ClearHud();
            gameManager.instance.deadText.text = "You have died \nWaves Survived: " + spawnManager.instance.wave;
            gameManager.instance.cursorLockPause();
        }
        else
        {
            aud.PlayOneShot(hurtAud[Random.Range(0, hurtAud.Count)], hurtVol);
        }
    }

    void placeTrap()
    {
        if(Input.GetKeyDown(KeyCode.E) && trapsHeld > 0)
        {
            RaycastHit hit;
            if(Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f,0.5f)), out hit, 6.0f))
            {
                if (hit.collider.GetComponent<IDamage>() == null && hit.collider.CompareTag("Trapable"))
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
        if (Input.GetKeyDown(KeyCode.Q) && !isHealing && bandagesHeld > 0 && HP < hpOriginal)
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
                    PlayWaveAudio();
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

    public void PlayWaveAudio()
    {
        Debug.Log("New wave");
        aud.PlayOneShot(waveAud, waveVol);
    }

    public void Heal()
    {
        HP = hpOriginal;
    }

    public float getHP()
    {
        return (float)HP;
    }

    public float GetMaxHP()
    {
        return (float) hpOriginal;
    }

    public void SetYVel(float newVel)
    {
        playervelocity.y = newVel;
    }
}
