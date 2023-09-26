ESX = nil

CreateThread(function()
    ESX = exports["es_extended"]:getSharedObject()
    while ESX.GetPlayerData().job == nil do Wait(100) end
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
  PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

Citizen.CreateThread(function() --Blip
    if Config.Blip.Activate then
        blip = AddBlipForCoord(Config.Pos.x, Config.Pos.y, Config.Pos.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.title)
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function() --Open Menu
    while true do
		Citizen.Wait(0)
        DrawMarker(Config.Marker.type, Config.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Marker.size, Config.Marker.size, Config.Marker.size, Config.Marker.red, Config.Marker.green, Config.Marker.blue, 100, false, true, 2, false, false, false, false)

        if GetDistanceBetweenCoords(Config.Pos.x, Config.Pos.y, Config.Pos.z, GetEntityCoords(GetPlayerPed(-1))) < 1.0 then
            if not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'MainMenu') then
                ESX.ShowHelpNotification(_U('open'))
                if IsControlJustPressed(0, Config.Open) then
                    OpenMainMenu()
                    SendWebhook('Credit', 'Spieler Öffnet Menü')
                end
            end
        end
    end
end)

function OpenMainMenu() --Main Menu
    ESX.TriggerServerCallback('fex_credits:getCredit', function(data)
        local elements = {}

        if #data > 0 then
            table.insert(elements, {label = _U('Credit')..data[1].height.._U('Currency'), value = 'existingcredit', creditdata = data[1]})
            if Config.Debug then
                print_r(data[1])
            end
        else
            table.insert(elements, {label = _U('NewCredit'), value = 'newcredit'})
            if Config.Debug then
                print('No Credit for this user!')
            end
        end

        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'MainMenu',
        {
            title    = (_U('title')),
            align    = 'top-left',
            elements = elements,
        },
        function(data_main, menu_main)
            if data_main.current.value == 'existingcredit' then
                OpenExistingCreditMenu(data_main.current.creditdata)
            elseif data_main.current.value == 'newcredit' then
                OpenNewCreditMenu()
            end
        end, function(data_main, menu_main)
            menu_main.close()
        end)
    end)
end

function OpenExistingCreditMenu(CreditData)
    local elements_existing = {
        {label = _U('Existing_Payback'), value = 'payback'},
        {label = _U('Existing_Pay_height'), value = 'set_payheight'},
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'ExistingMenu',
    {
        title    = (_U('title')),
        align    = 'top-left',
        elements = elements_existing,
    },
    function(data_existing, menu_existing)
        if data_existing.current.value == 'payback' then
            local amount = KeyboardInput('BOX_ID', _U('dialogbox_amount'), '', string.len(CreditData.height))
            if amount then
                if tonumber(amount) > tonumber(CreditData.height) then
                    ESX.ShowNotification(_U('Existing_Payback_tooheightamount'))
                elseif tonumber(amount) < 0 then
                    ESX.ShowNotification(_U('Existing_Payback_toolowamount'))
                elseif not (tonumber(amount) < 0) and not (tonumber(amount) > tonumber(CreditData.height)) then
                    local residualmoney = tonumber(CreditData.height) - tonumber(amount)
                    TriggerServerEvent('fex_credits:setCreditHeight', GetPlayerServerId(PlayerId()), residualmoney)
                    ESX.ShowNotification(_U('Existing_Payback_succesfull') .. residualmoney)
                    menu_existing.close()
                    SendWebhook('Credit', 'Zurückgezahlt: '..tonumber(amount)..' - Übrig: '..residualmoney)
                end
            else
                ESX.ShowNotification(_U('NoAmount'))
            end
        elseif data_existing.current.value == 'set_payheight' then
            local amount = KeyboardInput('BOX_ID', _U('dialogbox_amount'), '', 4)
            if amount then
                if tonumber(amount) > Config.MaxPayheight then
                    ESX.ShowNotification(_U('Existing_Pay_height_toohigh') .. Config.MaxPayheight)
                elseif tonumber(amount) < Config.MinPayheight then
                    ESX.ShowNotification(_U('Existing_Pay_height_toolow') .. Config.MinPayheight)
                elseif not (tonumber(amount) > Config.MaxPayheight) and not (tonumber(amount) < Config.MinPayheight) then
                    TriggerServerEvent('fex_credits:setPaymentHeight', GetPlayerServerId(PlayerId()), amount)
                    ESX.ShowNotification(_U('Existing_Pay_height_setnew') .. amount)
                    menu_existing.close()
                    SendWebhook('Credit', 'Monats-rate: '..amount)
                end
            else
                ESX.ShowNotification(_U('NoAmount'))
            end
        end
    end, function(data_existing, menu_existing)
        menu_existing.close()
    end)
end

creditheight = nil
paymentheight = nil
function OpenNewCreditMenu()
    local elements_new = {
        {label = _U('New_creditheight'), value = 'creditheight'},
        {label = _U('New_paymentheight'), value = 'paymentheight'},
        {label = _U('New_submit'), value = 'submit'},
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'NewMenu',
    {
        title    = (_U('title')),
        align    = 'top-left',
        elements = elements_new,
    },
    function(data_new, menu_new)
        if data_new.current.value == 'creditheight' then
            local amount = KeyboardInput('BOX_ID', _U('dialogbox_amount'), '', string.len(Config.MaxCreditHeight))
            if amount then
                if tonumber(amount) > tonumber(Config.MaxCreditHeight) then
                    ESX.ShowNotification(_U('New_credithigh') .. Config.MaxCreditHeight)
                elseif tonumber(amount) < tonumber(Config.MinCreditHeight) then
                    ESX.ShowNotification(_U('New_creditlow') .. Config.MinCreditHeight)
                elseif not (tonumber(amount) < tonumber(Config.MinCreditHeight)) and not (tonumber(amount) > tonumber(Config.MaxCreditHeight)) then
                    creditheight = amount
                end
            else
                ESX.ShowNotification(_U('NoAmount'))
            end
        elseif data_new.current.value == 'paymentheight' then
            local amount = KeyboardInput('BOX_ID', _U('dialogbox_amount'), '', string.len(Config.MaxPayheight))
            if amount then
                if tonumber(amount) > tonumber(Config.MaxPayheight) then
                    ESX.ShowNotification(_U('New_toohigh') .. Config.MaxPayheight)
                elseif tonumber(amount) < tonumber(Config.MinPayheight) then
                    ESX.ShowNotification(_U('New_toolow') .. Config.MinPayheight)
                elseif not (tonumber(amount) < tonumber(Config.MinPayheight)) and not (tonumber(amount) > tonumber(Config.MaxPayheight)) then
                    paymentheight = amount
                end
            else
                ESX.ShowNotification(_U('NoAmount'))
            end
        elseif data_new.current.value == 'submit' then
            if (not (creditheight == nil) and not (paymentheight == nil)) then
                TriggerServerEvent('fex_credits:newCredit', GetPlayerServerId(PlayerId()), creditheight, paymentheight)
                ESX.ShowNotification(_U('New_Success'))
                ESX.UI.Menu.CloseAll()
                SendWebhook('Credit', 'Höhe: '..creditheight..' - Monats-rate: '..paymentheight)
            else
                ESX.ShowNotification(_U('New_nil'))
            end
        end
    end, function(data_existing, menu_existing)
        menu_existing.close()
    end)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		return result
	else
		Citizen.Wait(500)
		return nil
	end
end

RegisterNetEvent('fex_credits:closemenu')
AddEventHandler('fex_credits:closemenu', function()
    ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('fex_credits:paycheck')
AddEventHandler('fex_credits:paycheck', function()
    ESX.TriggerServerCallback('fex_credits:getCredit', function(data)
        SendWebhook('Credit', 'Automatische Rückzahlung gestartet!')
        if #data > 0 then
            paycheck_residualmoney = data[1].height - data[1].payment
            bankmoney = nil
            for key,value in pairs(ESX.PlayerData.accounts) do
                if value.name == 'bank' then
                    bankmoney = value.money
                end
            end

            if data[1].payment > bankmoney then
                local fine = ((data[1].height/100) * Config.Fine)
                ESX.ShowAdvancedNotification(_U('Paycheck_Title'), (_U('Paycheck_Subject_cantpay') .. fine .. _U('Currency')), _U('Paycheck_Message_cantpay'), 'CHAR_BANK_MAZE', 9)
            else
                ESX.ShowAdvancedNotification(_U('Paycheck_Title'), _U('Paycheck_Subject'), (_U('Paycheck_Message') .. data[1].height - data[1].payment), 'CHAR_BANK_MAZE', 9)
                TriggerServerEvent('fex_credits:setCreditHeight', GetPlayerServerId(PlayerId()), (data[1].payment))
            end
        end
    end)
end)

function SendWebhook(title, message)
    if Config.Webhook.use then
        ESX.TriggerServerCallback('fex_discord:getPlayerUsername', function(data)
            TriggerServerEvent('fex_discord:sendEmbedMessageWithWebhook', title, 'User: '..data, 16711680, message, Config.Webhook.Webhook)
        end)
    end
end