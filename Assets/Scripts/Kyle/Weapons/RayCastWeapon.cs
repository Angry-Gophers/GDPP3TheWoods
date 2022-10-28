using UnityEngine;
[CreateAssetMenu (menuName = "Gun", order = 1)]
public class RayCastWeapon : ScriptableObject
{
    // Gun Values
    [SerializeField] public GunType type;
    public string model;

    public int damage;
    public int range;
    public float reloadSpeed;

    public int magazineSize;
    public int bullets;
    public int reserveAmmo;

    // Gun Components
    public GameObject designModel;
    public AudioClip fireSound;
    // muzzle flash
    // damage hit effect
}