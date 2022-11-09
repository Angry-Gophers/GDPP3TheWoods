using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopHealth : MonoBehaviour, IDamage
{
    public int HP;
    AudioSource aud;
    [SerializeField] AudioClip wreckAud;
    [SerializeField] float wreckVol;

    public virtual void TakeDamage(int dmg)
    {
        HP -= dmg;

        if(HP <= 0)
        {
            aud.PlayOneShot(wreckAud, wreckVol);
        }
    }
}
