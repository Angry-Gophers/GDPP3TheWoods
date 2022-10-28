using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemyBase : MonoBehaviour, IDamage
{
    [Header("----- Componenets -----")]
    [SerializeField] protected GameObject eyes;
    protected NavMeshAgent agent;
    protected Vector3 target;

    [Header("----- Stats -----")]
    [SerializeField] int HP;

    // Start is called before the first frame update
    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        findTarget();
        agent.SetDestination(target);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public virtual void findTarget() { }

    public void takeDamage(int dmg)
    {
        HP -= dmg;

        if (HP <= 0)
            death();
    }

    void death()
    {
        agent.enabled = false;
        Destroy(gameObject);
    }
}
