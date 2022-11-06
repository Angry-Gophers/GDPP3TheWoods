using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trap : MonoBehaviour
{
    [SerializeField] int dmg;
    [SerializeField] Animator anim;
    // Start is called before the first frame update

    private void OnTriggerEnter(Collider other)
    {
        anim.SetTrigger("clamp");
        if (other.CompareTag("Player"))
        {
            gameManager.instance.player.GetComponent<CharacterController>().enabled = false;
            StartCoroutine(TrappedTimePlayer());
            
          
        }
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator TrappedTimePlayer()
    {
        gameManager.instance.playerScript.TakeDamage(dmg);
        yield return new WaitForSeconds(2.5f);
        gameManager.instance.player.GetComponent<CharacterController>().enabled = true;
        Destroy(gameObject);
    }

    IEnumerator TrappedTimeEnemy()
    {
        yield return new WaitForSeconds(5.0f);
       
    }
}
