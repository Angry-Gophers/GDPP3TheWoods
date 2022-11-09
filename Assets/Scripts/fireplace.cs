using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fireplace : MonoBehaviour, IDamage
{
    [Range(1, 50)] public int HP;
    [SerializeField] Light fireLight;

    public int maxHP;
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
            UpdateFireHud();
        }
        else
        {
            gameManager.instance.playerDeadMenu.SetActive(true);
            gameManager.instance.deadText.text = "The fire has gone out";
            gameManager.instance.cursorLockPause();
        }
    }

    public void UpdateFireHud()
    {
        float ratio = (float)HP / maxHP;
        fireLight.intensity = intensity * ratio;
        gameManager.instance.fire.fillAmount = ratio;
    }
}
