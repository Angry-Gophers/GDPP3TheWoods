using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class enemyDrops : MonoBehaviour
{
    [SerializeField] int type;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<PlayerController>().pickedUp(type);
            Destroy(gameObject);
        }
    }
}
