using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class buttonFunctions : MonoBehaviour
{
   public void resume()
    {
        gameManager.instance.cursorUnlockUnpause();
        gameManager.instance.pauseMenu.SetActive(false);
        gameManager.instance.isPaused = false;
        gameManager.instance.menuCurrentlyOpen = null;

    }
    public void restart()
    {
        gameManager.instance.cursorUnlockUnpause();
        gameManager.instance.menuCurrentlyOpen = null;
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);

    }
    public void quit()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex - 1);
    }
}
