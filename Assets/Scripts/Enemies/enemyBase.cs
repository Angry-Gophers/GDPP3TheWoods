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
    [Range(1,50)][SerializeField] int HP;
    [Range(.1f, 5f)] [SerializeField] protected float attackSpeed;
    [Range(1, 10)] [SerializeField] protected int damage;
    [Range(1, 10)] [SerializeField] protected int range;

    protected float originalSpeed;
    protected Vector3 targetDir;
    protected Vector3 playerDir;
    protected float angle;
    protected bool isAttacking;

    // Start is called before the first frame update
    protected void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        anim = GetComponent<Animator>();
        findTarget();
        agent.SetDestination(target);

        originalSpeed = agent.speed;
    }

    protected void Update()
    {
        playerDir = gameManager.instance.player.transform.position - transform.position;
        angle = Vector3.Angle(transform.forward, playerDir);
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
        spawnManager.instance.enemyDeath();
        Destroy(gameObject);
    }
}
