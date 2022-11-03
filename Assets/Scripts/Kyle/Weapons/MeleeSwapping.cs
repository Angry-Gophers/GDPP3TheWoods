using UnityEngine;

public class MeleeSwapping : MonoBehaviour
{
    public int selectedWeapon = 0;

    public void Update()
    {
        if(gameManager.instance.meleeContainer.activeSelf)
            SwitchMelee();
    }


    public void SelectMelee()
    {
        int i = 0;
        foreach (Transform melee in transform)
        {
            if (i == selectedWeapon)
                melee.gameObject.SetActive(true);
            else
               melee.gameObject.SetActive(false);
            i++;
        }
    }
    public void SwitchMelee()
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
            SelectMelee();
        }
    }
}