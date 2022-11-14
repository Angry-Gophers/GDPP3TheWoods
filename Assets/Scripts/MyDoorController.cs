using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDoorController : MonoBehaviour
{
    public Animator doorAnim;

    [SerializeField] AudioSource audioSource;
    [SerializeField] AudioClip[] doorNoises;
    [Range(0, 1)] [SerializeField] float doorNoisesAudVolume;

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
            audioSource.PlayOneShot(doorNoises[1], doorNoisesAudVolume);
            gameObject.GetComponent<Collider>().enabled = true;
            doorOpen = true;
        }
        else
        {
            gameObject.GetComponent<Collider>().enabled = false;
            doorAnim.Play("DoorClose", 0, 0.0f);
            audioSource.PlayOneShot(doorNoises[0], doorNoisesAudVolume);
            gameObject.GetComponent<Collider>().enabled = true;
            doorOpen = false;
        }
    }

    public bool AnimatorIsPlaying()
    {
        return doorAnim.GetCurrentAnimatorStateInfo(0).length >
               doorAnim.GetCurrentAnimatorStateInfo(0).normalizedTime;
    }
}
