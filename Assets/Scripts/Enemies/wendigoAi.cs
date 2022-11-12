using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class wendigoAi : enemyBase
{
    [Header ("----- Wendigo stats -----")]
    [SerializeField] GameObject hand;
    [SerializeField] float attackWindow;
    [SerializeField] float preAttackWindow;
    [SerializeField] float spawnManagerDelayTime;
    Collider handCol;

    [Header("----- Wendigo sounds -----")]
    AudioSource aud;
    [SerializeField] AudioClip staggerAud;
    [Range(0f, 1f)][SerializeField] float staggerVol;
    [SerializeField] AudioClip hurtAud;
    [Range(0f, 1f)] [SerializeField] float hurtVol;
    [SerializeField] AudioClip deadAud;
    [Range(0f, 1f)] [SerializeField] float deadVol;
    [SerializeField] AudioClip attackAud;
    [Range(0f, 1f)] [SerializeField] float attackVol;
    [SerializeField] AudioClip awakeAud;
    [Range(0f, 1f)] [SerializeField] float awakeVol;
    [SerializeField] List<AudioClip> idleSounds;
    [Range (0f, 1f)] [SerializeField] float idleVol;

    bool idle;

    private void Start()
    {
        base.Start();

        hand.GetComponent<collisionAttack>().damage = damage;
        handCol = hand.GetComponent<Collider>();
        aud = GetComponent<AudioSource>();
        handCol.enabled = false;
        targetingPlayer = true;
        aud.PlayOneShot(awakeAud, awakeVol);
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();

        if(HP > 0 && agent.enabled == true)
        {
            //Set walk animation speed
            anim.SetFloat("Speed", Mathf.Lerp(anim.GetFloat("Speed"), agent.velocity.normalized.magnitude, Time.deltaTime * 3));

            if (!isAttacking && ! idle)
            {
                StartCoroutine(IdleSound());
            }
        }
    }

    public override IEnumerator attack()
    {
        hand.GetComponent<collisionAttack>().playerhit = false;
        isAttacking = true;
        idle = false;
        aud.Stop();

        anim.SetTrigger("Attacking");
        aud.PlayOneShot(attackAud, attackVol);

        StartCoroutine(WindowOfAttack());
        yield return new WaitForSeconds(attackSpeed);
        isAttacking = false;
    }

    public override void findTarget()
    {
        target = gameManager.instance.player.transform.position;
    }

    public override void death()
    {
        base.death();

        aud.PlayOneShot(deadAud, deadVol);
        spawnManager.instance.eliteDeath();
    }

    IEnumerator WindowOfAttack()
    {
        yield return new WaitForSeconds(preAttackWindow);
        handCol.enabled = true;
        yield return new WaitForSeconds(attackWindow);
        handCol.enabled = false;
    }

    public override void TakeDamage(int dmg)
    {
        base.TakeDamage(dmg);

        if (!staggered && HP > 0)
            aud.PlayOneShot(hurtAud, hurtVol);
    }

    public override IEnumerator stagger()
    {
        if(HP > 0)
            aud.PlayOneShot(staggerAud, staggerVol);

        return base.stagger();
    }

    public IEnumerator IdleSound()
    {
        idle = true;
        aud.PlayOneShot(idleSounds[Random.Range(0, idleSounds.Count)], idleVol);
        yield return new WaitForSeconds(1.5f);
        idle = false;
    }
}
