local ESX = nil
ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('fex_credits:getCredit', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM credit WHERE userid = @identifier', {
        ['@identifier'] = xPlayer.getIdentifier()
    }, function(result)
        cb(result)
    end)
end)

--Change Credit Height
RegisterNetEvent('fex_credits:setCreditHeight')
AddEventHandler('fex_credits:setCreditHeight', function(source, height)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (tonumber(height) == 0) then
        xPlayer.setAccountMoney(Config.Account, 0)
    else
        xPlayer.removeAccountMoney(Config.Account, tonumber(height))
    end
    if tonumber(height) == 0 then
        MySQL.Sync.execute('DELETE FROM credit WHERE userid = @identifier', {
            ['@identifier'] = xPlayer.getIdentifier()
        })
        xPlayer.triggerEvent('fex_credits:closemenu')
    else
        MySQL.Sync.execute('UPDATE credit SET height = @height WHERE userid = @identifier', {
            ['@height'] = height,
            ['@identifier'] = xPlayer.getIdentifier()
        })
    end
end)

--Change Payment Height
RegisterNetEvent('fex_credits:setPaymentHeight')
AddEventHandler('fex_credits:setPaymentHeight', function(source, payment)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Sync.execute('UPDATE credit SET payment = @payment WHERE userid = @identifier', {
        ['@payment'] = payment,
        ['@identifier'] = xPlayer.getIdentifier()
    })
end)

--Register new Credit
RegisterNetEvent('fex_credits:newCredit')
AddEventHandler('fex_credits:newCredit', function(source, height, payment)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney(Config.Account, tonumber(height))

    MySQL.Async.execute('INSERT INTO `credit` (`userid`, `height`, `payment`) VALUES (@userid, @height, @payment)', {
        ['@userid'] = xPlayer.getIdentifier(),
        ['@height'] = height,
        ['@payment'] = payment
   })
end)
-- INSERT INTO `credit` (`id`, `userid`, `height`, `payment`, `stop`) VALUES (NULL, 'char1:1aa3af95bde6a9d44780c24122a40a77fbc6586b', '1000', '100', '0');
