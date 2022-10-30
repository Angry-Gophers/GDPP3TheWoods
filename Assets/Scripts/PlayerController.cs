using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDamage
{
    [Header("---Components---")]
    [SerializeField] CharacterController playerController;
    [Header("---Player Stats---")]
    [SerializeField] int HP;
    [SerializeField] float playerSpeed;
    [SerializeField] float jumpHeight;
    [SerializeField] int maxJumps;
    [SerializeField] float gravityValue;
    [SerializeField] int hpOriginal;
    [Header("---Player Weapon Stats---")]
    [SerializeField] RayCastWeapon startingPistol;
    [SerializeField] int shootDmg;
    [SerializeField] float shootDist;
    [SerializeField] float reloadTime;
    [SerializeField] float shootRate;// Kyle- I may not do it this way this time, I am looking at using an enum or attached ScriptableObject
    public bool isShooting = false;
    public bool isReloading = false;
    public GunType weaponType;
    [SerializeField] GameObject gunModel;
    Vector3 playervelocity;
    int timesJumped;
    // Create <ListofWeapons> data container for everything but the knife which is handled differently
    [SerializeField] public List<RayCastWeapon> gunListStats = new List<RayCastWeapon>();
    int selectedGun;
    // Start is called before the first frame update
    void Start()
    {
        HP = hpOriginal;
        
        gunListStats.Add(startingPistol);
        selectedGun = gunListStats.Count - 1;
        weaponType = GetCurrentWeaponType(startingPistol);
    }

    // Update is called once per frame
    void Update()
    {
        movement();
        jump();
        StartCoroutine(shoot());
        // call weaponSwapping(); if they aren't shooting or reloading
    }

    // Gets the weapon type
    GunType GetCurrentWeaponType(RayCastWeapon gun)
    {
        return gunListStats[selectedGun].type;
    }
    
    void movement()
    {
        if (playerController.isGrounded && playervelocity.y < 0)
        {
            timesJumped = 0;
            playervelocity.y = 0;
        }

        Vector3 move = transform.right * (Input.GetAxis("Horizontal")) + transform.forward * (Input.GetAxis("Vertical"));
        playerController.Move(move * Time.deltaTime * playerSpeed);
    }

    void jump()
    {

        if(Input.GetButton("Jump")&& timesJumped < maxJumps)
        {
            timesJumped++;
            playervelocity.y = jumpHeight;
        }
        playervelocity.y -= gravityValue * Time.deltaTime;
        playerController.Move(playervelocity * Time.deltaTime);


    }
    IEnumerator shoot()
    {
        if(weaponType == GunType.SemiAuto)
        {
            if (Input.GetButtonDown("Shoot") && !isShooting)
            {
                isShooting = true;
                Debug.Log("Shooting SemiAuto");
                FiredBulletRay();
                yield return new WaitForEndOfFrame();
                isShooting = false;
            }
        }
        else if(weaponType == GunType.Auto)
        {
            if (Input.GetButton("Shoot") && !isShooting)
            {
                isShooting = true;
                Debug.Log("Shooting Auto");
                FiredBulletRay();
                yield return new WaitForSeconds(.017f);
                isShooting = false;
            }
        }else if(weaponType == GunType.Burst)
        {
            if (Input.GetButton("Shoot") && !isShooting)
            {
                isShooting = true;
                Debug.Log("Shooting Burst");
                FiredBulletRay();
                yield return new WaitForSeconds(.3f);
                isShooting = false;
            }
        }else if(weaponType == GunType.Single)
        {
            if (Input.GetButtonDown("Shoot") && !isShooting)
            {
                isShooting = true;
                Debug.Log("Shooting Single");
                FiredBulletRay();
                yield return new WaitForSeconds(1f);
                isShooting = false;
            }
        }
    }
    // Reloading specific to the weapon
    IEnumerator reloading()
    {
        isReloading = true;
        //reload the weapon
        yield return new WaitForSeconds(1);//currentWeapons reloadTime);
        isReloading = false;
    }

    // Weapon Swapping
    void weaponSwapping()
    {
        // Swap weapon logic
        //if(they press the melee button ){
        //  get the melee weapon  
        //}else{
        //  get the gun
        //}
        switchGun();
    }

    public void switchGun()
    {
        if (gunListStats.Count > 0)
        {
            if (Input.GetAxis("Mouse ScrollWheel") > 0 && selectedGun < gunListStats.Count - 1)
            {
                selectedGun++;
                swapGunStats(gunListStats[selectedGun]);
            }
            else if (Input.GetAxis("Mouse ScrollWheel") < 0 && selectedGun > 0)
            {
                selectedGun--;
                swapGunStats(gunListStats[selectedGun]);
            }
        }
    }

    void swapGunStats(RayCastWeapon stats)
    {
        GetCurrentWeaponType(stats);
        shootDmg = stats.damage;
        shootDist = stats.range;
        reloadTime = stats.reloadSpeed;
        //gunFireSound = stats.fireSound;
        gunModel.GetComponent<MeshFilter>().sharedMesh = stats.designModel.GetComponent<MeshFilter>().sharedMesh;
        gunModel.GetComponent<MeshRenderer>().sharedMaterial = stats.designModel.GetComponent<MeshRenderer>().sharedMaterial;
        //gameManager.instance.updateAmmoCount(stats.bullets, stats.reserveAmmo);
    }

    private void FiredBulletRay()
    {
        RaycastHit hit;
        if (Physics.Raycast(Camera.main.ViewportPointToRay(new Vector2(0.5f, 0.5f)), out hit, shootDist))
        {
            if (hit.collider.GetComponent<IDamage>() != null)
            {
                hit.collider.GetComponent<IDamage>().takeDamage(shootDmg);
            }
        }
    }

    public void takeDamage(int dmg)
    {
        HP -= dmg;
        if(HP <= 0)
        {
            Debug.Log("You Died");
        }

    }
}
