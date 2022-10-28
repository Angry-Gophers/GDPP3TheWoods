using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class phantomAi : enemyBase
{
    [SerializeField] int viewAngle;
    [SerializeField] int viewRange;
    [Range(.25f, 1f)][SerializeField] float sizeRandMin;
    [Range(1f, 2f)] [SerializeField] float sizeRandMax;

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
        anim.SetFloat("locomotion", Mathf.Lerp(anim.GetFloat("locomotion"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));

        //Target the player or the fire depending on line of sight
        if (canSeePlayer())
        {
            agent.SetDestination(gameManager.instance.player.transform.position);
        }
        else
        {
            if(agent.destination != target)
                agent.destination = target;
        }

        
    }

    public override void findTarget()
    {
        target = GameObject.FindGameObjectWithTag("Fire").transform.position;
    }

    bool canSeePlayer()
    {
        Vector3 playerDir = gameManager.instance.player.transform.position - transform.position;
        float angle = Vector3.Angle(transform.forward, playerDir);

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
    
    void attack() { }
}
