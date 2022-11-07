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
    [SerializeField] int corpseTime;

    protected float originalSpeed;
    protected Vector3 targetDir;
    protected bool isAttacking;

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
        if (HP > 0)
        {
            //Check to see if in range for an attack
            if (HP > 0 && agent.enabled == true)
            {
                //Find current target
                if (target != gameManager.instance.fireplace.transform.position)
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
            anim.SetTrigger("gotHit");
            StartCoroutine(stagger());
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

    IEnumerator stagger()
    {
        agent.speed = 0;
        yield return new WaitForSeconds(staggerTime);
        agent.speed = originalSpeed;
    }
}
