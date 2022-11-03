using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trap : MonoBehaviour
{
    [SerializeField] Animator anim;
    // Start is called before the first frame update

    private void OnTriggerEnter(Collider other)
    {
        anim.SetTrigger("clamp");
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
