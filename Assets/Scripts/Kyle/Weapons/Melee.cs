using UnityEngine;
[CreateAssetMenu]
public class Melee : ScriptableObject
{
    // Weapon Values
    public string Name;

    public int Damage;
    public int Range;
    public float SwingSpeed;

    // Weapon Components
    public GameObject DesignModel;
    public AudioClip SwingSound;
    // damage hit effect
}
