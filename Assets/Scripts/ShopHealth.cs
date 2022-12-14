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
    [SerializeField] int upgradeBonus;

    int maxHP;

    void Start()
    {
        HP = 30;
        maxHP = HP;
        gameManager.instance.shopAlive = true;
        aud = gameObject.GetComponent<AudioSource>();
        UpdateHud();
    }

    public virtual void TakeDamage(int dmg)
    {
        HP -= dmg;
        UpdateHud();

        if (HP > 0)
        {
            StartCoroutine(gameManager.instance.ShopFlash());
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

    public void UpdateHud()
    {
        float ratio = (float)HP / (float)maxHP;
        gameManager.instance.shopHealthBar.fillAmount = ratio;
    }

    public void Heal()
    {
        HP = maxHP;
        gameManager.instance.shopAlive = true;
        headlights.enabled = true;
        brakelights.enabled = true;
    }

    public void Upgrade()
    {
        maxHP += upgradeBonus;
    }
}
