using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControls : MonoBehaviour
{
    [SerializeField] float horSens;
    [SerializeField] float vertSens;
    [SerializeField] float lookLockVertMax;
    [SerializeField] float lookLockVertMin;
    float xRotation;
    public bool isInvert;
    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        
    }

    // Update is called once per frame
    void LateUpdate()
    {
        //Mouse input
        float mouseX = Input.GetAxis("Mouse X") * Time.deltaTime * horSens;
        float mouseY = Input.GetAxis("Mouse Y") * Time.deltaTime * vertSens;
        if (isInvert)
        {
            xRotation += mouseY;
        }
        else
        {
            xRotation -= mouseY;
        }

        //Clamp XRotation
        xRotation = Mathf.Clamp(xRotation, lookLockVertMin, lookLockVertMax);

        //Rotate on xAxis
        transform.localRotation = Quaternion.Euler(xRotation, 0, 0);

        //Rotate Player
        transform.parent.Rotate(Vector3.up * mouseX);
        
        
    }
}
