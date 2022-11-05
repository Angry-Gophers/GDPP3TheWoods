using UnityEngine;

public class CameraControls : MonoBehaviour
{
    [SerializeField] float horSens;
    [SerializeField] float vertSens;
    [SerializeField] float lookVertMax;
    [SerializeField] float lookVertMin;
    float xRotation;
     public bool invert = true;
    void Start()
    {
        // Lock cursor to center and make invisible
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }
    void LateUpdate()
    {
        // Camera input
        float mouseX = Input.GetAxis("Mouse X") * Time.deltaTime * horSens;
        float mouseY = Input.GetAxis("Mouse Y") * Time.deltaTime * vertSens;
        if (invert)
        {
            xRotation -= mouseY;
        }
        else
        {
            xRotation += mouseY;
        }
        // Clamp xRotation
        xRotation = Mathf.Clamp(xRotation, lookVertMin, lookVertMax);
        // Rotate camera
        transform.localRotation = Quaternion.Euler(xRotation, 0, 0);
        // Rotate player
        transform.parent.Rotate(Vector3.up * mouseX);
    }
}