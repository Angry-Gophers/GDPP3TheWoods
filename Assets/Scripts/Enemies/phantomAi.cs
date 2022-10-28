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

    Vector3 playerDis;

    private void Start()
    {
        base.Start();

        float size = Random.Range(sizeRandMin, sizeRandMax);
        gameObject.transform.transform.localScale = new Vector3 (size, size, size);

        agent.speed *= 1 / size;
        originalSpeed = agent.speed;
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();

        anim.SetFloat("locomotion", Mathf.Lerp(anim.GetFloat("locomotion"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));
        playerDis = gameManager.instance.player.transform.position - transform.position;
        angle = Vector3.Angle(transform.forward, playerDis);

        //Target the player or the fire depending on line of sight
        if (canSeePlayer())
        {
            targetDir = playerDis;

            agent.SetDestination(gameManager.instance.player.transform.position);
            faceTarget();
        }
        else
        {
            if(agent.destination != target)
                agent.destination = target;

            targetDir = target - transform.position;

            faceTarget();
        }

        if(agent.stoppingDistance >= agent.remainingDistance && !isAttacking)
        {
            StartCoroutine(attack());
        }
    }

    public override void findTarget()
    {
        target = GameObject.FindGameObjectWithTag("Fire").transform.position;
    }

    bool canSeePlayer()
    {
        RaycastHit hit;

        if(Physics.Raycast(eyes.transform.position, playerDis, out hit, viewRange))
        {
            if (hit.collider.CompareTag("Player") && angle <= viewAngle)
                return true;
            else
                return false;
        }
        else
            return false;
    }

    void faceTarget()
    {
        targetDir.y = 0;
        Quaternion rotation = Quaternion.LookRotation(targetDir);
        transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * 4);
    }

    IEnumerator attack()
    {
        isAttacking = true;

        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward, out hit, range))
        {
            if (hit.collider.GetComponent<IDamage>() != null)
                hit.collider.GetComponent<IDamage>().takeDamage(damage);
        }

        yield return new WaitForSeconds(attackSpeed);
        isAttacking = false;
    }
}
