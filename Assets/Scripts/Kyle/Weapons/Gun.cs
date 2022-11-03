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
    [SerializeField] public float reloadSpeed;
    public bool isReloading;
    public Camera fpsCam;
    public ParticleSystem muzzleFlash;
    private float nextTimeToFire = 0f;
    void Update()
    {
        if(bullets > 0 && !isReloading)
        {
            Shoot();
        }
        else if(bullets == 0 && !isReloading)
        {
            StartCoroutine(ReloadGun());
        }
        
    }

    IEnumerator ReloadGun()
    {
        if (reserveAmmo <= 0) yield return new WaitForEndOfFrame();
        isReloading = true;
        Debug.Log("Reloading Weapon");
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
            
        isReloading = false;
    }

    public void Shoot()
    {
            if (Input.GetButtonDown("Shoot") && Time.time >= nextTimeToFire)
            {
                nextTimeToFire = Time.time + 1f / fireRate;
                FiredBulletRay();
                Debug.Log("Shot a bullet");
                bullets--;
            }
    }

    public void FiredBulletRay()
    {
        muzzleFlash.Play();
        RaycastHit hit;
        if(Physics.Raycast(fpsCam.transform.position, fpsCam.transform.forward, out hit, range)){
            if (hit.collider.GetComponent<IDamage>() != null)
                hit.collider.GetComponent<IDamage>().TakeDamage(damage);
        }
    }
}