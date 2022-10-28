using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [Header("---Components---")]
    [SerializeField] CharacterController controller;
    [Header("---Player Stats---")]
    [SerializeField] float playerSpeed;
    [SerializeField] float jumpHeight;
    [SerializeField] int jumpMax;
    [SerializeField] float gravityValue;
    Vector3 playervelocity;
    int timesJumped;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        movement();
        jump();
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
}
