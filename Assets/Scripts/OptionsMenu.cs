using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OptionsMenu : MonoBehaviour
{
    public GameObject cam;

    private void Start()
    {
        
    }
    public void InvertCamera()
    {
        gameManager.instance.cameraControlsScript.invert = !gameManager.instance.cameraControlsScript.invert;
        
    }
}
