using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;

public class OptionsMenu : MonoBehaviour
{
    public GameObject cam;
    public static bool invert;
    public static float sensetivity;
    public static float volume;
    [SerializeField] Slider sens;
    [SerializeField] Slider vol;
    [SerializeField] Toggle invertButton;
    [SerializeField] AudioMixer mixer;

    static bool firstLaunch = true;

    private void Start()
    {
        if (firstLaunch)
        {
            sensetivity = 1;
            volume = 1;
            invert = false;
            firstLaunch = false;
        }

        sens.value = sensetivity;
        invertButton.isOn = invert;
        vol.value = volume;
        mixer.SetFloat("MasterVol", Mathf.Log10(vol.value) * 20);
    }
    public void InvertCamera()
    {
        invert = !invert;
    }

    public void SetSensitivity()
    {
        sensetivity = sens.value;
    }

    public void setVolume()
    {
        mixer.SetFloat("MasterVol", Mathf.Log10(vol.value) * 20);
        volume = vol.value;
    }
}
