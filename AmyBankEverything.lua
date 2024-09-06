-- Event to track when the player is at a bank
local isAtBank = false

-- Add UI button
AmyBankButtonGroup = {
    {
        name = "Move to Bank",
        keybind = "UI_SHORTCUT_QUATERNARY",
        callback = function() MoveItemsToBank() end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
}

local function OnBankOpen(eventCode)
	KEYBIND_STRIP:AddKeybindButtonGroup(AmyBankButtonGroup)
    isAtBank = true
end

local function OnBankClose(eventCode)
	KEYBIND_STRIP:RemoveKeybindButtonGroup(AmyBankButtonGroup)
    isAtBank = false
end

-- Function to move items from the selected inventory tab to the bank
function MoveItemsToBank()
	local totalItemsMoved = 0
	
    if not isAtBank then
        d("You must be at a bank to transfer items.")
        return
    end

    local bagId = BAG_BACKPACK  -- Default to the player's backpack

    -- Get the current inventory tab, assuming "Backpack" as default
    local currentFilter = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].currentFilter
    if currentFilter == ITEMFILTERTYPE_BANK then
        d("You're already in the bank tab!")
        return
    end

-- Loop through all items in the selected inventory tab
    for slotIndex = 0, GetBagSize(bagId) - 1 do
        local itemLink = GetItemLink(bagId, slotIndex)
        local stackCount = GetItemTotalCount(bagId, slotIndex)

        if itemLink ~= "" and stackCount > 0 then
            -- Pickup the item from the backpack and place it in the bank
            --PickupInventoryItem(bagId, slotIndex)
			CallSecureProtected("PickupInventoryItem", bagId, slotIndex)
			BankFirstEmpty = FindFirstEmptySlotInBag(BAG_BANK)
			CallSecureProtected("PlaceInInventory", BAG_BANK, BankFirstEmpty)
            if CallSecureProtected("PlaceInTransfer", BAG_BANK) then
				totalItemsMoved = totalItemsMoved + 1
            end
        end
	end
	
	-- Print the total number of items moved (thought this was causing the messaging spam error but it is not)
	--[[
    if totalItemsMoved > 0 then
        d("Moved a total of " .. totalItemsMoved .. " items to the bank.")
    else
        d("No items were moved.")
    end
	]]
end

-- Keybinding function
local function OnKeyBindingPressed()
    MoveItemsToBank()
end

-- Register for the bank open/close events
EVENT_MANAGER:RegisterForEvent("AmyBankEverything", EVENT_OPEN_BANK, OnBankOpen)
EVENT_MANAGER:RegisterForEvent("AmyBankEverything", EVENT_CLOSE_BANK, OnBankClose)

-- Register the keybinding to call our function
ZO_CreateStringId("SI_BINDING_NAME_AMYBANKEVERYTHING_MOVEITEMS", "Move Items to Bank")
SLASH_COMMANDS["/movetobank"] = OnKeyBindingPressed

