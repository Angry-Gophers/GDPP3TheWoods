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
        fireplace fire;
        [SerializeField] int candleBonus;

        bool reloadUpgraded;

        void Start()
        {
            fire = gameManager.instance.fireplace.GetComponent<fireplace>();

            store = new List<ShopItems>() {
              new ShopItems() {
                ItemName = "Bandage",
                AntlerCost = 0,
                EctoplasmCost = 5
              },
              new ShopItems() {
                ItemName = "Trap",
                AntlerCost = 0,
                EctoplasmCost = 5
              },
              new ShopItems() {
                ItemName = "Candle",
                AntlerCost = 5,
                EctoplasmCost = 0
              },
              new ShopItems()
              {
                  ItemName = "Weapons Training",
                  AntlerCost = 0,
                  EctoplasmCost = 20
              },
              new ShopItems() {
                  ItemName = "Thicker Metal",
                  AntlerCost = 5,
                  EctoplasmCost = 0
              }
            };
            CanBuy();
        }

        private void OnEnable()
        {
            CanBuy();
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

            foreach(Button button in storeButtons)
            {
                if(button.name == "Weapons Training" && reloadUpgraded)
                {
                    button.interactable = false;
                    button.enabled = false;
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
                    button.enabled = isEnabled;
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

            gameManager.instance.shopEcto.text = "Ectoplasm: " + gameManager.instance.playerScript.ectoplasm;
            gameManager.instance.shopAntler.text = "Antlers: " + gameManager.instance.playerScript.antlers;
            CanBuy();
            gameManager.instance.UpdatePlayerHUD();
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

            gameManager.instance.shopEcto.text = "Ectoplasm: " + gameManager.instance.playerScript.ectoplasm;
            gameManager.instance.shopAntler.text = "Antlers: " + gameManager.instance.playerScript.antlers;
            CanBuy();
            gameManager.instance.UpdatePlayerHUD();
            //update HUD
        }

        public void GetCandle()
        {
            if (fire.HP < fire.maxHP)
            {
                fire.HP += candleBonus;

                if(fire.HP > fire.maxHP)
                    fire.HP = fire.maxHP;

                fire.UpdateFireHud();

                for (int x = 0; x < store.Count; x++)
                {
                    if (store[x].ItemName == "Candle")
                    {
                        gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                        gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                    }
                }

                gameManager.instance.shopEcto.text = "Ectoplasm: " + gameManager.instance.playerScript.ectoplasm;
                gameManager.instance.shopAntler.text = "Antlers: " + gameManager.instance.playerScript.antlers;
                CanBuy();
            }
        }

        public void WeaponHandling()
        {
            gameManager.instance.reloadSpeed = .75f;
            reloadUpgraded = true;
            for (int x = 0; x < store.Count; x++)
            {
                if (store[x].ItemName == "Weapons Training")
                {
                    gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                    gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                }
            }

            gameManager.instance.shopEcto.text = "Ectoplasm: " + gameManager.instance.playerScript.ectoplasm;
            gameManager.instance.shopAntler.text = "Antlers: " + gameManager.instance.playerScript.antlers;
            CanBuy();
            gameManager.instance.UpdatePlayerHUD();
            //update HUD
        }

        public void UpgradeCar()
        {
            gameManager.instance.shopScript.Upgrade();
            gameManager.instance.shopScript.UpdateHud();
            for (int x = 0; x < store.Count; x++)
            {
                if (store[x].ItemName == "Thicker Metal")
                {
                    gameManager.instance.playerScript.antlers -= store[x].AntlerCost;
                    gameManager.instance.playerScript.ectoplasm -= store[x].EctoplasmCost;
                }
            }

            gameManager.instance.shopEcto.text = "Ectoplasm: " + gameManager.instance.playerScript.ectoplasm;
            gameManager.instance.shopAntler.text = "Antlers: " + gameManager.instance.playerScript.antlers;
            CanBuy();
            gameManager.instance.UpdatePlayerHUD();
            //update HUD
        }

        public void CloseShop()
        {
            gameManager.instance.shopWindow.SetActive(false);
            gameManager.instance.menuCurrentlyOpen = null;
            gameManager.instance.cursorUnlockUnpause();
        }

        public void OpengunShop()
        {
            gameManager.instance.gunShopWindow.SetActive(true);
        }
    }
}