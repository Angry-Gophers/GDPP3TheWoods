using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class phantomAi : enemyBase
{
    [Header("----- Phantom stats -----")]
    [Range(25, 60)][SerializeField] int viewAngle;
    [Range(1, 20)][SerializeField] int viewRange;

    // Update is called once per frame
    void Update()
    {
        base.Update();

        if (HP > 0)
        {
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
                if (agent.destination != target)
                    agent.destination = target;

                targetDir = target - transform.position;
            }

            //Rotate to face the target
            if (agent.stoppingDistance >= agent.remainingDistance)
            {
                faceTarget();
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

    //Melee attack
    public override IEnumerator attack()
    {
        isAttacking = true;

        anim.SetTrigger("cast3");

        //Shoots a raycast and checks if the hit object can be damaged
        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward, out hit, range))
        {
            if (hit.collider.GetComponent<IDamage>() != null && hit.collider.tag != "Enemy")
                hit.collider.GetComponent<IDamage>().TakeDamage(damage);
        }

        yield return new WaitForSeconds(attackSpeed);
        isAttacking = false;
    }
}
