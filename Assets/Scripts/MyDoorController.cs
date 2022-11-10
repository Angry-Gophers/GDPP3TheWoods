using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDoorController : MonoBehaviour
{
    private Animator doorAnim;

    private bool doorOpen = false;

    private void Awake()
    {
        doorAnim = gameObject.GetComponent<Animator>();
    }

    public void PlayAnimation()
    {
        if (!doorOpen)
        {
            gameObject.GetComponent<Collider>().enabled = false;
            doorAnim.Play("DoorOpen", 0, 0.0f);
            gameObject.GetComponent<Collider>().enabled = true;
            doorOpen = true;
        }
        else
        {
            gameObject.GetComponent<Collider>().enabled = false;
            doorAnim.Play("DoorClose", 0, 0.0f);
            gameObject.GetComponent<Collider>().enabled = true;
            doorOpen = false;
        }
    }
}
