using UnityEngine;

public class WeaponSwapping : MonoBehaviour
{
    public int selectedWeapon = 0;
    public GameObject weapon;
    public static WeaponSwapping instance;
    [SerializeField] Animator anim;

    public void Start()
    {
        instance = this;
        SelectGun();
    }

    public void Update()
    {
        if (gameManager.instance.gunContainer.activeSelf)
            SwitchGun();
        
    }

    public void Restock()
    {
        weapon.GetComponent<Gun>().restockAmmo();
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
                gameManager.instance.UpdatePlayerHUD();
            }
            else
                gun.gameObject.SetActive(false);
            i++;
        }
    }
    public void SwitchGun()
    {
        if (!gameManager.instance.isPaused)
        {
            int prevWeapon = selectedWeapon;
            gameManager.instance.reloadText.SetActive(false);
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
            anim.SetBool("LongGun", weapon.GetComponent<Gun>().isLongGun);

            gameManager.instance.UpdateGunHud(weapon.GetComponent<Gun>().iconValue);
        }
    }
}
