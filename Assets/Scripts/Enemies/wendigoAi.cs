using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class wendigoAi : enemyBase
{
    [SerializeField] GameObject hand;
    Collider handCol;

    private void Start()
    {
        base.Start();

        hand.GetComponent<collisionAttack>().damage = damage;
        handCol = hand.GetComponent<Collider>();
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();

        if(HP > 0 && agent.enabled == true)
        {
            //Set walk animation speed
            anim.SetFloat("Speed", Mathf.Lerp(anim.GetFloat("Speed"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));
        }
    }

    public override IEnumerator attack()
    {
        hand.GetComponent<collisionAttack>().playerhit = false;
        isAttacking = true;

        anim.SetTrigger("Attacking");
        handCol.enabled = true;

        yield return new WaitForSeconds(attackSpeed);
        handCol.enabled = false;
        isAttacking = false;
    }

    public override void findTarget()
    {
        target = gameManager.instance.player.transform.position;
    }

    public override void death()
    {
        base.death();

        spawnManager.instance.eliteDeath();
    }
}
