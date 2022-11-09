using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fireplace : MonoBehaviour, IDamage
{
    [Range(1, 50)][SerializeField] int HP;
    [SerializeField] Light fireLight;

    int maxHP;
    float intensity;

    // Start is called before the first frame update
    void Start()
    {
        maxHP = HP;
        intensity = fireLight.intensity;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void TakeDamage(int dmg)
    {
        if (HP > 0)
        {
            HP -= dmg;
            float ratio = (float)HP / maxHP;
            fireLight.intensity = intensity * ratio;
            gameManager.instance.fire.fillAmount = ratio;
        }
        else
        {
            gameManager.instance.playerDeadMenu.active = true;
            gameManager.instance.deadText.text = "The fire has gone out";
            gameManager.instance.cursorLockPause();
        }
    }
}
