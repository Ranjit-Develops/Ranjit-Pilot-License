QBCore = exports['qb-core']:GetCoreObject()

-------------
-- Variables --
------------
local LastCheckPoint = -1
local CurrentCheckPoint = 0
local CurrentZoneType   = nil
local inDMV = false
local trigger = true
local CurrentTest = nil

------------- OnPlayerLoaded Event ---------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isLoggedIn = true
  Player = QBCore.Functions.GetPlayerData()
end)


---------------------------------------
            -- EVENTS --
---------------------------------------

RegisterNetEvent('ranjit-pilot:startdriver', function()
  CurrentTest = 'drive'
  DriveErrors = 0
  LastCheckPoint = -1
  CurrentCheckPoint = 0
  IsAboveSpeedLimit = false
  CurrentZoneType = 'residence'
  local prevCoords = GetEntityCoords(PlayerPedId())
  QBCore.Functions.SpawnVehicle(Config.VehicleModels.driver, function(veh)
      TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
      exports['LegacyFuel']:SetFuel(veh, 100)
      SetVehicleNumberPlateText(veh, 'DMV')
      SetEntityAsMissionEntity(veh, true, true)
      SetEntityHeading(veh, Config.Location['spawn'].w)
      TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
      TriggerServerEvent('qb-vehicletuning:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
      LastVehicleHealth = GetVehicleBodyHealth(veh)
      CurrentVehicle = veh
      TriggerEvent('ranjit-pilot:Notify', 'You are taking the pilot test.', 3000, 'success', 'Taking pilot Test')
  end, Config.Location['spawn'], false)
end)



RegisterNetEvent('ranjit-pilot:Notify', function (msg, time, type, title)
  local notify = Config.NotifyType
  if type == 'info' then
    if notify == 'qbcore' then
      type = 'primary'
    elseif notify == 'okok' then
      type = type
    end
  elseif type == 'warning' then
    if notify == 'qbcore' then
      type = 'error'
    elseif notify == 'okok' then
      type = type
    end
  end
  if notify == 'qbcore' then
    TriggerEvent('QBCore:Notify', msg, type, time)
    --QBCore.Functions.Notify(msg, type, time)
  elseif notify == 'okok' then
    exports['okokNotify']:Alert(title, msg, time, type)
  else
    TriggerEvent('chat:addMessage', {
      color = {255, 0, 0},
      multiline = false,
      args = {title, msg}
    })
  end
end)

RegisterNetEvent('ranjit-pilot:client:dmvoptions', function ()
  --DMVOptions()
  OpenMenu('driver')
end)

---------------------------------------
            -- FUNCTIONS --
---------------------------------------

DrawText3Ds = function(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local factor = #text / 370
  local px,py,pz=table.unpack(GetGameplayCamCoords())

  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
end

function DrawMissionText(msg, time)
  ClearPrints()
  SetTextEntry_2('STRING')
  AddTextComponentString(msg)
  DrawSubtitleTimed(time, 1)
end

function SetCurrentZoneType(type)
  CurrentZoneType = type
end


function StopDriveTest(success)
  local playerPed = PlayerPedId()
  local veh = GetVehiclePedIsIn(playerPed)
  if success then
    TriggerEvent('ranjit-pilot:Notify', 'You passed the driving test!', 3000, 'success', 'Passed')
    TriggerServerEvent('ranjit-pilot:driverpaymentpassed')
    QBCore.Functions.DeleteVehicle(veh)
    CurrentTest = nil
  elseif success == false then
    TriggerServerEvent('ranjit-pilot:driverpaymentfailed')
    TriggerEvent('ranjit-pilot:Notify', 'You failed the pilot test, please try again.', 3000, 'success', 'Failed')
    CurrentTest = nil

    RemoveBlip(CurrentBlip)
    QBCore.Functions.DeleteVehicle(veh)
    CurrentTest     = nil
    CurrentTestType = nil
    Wait(1000)
    SetEntityCoords(playerPed, Config.Location['marker'].x+1, Config.Location['marker'].y+1, Config.Location['marker'].z)
  end
end

function OpenMenu(menu)
    exports['qb-menu']:openMenu({
      {
        header = "DMV School",
        isMenuHeader = true,
      },
      {
        header = "Start pilot Test",
        txt = "$500",
        params = {
          event = 'ranjit-pilot:startdriver',
          args = {
            CurrentTest = 'drive'
          }
        }
      },
    })
end

--[[function DMVOptions()
  local drive = Config.DriversTest
  if CurrentTest == 'drive' then
    TriggerEvent('ranjit-pilot:Notify', 'You\'re already taking the pilot test.', 3000, 'error', 'Already Taking Test')
  else
    QBCore.Functions.TriggerCallback('ranjit-pilot:server:permitdata', function (permit)
      if permit then
        OpenMenu('theoritical')
      else
        QBCore.Functions.TriggerCallback('ranjit-pilot:server:licensedata', function (license)
          if license then
            if drive then
              OpenMenu('driver')
            else
              TriggerEvent('ranjit-pilot:Notify', 'You already took your tests! Go to the City Hall to buy your license', 3000, 'info', 'Already took the test')
            end
          end
        end)
      end
    end)
  end
end]]
---------------------------------------
            -- THREADS --
---------------------------------------


CreateThread(function ()
  blip = AddBlipForCoord(Config.Location['marker'].x, Config.Location['marker'].y, Config.Location['marker'].z)
  SetBlipSprite(blip, Config.Blip.Sprite)
  SetBlipDisplay(blip, Config.Blip.Display)
  SetBlipColour(blip, Config.Blip.Color)
  SetBlipScale(blip, Config.Blip.Scale)
  SetBlipAsShortRange(blip, Config.Blip.ShortRange)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(Config.Blip.BlipName)
  EndTextCommandSetBlipName(blip)
end)

CreateThread( function ()
  if not Config.UseTarget then
    if Config.UseNewQB then
      local dmvzone = CircleZone:Create(vector3(Config.Location['coords']['x'], Config.Location['coords']['y'], Config.Location['coords']['z']), Config.Location['radius'], {useZ = Config.Location['useZ']})
      dmvzone:onPlayerInOut( function (isPointInside)
        if isPointInside then
          inDMV = true
          exports['qb-core']:DrawText('[E] Open DMV')
        else
          inDMV = false
          exports['qb-core']:HideText()
        end
      end)
    end
  else
    exports['qb-target']:SpawnPed({
      model = Config.Location['ped']['model'],
      coords = Config.Location['coords'],
      minusOne = Config.TargetOptions.minusOne,
      freeze = Config.TargetOptions.freeze,
      invincible = Config.TargetOptions.invincible,
      blockevents = Config.TargetOptions.blockevents,
      target = {
          options = {
            {
              type = 'client',
              icon = Config.TargetOptions.options.icon,
              label = Config.TargetOptions.options.label,
              event = 'ranjit-pilot:client:dmvoptions'
            },
          },
          distance = Config.Location['radius'],
      }
    })
  end
  while true do
    local sleep = 1000
    if inDMV then
      sleep = 0
      if IsControlJustPressed(0, 38) then
        sleep = 1000
        exports['qb-core']:KeyPressed()
        TriggerEvent('ranjit-pilot:client:dmvoptions')
      end
    end
    Wait(sleep)
  end
end)

-- Drive test
CreateThread(function()
  while true do
    Wait(10)
    if CurrentTest == 'drive' then
      local marker = Config.Location['marker']
      local playerPed      = PlayerPedId()
      local coords         = GetEntityCoords(playerPed)
      local nextCheckPoint = CurrentCheckPoint + 1
      if Config.CheckPoints[nextCheckPoint] == nil then
        if DoesBlipExist(CurrentBlip) then
          RemoveBlip(CurrentBlip)
        end
        CurrentTest = nil
        StopDriveTest(true)
      else
        if CurrentCheckPoint ~= LastCheckPoint then
          if DoesBlipExist(CurrentBlip) then
            RemoveBlip(CurrentBlip)
          end
          CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
          SetBlipRoute(CurrentBlip, 1)
          LastCheckPoint = CurrentCheckPoint
        end
        local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)
        if distance <= 100.0 then
          DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
        end
        if distance <= 3.0 then
          Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
          CurrentCheckPoint = CurrentCheckPoint + 1
        end
      end
    end
  end
end)

-- Speed / Damage control
CreateThread(function()
  while true do
    Wait(10)
      if CurrentTest == 'drive' then
          local playerPed = PlayerPedId()
          if IsPedInAnyVehicle(playerPed,  false) then
              local vehicle      = GetVehiclePedIsIn(playerPed,  false)
              local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
              local tooMuchSpeed = false
              for k,v in pairs(Config.SpeedLimits) do
                  if CurrentZoneType == k and speed > v then
                  tooMuchSpeed = true
                      if not IsAboveSpeedLimit then
                          DriveErrors       = DriveErrors + 1
                          IsAboveSpeedLimit = true
                          TriggerEvent('ranjit-pilot:Notify', 'You\'re driving too fast. Slow down', 3000, 'warning', 'Watch your speed!')
                          TriggerEvent('ranjit-pilot:Notify', 'Errors: '..tostring(DriveErrors)..' / '..Config.MaxErrors, 3000, 'warning', 'Error')
                      end
                  end
              end
              if not tooMuchSpeed then
                  IsAboveSpeedLimit = false
              end
              local health = GetVehicleBodyHealth(vehicle)
              if health < LastVehicleHealth then
                  DriveErrors = DriveErrors + 1
                  TriggerEvent('ranjit-pilot:Notify', 'You damaged the vehicle', 3000, 'warning', 'Damaged the Vehicle')
                  TriggerEvent('ranjit-pilot:Notify', 'Errors: '..tostring(DriveErrors)..' / '..Config.MaxErrors, 3000, 'warning', 'Error!')
                  LastVehicleHealth = health
              end
              if DriveErrors >= Config.MaxErrors then
                Wait(10)
                StopDriveTest(false)
              end
          end
      end
  end
end)
