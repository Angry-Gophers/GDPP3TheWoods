using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trap : MonoBehaviour
{
    [SerializeField] int dmg;
    [SerializeField] Animator anim;
    [SerializeField] AudioClip trapAud;
    [SerializeField] float trapVol;
    AudioSource aud;
    bool activated;
    // Start is called before the first frame update

    private void OnTriggerEnter(Collider other)
    {
        if (!activated && other.CompareTag("Player") || other.CompareTag("Enemy"))
        {
            activated = true;
            anim.SetTrigger("clamp");
            if (other.CompareTag("Player"))
            {
                gameManager.instance.player.GetComponent<CharacterController>().enabled = false;
                StartCoroutine(TrappedTimePlayer());
            }
            if (other.CompareTag("Enemy"))
            {
                if(other.GetComponent<enemyBase>() != null)
                {
                    StartCoroutine(other.GetComponent<enemyBase>().trapped(dmg));
                }
            }

            aud.PlayOneShot(trapAud, trapVol);
            Destroy(gameObject, 5);
        }
    }
    void Start()
    {
        aud = GetComponent<AudioSource>();
    }

    IEnumerator TrappedTimePlayer()
    {
        gameManager.instance.playerScript.TakeDamage(dmg);
        yield return new WaitForSeconds(2.5f);
        gameManager.instance.player.GetComponent<CharacterController>().enabled = true;
        Destroy(gameObject);
    }

}
