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
    [SerializeField] int corpseTime;

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
            //Gets the player direction based on local position, then gets the angle between the two
            playerDir = gameManager.instance.player.transform.position - transform.position;
            angle = Vector3.Angle(transform.forward, playerDir);

            //Check to see if in range for an attack
            if (agent.enabled == true)
            {
                if (agent.stoppingDistance >= agent.remainingDistance && !isAttacking)
                    StartCoroutine(attack());
            }
        }
    }

    public virtual void findTarget() { }

    public virtual IEnumerator attack() { yield return null; }

    public virtual void TakeDamage(int dmg)
    {
        HP -= dmg;

        agent.speed = 0;
        agent.speed = originalSpeed;

        if (HP <= 0)
            death();
    }

    public virtual void death()
    {
        col.enabled = false;
        agent.enabled = false;

        int temp = Random.Range(0, 2);
        if (temp == 0 && drop != null && spawnManager.instance.inWave)
            Instantiate(drop, dropTrans.position, dropTrans.rotation);

        spawnManager.instance.enemyDeath();
        Destroy(gameObject, corpseTime);
    }


    //Rotates the gameobject when the agent won't
    protected void faceTarget()
    {
        targetDir.y = 0;
        Quaternion rotation = Quaternion.LookRotation(targetDir);
        transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * 4);
    }
}
