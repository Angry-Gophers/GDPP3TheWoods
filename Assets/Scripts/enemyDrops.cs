using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class enemyDrops : MonoBehaviour
{
    [SerializeField] int type;
    [SerializeField] List<AudioClip> audio;
    [SerializeField] float audioVol;

    AudioSource aud;
    Collider col;
    MeshRenderer mr;
    Light light;

    // Start is called before the first frame update
    void Start()
    {
        aud = GetComponent<AudioSource>();
        col = GetComponent<Collider>();
        mr = GetComponent<MeshRenderer>();
        light = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<PlayerController>().pickedUp(type);

            if(audio.Count > 0)
                aud.PlayOneShot(audio[Random.Range(0, audio.Count)], audioVol);

            gameManager.instance.UpdatePlayerHUD();

            col.enabled = false;
            mr.enabled = false;
            light.enabled = false;
            Destroy(gameObject, 1f);
        }
    }
}
