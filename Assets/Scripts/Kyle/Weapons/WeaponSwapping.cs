using UnityEngine;

public class WeaponSwapping : MonoBehaviour
{
    public int selectedWeapon = 0;


    public void Start()
    {
        SelectGun();
    }

    public void Update()
    {
        SwitchGun();
    }


    public void SelectGun()
    {
        int i = 0;
        foreach(Transform gun in transform)
        {
            if(i == selectedWeapon)
                gun.gameObject.SetActive(true);
            else
                gun.gameObject.SetActive(false);
            i++;
        }
    }
    public void SwitchGun()
    {

        int prevWeapon = selectedWeapon;
        if (Input.GetAxis("Mouse ScrollWheel") > 0f)
        {
            if (selectedWeapon >= transform.childCount - 1)
            {
                selectedWeapon = 0;
            }
            else
            {
                selectedWeapon++;
            }
        }
        if (Input.GetAxis("Mouse ScrollWheel") < 0f)
        {
            if (selectedWeapon <= 0)
            {
                selectedWeapon = transform.childCount - 1;
            }
            else
            {
                selectedWeapon--;
            }
        }

        if(prevWeapon != selectedWeapon)
        {
            SelectGun();
        }
    }
}
