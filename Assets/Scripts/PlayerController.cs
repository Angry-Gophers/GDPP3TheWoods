using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDamage
{
    [Header("---Components---")]
    [SerializeField] CharacterController controller;
    [Header("---Player Stats---")]
    [SerializeField] int HP;
    [SerializeField] float playerSpeed;
    [SerializeField] float jumpHeight;
    [SerializeField] int jumpMax;
    [SerializeField] float gravityValue;
    [SerializeField] int hpOriginal;
    [Header("---Player Weapon Stats---")]
    [SerializeField] int shootDmg;
    [SerializeField] float shootDist;
    [SerializeField] float shootRate;
    public bool isShooting;

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
        StartCoroutine(shoot());
    }
    
    void movement()
    {
        if (controller.isGrounded && playervelocity.y < 0)
        {
            timesJumped = 0;
            playervelocity.y = 0;
        }

        Vector3 move = transform.right * (Input.GetAxis("Horizontal")) + transform.forward * (Input.GetAxis("Vertical"));
        controller.Move(move * Time.deltaTime * playerSpeed);
    }

    void jump()
    {

        if(Input.GetButton("Jump")&& timesJumped < jumpMax)
        {
            timesJumped++;
            playervelocity.y = jumpHeight;
        }
        playervelocity.y -= gravityValue * Time.deltaTime;
        controller.Move(playervelocity * Time.deltaTime);


    }
    IEnumerator shoot()
    {
        if(Input.GetButton("Shoot") && !isShooting)
        {
            isShooting = true;
            Debug.Log("shot");
            RaycastHit hit;
            if(Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f,0.5f)), out hit, shootDist))
            {
                if(hit.collider.GetComponent<IDamage>() != null)
                {
                    hit.collider.GetComponent<IDamage>().takeDamage(shootDmg);
                }
            }
          yield return new WaitForSeconds(shootRate);
            isShooting = false;
        }
        
        
    }

    public void takeDamage(int dmg)
    {
        HP -= dmg;
        if(HP <= 0)
        {
            Debug.Log("You Died");
        }

    }
}
