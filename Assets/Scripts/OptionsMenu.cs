using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OptionsMenu : MonoBehaviour
{
    public GameObject cam;
    public static bool invert;
    public static float sensetivity;
    [SerializeField] Slider sens;

    private void Start()
    {
        sensetivity = 1;
    }
    public void InvertCamera()
    {
        invert = !invert;
    }

    public void SetSensitivity()
    {
        sensetivity = sens.value;
    }
}
