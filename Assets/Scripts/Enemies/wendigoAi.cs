using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class wendigoAi : enemyBase
{
    // Update is called once per frame
    void Update()
    {
        base.Update();

        if(HP > 0 && agent.enabled == true)
        {
            //update with new player location
            findTarget();
            agent.SetDestination(target);

            targetDir = target - transform.position;
        }
    }

    public override IEnumerator attack()
    {
        isAttacking = true;

        //Shoots a raycast and checks if the hit object can be damaged
        RaycastHit hit;
        if (Physics.Raycast(transform.position, transform.forward, out hit, range))
        {
            if (hit.collider.GetComponent<IDamage>() != null && hit.collider.tag != "Enemy")
                hit.collider.GetComponent<IDamage>().TakeDamage(damage);
        }

        yield return new WaitForSeconds(attackSpeed);
        isAttacking = false;
    }

    public override void findTarget()
    {
        target = gameManager.instance.player.transform.position;
    }
}
