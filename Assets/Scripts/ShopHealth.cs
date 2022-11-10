using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopHealth : MonoBehaviour, IDamage
{
    public int HP;
    AudioSource aud;
    [SerializeField] AudioClip wreckAud;
    [SerializeField] float wreckVol;
    [SerializeField] Light headlights;
    [SerializeField] Light brakelights;

    int maxHP;

    void Start()
    {
        maxHP = HP;
        gameManager.instance.shopAlive = true;
        aud = gameObject.GetComponent<AudioSource>();
    }

    public virtual void TakeDamage(int dmg)
    {
        if (HP > 0)
        {
            HP -= dmg;
            float ratio = (float)HP / (float) maxHP;
            gameManager.instance.shopHealthBar.fillAmount = ratio;
        }
        else
        {
            if (gameManager.instance.shopAlive)
            {
                aud.PlayOneShot(wreckAud, wreckVol);
                gameManager.instance.shopAlive = false;
                headlights.enabled = false;
                brakelights.enabled = false;
            }
        }
    }
}
