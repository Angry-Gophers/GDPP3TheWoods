using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemyBase : MonoBehaviour, IDamage
{
    [Header("----- Componenets -----")]
    [SerializeField] protected GameObject eyes;
    [SerializeField] protected GameObject drop;
    [SerializeField] protected Transform dropTrans;
    protected Animator anim;
    protected NavMeshAgent agent;
    protected Vector3 target;
    protected Collider col;

    [Header("----- Stats -----")]
    [Range(1,50)]public int HP;
    [Range(.1f, 5f)] [SerializeField] protected float attackSpeed;
    [Range(1, 10)] [SerializeField] protected int damage;
    [Range(1, 10)] [SerializeField] protected int range;
    [Range(.25f, 1f)] [SerializeField] float sizeRandMin;
    [Range(1f, 2f)] [SerializeField] float sizeRandMax;
    [Range (0.1f, 5f)][SerializeField] float staggerTime;
    [Range(1, 4)] [SerializeField] int staggerChance;
    [SerializeField] int corpseTime;
    [SerializeField] int trappedTime;

    protected float originalSpeed;
    protected Vector3 targetDir;
    protected bool isAttacking;
    protected bool staggered = false;
    bool isTrapped;

    float stopping;
    float remaining;

    // Start is called before the first frame update
    protected void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        anim = GetComponent<Animator>();
        col = GetComponent<Collider>();
        findTarget();
        agent.SetDestination(target);

        //Sets each enemy to a random size, and set its speed based on how big it is
        float size = Random.Range(sizeRandMin, sizeRandMax);
        gameObject.transform.transform.localScale = new Vector3(size, size, size);
        agent.speed *= 1 / size;
        originalSpeed = agent.speed;
    }

    protected void Update()
    {
        //Check to see if in range for an attack
        if (HP > 0 && agent.enabled == true)
        {
            //Find current target
            if (target != gameManager.instance.fire.transform.position)
                findTarget();

            agent.SetDestination(target);

            targetDir = target - transform.position;

            if (agent.stoppingDistance >= agent.remainingDistance)
            {
                faceTarget();

                if(!isAttacking)
                    StartCoroutine(attack());
            }
        }
    }

    public virtual void findTarget() { }

    public virtual IEnumerator attack() { yield return null; }

    public virtual void TakeDamage(int dmg)
    {
        HP -= dmg;

        if (HP <= 0)
            death();
        else
        {
            int temp = Random.Range(0, 4);
            staggered = false;

            if (temp >= staggerChance || dmg >= 10)
            {
                StartCoroutine(stagger());
                staggered = true;
            }
        }
    }

    public virtual void death()
    {
        col.enabled = false;
        agent.enabled = false;

        int temp = Random.Range(0, 2);
        if (temp == 0 && drop != null && spawnManager.instance.inWave)
            Instantiate(drop, dropTrans.position, dropTrans.rotation);

        anim.SetTrigger("death");
        Destroy(gameObject, corpseTime);
    }


    //Rotates the gameobject when the agent won't
    protected void faceTarget()
    {
        targetDir.y = 0;
        Quaternion rotation = Quaternion.LookRotation(targetDir);
        transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * 4);
    }

    public virtual IEnumerator stagger()
    {
        if (anim.GetBool("gotHit") == false)
            anim.SetBool("gotHit", true);

        agent.speed = 0;
        yield return new WaitForSeconds(staggerTime);

        if(!isTrapped)
            agent.speed = originalSpeed;

        anim.SetBool("gotHit", false);
    }

    public IEnumerator trapped(int dmg)
    {
        isTrapped = true;
        agent.speed = 0;
        HP -= dmg;

        if(HP <= 0)
            death();

        yield return new WaitForSeconds(trappedTime);
        agent.speed = originalSpeed;
        isTrapped = false;
    }
}
