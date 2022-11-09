using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopHealth : MonoBehaviour, IDamage
{
    public int HP;
    AudioSource aud;
    [SerializeField] AudioClip wreckAud;
    [SerializeField] float wreckVol;

    int maxHP;

    void Start()
    {
        HP = maxHP;
    }

    public virtual void TakeDamage(int dmg)
    {
        if(HP > 0)
        {
            HP -= dmg;
            float ratio = (float)HP / (float) maxHP;
            gameManager.instance.shopHealthBar.fillAmount = ratio;
        }
    }
}
