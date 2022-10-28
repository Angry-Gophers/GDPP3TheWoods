using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class phantomAi : enemyBase
{


    // Update is called once per frame
    void Update()
    {

    }

    public override void findTarget()
    {
        target = GameObject.FindGameObjectWithTag("Fire").transform.position;
    }
}
