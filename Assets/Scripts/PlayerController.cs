using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDamage
{
    [Header("---Components---")]
    [SerializeField] CharacterController playerController;
    [SerializeField] GameObject trap;
    [SerializeField] int maxTraps;
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
    [Header("---Currency---")]
    [SerializeField] public int ectoplasm;
    [SerializeField] public int antlers;
    Vector3 playervelocity;
    int timesJumped;
    // Start is called before the first frame update
    void Start()
    {
        HP = hpOriginal;
    }

    // Update is called once per frame
    void Update()
    {
        movement();
        jump();
        Interact();
        placeTrap();
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
                }

                if (hit.collider.CompareTag("Shop Car") && !spawnManager.instance.inWave)
                {
                    gameManager.instance.shopWindow.SetActive(true);
                    Debug.Log("Shop");
                }
            }
        }
    }
}
