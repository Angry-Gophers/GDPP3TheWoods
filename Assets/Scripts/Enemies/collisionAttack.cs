using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class collisionAttack : MonoBehaviour
{
    public int damage;
    public bool playerhit;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !playerhit)
        {
            gameManager.instance.playerScript.TakeDamage(damage);
            playerhit = true;
        }
    }
}
