using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
// add using statement for the gameManager layer
// add TextMeshPro stuff
// please create namespaces for each folder for an appropriate layer
// TopLayer requires access to lower layers, lower layers do not need higher layers
// The player does not need access to the UI, but the UI needs access to the player through the gamemanager

// SOLID
// DRY
// - tomorrow I am going to work on this more, let me know what you all think

// The playerScript should have two different scripts for moving vs shooting for example
// Just trying to clean up the code and I will flesh more of the Shop out after work tomorrow

namespace TheWoods.TopLayer
{
    public class ShopUI : MonoBehaviour
    {
        public List<ShopItems> store { get; set; }
        [SerializeField] public List<Button> storeButtons = new List<Button>();
        void Start()
        {
            store = new List<ShopItems>() {
              new ShopItems() {
                ItemName = "Bandage",
                AntlerCost = 0,
                EctoplasmCost = 10
              },
              new ShopItems() {
                ItemName = "Trap",
                AntlerCost = 1,
                EctoplasmCost = 20
              },
              new ShopItems() {
                ItemName = "Candle",
                AntlerCost = 5,
                EctoplasmCost = 30
              }
            };
            CanBuy();

        }

        // Update is called once per frame
        void Update()
        {
        }

        private void CanBuy()
        {
            foreach (ShopItems item in store)
            {
                if (gameManager.instance.playerScript.antlers >= item.AntlerCost && gameManager.instance.playerScript.ectoplasm >= item.EctoplasmCost)
                {
                    EnabledButton(item, true);
                }
                else
                {
                    EnabledButton(item, false);
                }
            }
        }

        private void EnabledButton(ShopItems item, bool isEnabled)
        {
            foreach (Button button in storeButtons)
            {
                if (button.name == item.ItemName)
                {
                    button.interactable = isEnabled;
                }
            }
        }
        
        public void GetTrap()
        {
            gameManager.instance.playerScript.trapsHeld++;
            for(int x = 0; x < store.Count; x++)
            {
                if(store[x].ItemName == "Trap")
                {
                    gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                    gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                }
            }
            CanBuy();
            //update HUD display
        }

        public void GetBandage()
        {
            gameManager.instance.playerScript.bandagesHeld++;
            for (int x = 0; x < store.Count; x++)
            {
                if (store[x].ItemName == "Bandage")
                {
                    gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                    gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                }
            }
            CanBuy();
            //update HUD
        }

        public void GetCandle()
        {
            gameManager.instance.playerScript.candlesHeld++;
            for (int x = 0; x < store.Count; x++)
            {
                if (store[x].ItemName == "Candle")
                {
                    gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                    gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                }
            }
            CanBuy();
            //update HUD
        }

        public void CloseShop()
        {
            gameManager.instance.shopWindow.SetActive(false);
            gameManager.instance.cursorUnlockUnpause();
        }

        public void OpengunShop()
        {
            gameManager.instance.gunShopWindow.SetActive(true);
        }
    }
}