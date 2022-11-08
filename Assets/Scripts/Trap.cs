using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trap : MonoBehaviour
{
    [SerializeField] int dmg;
    [SerializeField] Animator anim;
    bool activated;
    // Start is called before the first frame update

    private void OnTriggerEnter(Collider other)
    {
        if (!activated)
        {
            anim.SetTrigger("clamp");
            if (other.CompareTag("Player"))
            {
                gameManager.instance.player.GetComponent<CharacterController>().enabled = false;
                StartCoroutine(TrappedTimePlayer());
            }
            if (other.CompareTag("Enemy"))
            {
                Debug.Log("Enemy detected");
                if(other.GetComponent<enemyBase>()!= null)
                {
                    StartCoroutine(other.GetComponent<enemyBase>().trapped(dmg));

                }
               
                
            }
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

}
