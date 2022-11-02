using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class pickUpTrap : MonoBehaviour
{
    public GameObject instruction;
    public GameObject trapsFullInstruction;
    bool action;
    private void OnTriggerEnter(Collider other)
    {
       
        if (other.CompareTag("Player"))
        {
            if(gameManager.instance.playerScript.trapsHeld < gameManager.instance.playerScript.maxTraps)
            {
                instruction.SetActive(true);
            }
            else
            {
                trapsFullInstruction.SetActive(true);
            }
            action = true;


        }
    }
    private void OnTriggerExit(Collider other)
    {
        instruction.SetActive(false);
        trapsFullInstruction.SetActive(false);
        action = false;
    }
    private void Update()
    {
        if(action && Input.GetKeyDown(KeyCode.F) && gameManager.instance.playerScript.trapsHeld != gameManager.instance.playerScript.maxTraps)
        {
            gameManager.instance.playerScript.pickUpTrap();
            instruction.SetActive(false);
            action = false;
            Destroy(gameObject);
        }
        
    }
}
