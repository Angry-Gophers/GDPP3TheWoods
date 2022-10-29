using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spawnManager : MonoBehaviour
{
    [Header("----- Components -----")]
    [SerializeField] List<GameObject> spawnList = new List<GameObject>();
    [SerializeField] GameObject phantom;
    public static spawnManager instance;

    [Header("----- Wave stats -----")]
    [SerializeField] int wave;
    [SerializeField] int enemyLimit;
    [SerializeField] int maxLimit;
    [SerializeField] float spawnRate;
    [SerializeField] int atTheSameTime;

    int enemiesInScene;
    bool spawning;

    void Start()
    {
        instance = this;
        GameObject[] locations = GameObject.FindGameObjectsWithTag("SpawnPos");

        for(int i = 0; i < locations.Length; i++)
        {
            spawnList.Add(locations[i]);
        }

        startWave();
    }

    void Update()
    {
        if (enemiesInScene < enemyLimit && !spawning)
            StartCoroutine(spawnMore());
    }

    void startWave()
    {
        wave++;

        for(int i = 0;i < spawnList.Count; i++)
        {
            spawnEnemy(i);
        }
    }

    IEnumerator spawnMore()
    {
        spawning = true;
        int spawned = 0;

        while(spawned < atTheSameTime)
        {
            spawnEnemy(Random.Range(0, spawnList.Count)); 
            spawned++;
        }

        yield return new WaitForSeconds(spawnRate);
        spawning = false;
    }

    public void enemyDeath()
    {
        enemiesInScene--;
    }

    void spawnEnemy(int location)
    {
        if(enemiesInScene < enemyLimit)
        {
            enemiesInScene++;
            Instantiate(phantom, spawnList[location].transform.position, spawnList[location].transform.rotation);
        }
    }
}
