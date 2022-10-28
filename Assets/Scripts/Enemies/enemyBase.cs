using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemyBase : MonoBehaviour, IDamage
{
    [Header("----- Componenets -----")]
    [SerializeField] protected GameObject eyes;
    protected Animator anim;
    protected NavMeshAgent agent;
    protected Vector3 target;

    [Header("----- Stats -----")]
    [SerializeField] int HP;

    protected float originalSpeed;

    // Start is called before the first frame update
    protected void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        anim = GetComponent<Animator>();
        findTarget();
        agent.SetDestination(target);

        originalSpeed = agent.speed;
    }

    public virtual void findTarget() { }

    public void takeDamage(int dmg)
    {
        HP -= dmg;

        agent.speed = 0;
        anim.SetTrigger("gotHit");

        if (HP <= 0)
            death();
    }

    void death()
    {
        agent.enabled = false;
        Destroy(gameObject);
    }
}
