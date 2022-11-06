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

        if (HP > 0 && agent.enabled == true)
        {
            //Set walk animation speed
            anim.SetFloat("locomotion", Mathf.Lerp(anim.GetFloat("locomotion"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));

            //Find current target
            if(target != gameManager.instance.fireplace.transform.position)
                findTarget();

            agent.SetDestination(target);

            targetDir = target - transform.position;
        }
    }

    //Find the fireplace
    public override void findTarget()
    {
        if (spawnManager.instance.enemiesTargetingFire < spawnManager.instance.targetFireLimit)
        {
            target = gameManager.instance.fireplace.transform.position;
            spawnManager.instance.enemiesTargetingFire++;
        }
        else
            target = gameManager.instance.player.transform.position;
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

    public override void death()
    {
        base.death();

        anim.SetTrigger("death");
        if (target == gameManager.instance.fireplace.transform.position)
            spawnManager.instance.enemiesTargetingFire--;
    }

    public override void TakeDamage(int dmg)
    {
        base.TakeDamage(dmg);

        anim.SetTrigger("gotHit");
    }
}
