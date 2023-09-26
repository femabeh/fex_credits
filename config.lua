-- The Framework which is used
ESX = exports["es_extended"]:getSharedObject()

-- Keys
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, 
    ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, 
    ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, 
    ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, 
    ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Config = {
    Debug = ESX.GetConfig().EnableDebug, --Enables the debug function
    Open = Keys['E'], --Change the Key also in the Translation!
    Locale = GetConvar('esx:local', 'de'), --Translation
    Pos = vector3(251.5550, 221.4640, 105.2866), --Position, where you can manage your credit
    Account = 'bank', --Account from that money get removed and added
    Payout = true, --Should part of the Credit be paid off with each payout?
    MaxCreditHeight = 100000, --The Maximum amount for Credits. It cant be higher!
    MinCreditHeight = 10000, --The Minimumg amount for Credits. It cant be lower!
    MaxPayheight = 1000, --The maximum height of paybacks while the Payout.
    MinPayheight = 100, --The minimum height of paybacks while the Payout.
    Fine = 3, --The Money to pay, if the player cant pay (in percent of remaining credit!)
}

Config.Marker = {
	type = 1,
    size = 1.75,
    red = 204,
    green = 0,
    blue = 0,
}

Config.Blip = {
    Activate = true,
    sprite = 374,
    color = 0,
    title = 'Kredit-System',
}

Config.Webhook = {
    use = true,
    Webhook = 'https://discord.com/api/webhooks/1081213462266531860/plbeqh-rfFT10AZyWcRSFgCLjeESiI1asYO9D_tgGHqHqnk2hV27W2OWUtLy665uORlY',
}

--Debug Function (Activates when Config.Debug is true/ESX Debug is true)
function print_r( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end
