using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spawnManager : MonoBehaviour
{
    [Header("----- Components -----")]
    [SerializeField] List<GameObject> spawnList = new List<GameObject>();
    [SerializeField] List<GameObject> enemies = new List<GameObject>();
    [SerializeField] GameObject phantom;
    public static spawnManager instance;

    [Header("----- Wave stats -----")]
    [SerializeField] int wave;
    [SerializeField] int enemyLimit;
    [SerializeField] int maxLimit;
    [SerializeField] float spawnRate;
    [SerializeField] int atTheSameTime;
    [SerializeField] int waveLength;

    int enemiesInScene;
    bool spawning;
    bool firstSpawn;

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
        //Increment wave
        wave++;
        firstSpawn = true;

        //Increase difficulty
        if(wave % 3 == 0)
        {
            if(spawnRate > 1)
                spawnRate -= .5f;

            if (atTheSameTime < 5)
                atTheSameTime++;
        }

        if (wave != 1 && enemyLimit < maxLimit)
            enemyLimit += 2;

        //Spawn an enemy at every position
        for(int i = 0;i < spawnList.Count; i++)
        {
            spawnEnemy(i);
        }

        //Start wave timer
        StartCoroutine(waveTimer());
    }

    IEnumerator spawnMore()
    {
        spawning = true;
        int spawned = 0;

        while(spawned < atTheSameTime && !firstSpawn)
        {
            spawnEnemy(Random.Range(0, spawnList.Count)); 
            spawned++;
        }

        firstSpawn = false;

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
            GameObject spawned = Instantiate(phantom, spawnList[location].transform.position, spawnList[location].transform.rotation);
            enemies.Add(spawned);
        }
    }

    IEnumerator waveTimer()
    {
        yield return new WaitForSeconds(waveLength);

        for(int i = 0; i < enemies.Count; i++)
        {
            enemies[i].GetComponent<enemyBase>().death();
        }

        startWave();
    }
}
