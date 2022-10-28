using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class phantomAi : enemyBase
{
    [Header("----- Phantom stats -----")]
    [Range(25, 60)][SerializeField] int viewAngle;
    [Range(1, 20)][SerializeField] int viewRange;
    [Range(.25f, 1f)][SerializeField] float sizeRandMin;
    [Range(1f, 2f)] [SerializeField] float sizeRandMax;


    private void Start()
    {
        base.Start();

        //Sets each phantom to a random size, and set its speed based on how big it is
        float size = Random.Range(sizeRandMin, sizeRandMax);
        gameObject.transform.transform.localScale = new Vector3 (size, size, size);
        agent.speed *= 1 / size;
        originalSpeed = agent.speed;
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();

        //Set walk animation speed
        anim.SetFloat("locomotion", Mathf.Lerp(anim.GetFloat("locomotion"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));

        //Target the player or the fire depending on line of sight
        if (canSeePlayer())
        {
            targetDir = playerDir;

            agent.SetDestination(gameManager.instance.player.transform.position);
        }
        else
        //Otherwise target the fire
        {
            if(agent.destination != target)
                agent.destination = target;

            targetDir = target - transform.position;
        }

        //If the enemy is too close for the agent to rotate, then make it face the target
        if(agent.stoppingDistance >= agent.remainingDistance)
        {
            faceTarget();

            //Attack if able
            if (!isAttacking)
            {
                StartCoroutine(attack());
            }
        }
    }

    //Find the fireplace
    public override void findTarget()
    {
        target = GameObject.FindGameObjectWithTag("Fire").transform.position;
    }

    //Checks if player is in line of sight
    bool canSeePlayer()
    {
        RaycastHit hit;

        if(Physics.Raycast(eyes.transform.position, playerDir, out hit, viewRange))
        {
            if (hit.collider.CompareTag("Player") && angle <= viewAngle)
                return true;
            else
                return false;
        }
        else
            return false;
    }

    //Rotates the gameobject when the agent won't
    void faceTarget()
    {
        targetDir.y = 0;
        Quaternion rotation = Quaternion.LookRotation(targetDir);
        transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * 4);
    }

    //Melee attack
    IEnumerator attack()
    {
        isAttacking = true;

        //Shoots a raycast and checks if the hit object can be damaged
        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward, out hit, range))
        {
            if (hit.collider.GetComponent<IDamage>() != null && hit.collider.tag != "Enemy")
                hit.collider.GetComponent<IDamage>().takeDamage(damage);
        }

        yield return new WaitForSeconds(attackSpeed);
        isAttacking = false;
    }
}
