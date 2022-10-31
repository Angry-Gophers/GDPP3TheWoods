using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class pickUpTrap : MonoBehaviour
{
    public GameObject instruction;
    bool action;
    private void OnTriggerEnter(Collider other)
    {
       
        if (other.CompareTag("Player"))
        {
            instruction.SetActive(true);
            action = true;
            
        }
    }
    private void OnTriggerExit(Collider other)
    {
        instruction.SetActive(false);
        action = false;
    }
    private void Update()
    {
        if(action && Input.GetKeyDown(KeyCode.F))
        {
            gameManager.instance.playerScript.pickUpTrap();
            instruction.SetActive(false);
            action = false;
            Destroy(gameObject);
        }
        
    }
}
