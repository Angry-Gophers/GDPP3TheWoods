using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fireplace : MonoBehaviour, IDamage
{
    Light fireLight;

    [Range(1, 50)][SerializeField] int HP;

    int maxHP;
    float intensity;

    // Start is called before the first frame update
    void Start()
    {
        fireLight = GetComponent<Light>();
        maxHP = HP;
        intensity = fireLight.intensity;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void takeDamage(int dmg)
    {
        if (HP > 0)
        {
            HP -= dmg;
            float ratio = (float)HP / maxHP;
            fireLight.intensity = intensity * ratio;
        }
        else
        {
            Debug.Log("Fire is out");
        }
    }
}
