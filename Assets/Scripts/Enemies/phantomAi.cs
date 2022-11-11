using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class phantomAi : enemyBase
{
    [SerializeField] float shopBuffer;

    // Update is called once per frame
    void Update()
    {
        base.Update();

        if (HP > 0 && agent.enabled == true)
        {
            //Set walk animation speed
            anim.SetFloat("locomotion", Mathf.Lerp(anim.GetFloat("locomotion"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));
        }
    }

    //Find the fireplace
    public override void findTarget()
    {
        if (spawnManager.instance.enemiesTargetingFire < spawnManager.instance.targetFireLimit)
        {
            target = gameManager.instance.fireplace.transform.position;
            spawnManager.instance.enemiesTargetingFire++;
            agent.stoppingDistance = stoppingDis;
            targetingPlayer = false;
        }
        else if (spawnManager.instance.enemiesTargetingShop < spawnManager.instance.shopLimit && gameManager.instance.shopAlive)
        {
            target = gameManager.instance.shop.transform.position;
            spawnManager.instance.enemiesTargetingShop++;
            agent.stoppingDistance = shopBuffer;
            targetingPlayer = false;
        }
        else
        {
            target = gameManager.instance.player.transform.position;
            agent.stoppingDistance = stoppingDis;
            targetingPlayer = true;
        }
    }

    //Melee attack
    public override IEnumerator attack()
    {
        //Shoots a raycast and checks if the hit object can be damaged
        RaycastHit hit;
        if(Physics.Raycast(dropTrans.transform.position, transform.forward, out hit, range))
        {
            if (hit.collider.GetComponent<IDamage>() != null && hit.collider.tag != "Enemy")
            {
                isAttacking = true;
                anim.SetTrigger("cast3");
                hit.collider.GetComponent<IDamage>().TakeDamage(damage);
                yield return new WaitForSeconds(attackSpeed);
            }
        }

        isAttacking = false;
    }

    public override void death()
    {
        base.death();

        if (target == gameManager.instance.fireplace.transform.position)
            spawnManager.instance.enemiesTargetingFire--;
        else if (target == gameManager.instance.shop.transform.position)
            spawnManager.instance.enemiesTargetingShop--;

        spawnManager.instance.enemyDeath();
    }
}
