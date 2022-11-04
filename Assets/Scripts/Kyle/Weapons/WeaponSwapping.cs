using UnityEngine;

public class WeaponSwapping : MonoBehaviour
{
    public int selectedWeapon = 0;
    GameObject weapon;


    public void Start()
    {
        SelectGun();
    }

    public void Update()
    {
        if (gameManager.instance.gunContainer.activeSelf)
            SwitchGun();
    }


    public void SelectGun()
    {
        int i = 0;
        foreach(Transform gun in transform)
        {
            if (i == selectedWeapon)
            {
                gun.gameObject.SetActive(true);
                weapon = gun.gameObject;
                gameManager.instance.UpdatePlayerHUD(gun.GetComponent<Gun>().bullets, gun.GetComponent<Gun>().reserveAmmo);
            }
            else
                gun.gameObject.SetActive(false);
            i++;
        }
    }
    public void SwitchGun()
    {
        if (weapon.GetComponent<Gun>().isReloading == false)
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

            if (prevWeapon != selectedWeapon)
            {
                SelectGun();
            }
        }
    }
}
