using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class pickUpTrap : MonoBehaviour
{
   
    private void Update()
    {
        
    }
   public void pickedUp()
    {
        Destroy(gameObject);
    }
}
