
using System.Collections.Generic;
using UnityEngine;
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
        //What this class needs to know
        // How much time is left to shop?
        // ^^ all available through the gameManager
        // What this class has to update
        // Player HUD values, Player antlers and ectoplasm, current weapons useable/ in storage?
        // This class needs to access the gameManager for the playerScript values in it's instance
        // This class is essentially button functions unrelated to other menu buttons
        // defining struct
        public struct ShopItems
        {
            public string ItemName
            {
                get { return ItemName; }
                set { ItemName = value; }
            }
            // creates property
            public int ItemCostAntlers
            {
                get { return ItemCostAntlers; }
                set { ItemCostAntlers = value; }
            }
            public int ItemCostEctoplasm
            {
                get { return ItemCostEctoplasm; }
                set { ItemCostEctoplasm = value; }
            }
        }
        public List<ShopItems> ShopItemList { get; set; }
        public void Start()
        {
            ShopItemList = new List<ShopItems>() {
              new ShopItems() {
                ItemName = "Bandage",
                ItemCostAntlers = 0,
                ItemCostEctoplasm = 10
              },
              new ShopItems() {
                ItemName = "Trap",
                ItemCostAntlers = 1,
                ItemCostEctoplasm = 20
              },
              new ShopItems() {
                ItemName = "Candle",
                ItemCostAntlers = 5,
                ItemCostEctoplasm = 30
              }
            };
        }
        void Update()
        {
            // if they can buy something, allow visibility of the button
                // Update the HUD and currency and weapons with the right method
            // else close the Shop if time is up, player closes it, etc
        }
        // Check if they can afford the item before allowing the button to be visible
            // Buy new guns
                // Check current guns first// only display unowned guns
            // Buy bandages
                // Check current bandages // only display if they can hold more
            // Buy traps
                // Check current traps // only display if they can hold more
            // Anything else?
        // Update if successful purchase
            // Unsuccessful error message
        public bool AbleToBuy()
        {
                if(gameManager.instance.playerScript.antlers >= item.ItemCostAntlers && gameManager.instance.playerScript.ectoplasm >= item.ItemCostEctoplasm)
                {
                    //enable the buttons on the panel
                    return true;
                }
            return false;
        }
        public void DisplayButtons()
        {
            foreach (ShopItems item in ShopItemList)
            {
                buttonInQuestion.setActive = AbleToBuy();
            }
        }
    }
}