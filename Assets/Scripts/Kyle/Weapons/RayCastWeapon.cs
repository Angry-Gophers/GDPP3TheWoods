using UnityEngine;
[CreateAssetMenu (menuName = "Create Gun", order = 1)]
public class RayCastWeapon : ScriptableObject
{
    // Gun Values
    [SerializeField] public GunTypes GunType { get; set; }
    public string ModelName { get; set; }

    public int GunDamage { get; set; }
    public int GunRange { get; set; }
    public float GunReloadSpeed { get; set; }

    public int GunMagazineSpeed { get; set; }
    public int GunBullets { get; set; }
    public int GunReserveAmmo { get; set; }

    // Gun Components
    public GameObject GunDesignModel { get; set; }
    public AudioClip GunFireSound { get; set; }
    // muzzle flash
    // damage hit effect
}