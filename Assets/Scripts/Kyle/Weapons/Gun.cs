using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Gun : MonoBehaviour
{
    [SerializeField] public int damage;
    [SerializeField] public int range;
    [SerializeField] public float fireRate;
    [SerializeField] public int magazine;
    [SerializeField] public int bullets;
    [SerializeField] public int reserveAmmo;
    [SerializeField] public int maxReserve;
    [SerializeField] public float reloadSpeed;
    [SerializeField] AudioSource aud;
    [SerializeField] AudioClip shotAud;
    [SerializeField] float shotVol;
    [SerializeField] AudioClip reloadAud;
    [SerializeField] float reloadVol;
    [SerializeField] Animator anim;
    public bool isReloading;
    public bool fullAuto;
    public Camera fpsCam;
    public ParticleSystem muzzleFlash;
    private float nextTimeToFire = 0f;
    void Update()
    {
        if(bullets > 0 && !isReloading)
        {
            Shoot();
        }
        else if(bullets == 0 && !isReloading && reserveAmmo > 0)
        {
            StartCoroutine(ReloadGun());
        }
        
    }

    IEnumerator ReloadGun()
    {
        if (reserveAmmo <= 0) yield return new WaitForEndOfFrame();
        isReloading = true;

        gameManager.instance.reloadText.active = true;
        aud.PlayOneShot(reloadAud, reloadVol);

        yield return new WaitForSeconds(reloadSpeed);
        if(reserveAmmo >= magazine)
        {
            bullets = magazine;
            reserveAmmo -= magazine;
        }
        else if(reserveAmmo < magazine)
        {
            bullets = reserveAmmo;
            reserveAmmo = 0;
        }
            
        gameManager.instance.reloadText.active = false;
        gameManager.instance.UpdatePlayerHUD();
        isReloading = false;
    }

    public void Shoot()
    {
        if (!fullAuto)
        {
            if (Input.GetButtonDown("Shoot") && Time.time >= nextTimeToFire)
            {
                nextTimeToFire = Time.time + 1f / fireRate;
                FiredBulletRay();
                aud.PlayOneShot(shotAud, shotVol);
                anim.SetTrigger("Shoot");
                bullets--;
            }
        }
        else
        {
            if (Input.GetButton("Shoot") && Time.time >= nextTimeToFire)
            {
                nextTimeToFire = Time.time + 1f / fireRate;
                FiredBulletRay();
                aud.PlayOneShot(shotAud, shotVol);
                bullets--;
            }
        }

        gameManager.instance.UpdatePlayerHUD();
    }

    public void FiredBulletRay()
    {
        muzzleFlash.Play();
        RaycastHit hit;
        if(Physics.Raycast(fpsCam.transform.position, fpsCam.transform.forward, out hit, range)){
            if (hit.collider.GetComponent<IDamage>() != null && !hit.collider.CompareTag("Fire"))
                hit.collider.GetComponent<IDamage>().TakeDamage(damage);
        }
    }

    public void restockAmmo()
    {
        bullets = magazine;
        reserveAmmo = maxReserve;
        gameManager.instance.UpdatePlayerHUD();
    }
}