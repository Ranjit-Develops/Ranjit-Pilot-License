Config = {}

Config.NotifyType = 'qbcore'                                 --(qbcore | okok)<--This is the 2 options. Right now only supports QBCore:Notify or okokNotify

Config.PaymentType = 'cash'            -- 'cash' or 'bank' What account to use for payment
Config.DriversTest = true                   
Config.SpeedMultiplier = 2.236936                            --KM/H = 3.6 MPH = 2.236936
Config.MaxErrors       = 10
Config.UseTarget       = true                            -- True = Spawns a Ped to use qb-target with. False = Will use exports['qb-core']:DrawText or DrawText3Ds function depending on Config.UseNewQB
Config.UseNewQB        = true                               -- If Not Using Target then if your QB files aren't updated to use exports['qb-core']:DrawText then make this false. If you'd rather use the exports['qb-core']:DrawText than use Target then make this true and make Config.UseTarget = false


Config.TargetOptions = {
  minusOne = true,                                        -- Gets the Coords you copied from qb-adminmenu and minuses 1 from the z coordinate to put the ped on the floor instead of floating in the air. Best to leave this true
  freeze = true,                                          -- Freezes ped in place so nothing can move him. 
  invincible = true,                                      -- Can't Kill Ped
  blockevents = true,                                     -- Blocks other Events from showing up that isn't in the export for this script
  options = { 
    icon = 'fa-solid fa-car-burst',                       -- Icon to show up for Target Option
    label = 'Open License',                                   -- Text to show up for Target Option
  }
}
Config.GiveItem = true   
Config.Location = {
  ['marker'] = vector4(-998.57, -2954.97, 13.96, 57.76),           --Location of Blip for DMV School and Location of Start Marker if Config.UseNewQB = false
  ['spawn'] = vector4(-1004.5, -3131.78, 13.94, 58.94),    -- Location to spawn vehicle upon starting Drivers Test
  ['coords'] = vector4(-1000.67, -2944.43, 13.95, 41.89),    -- Location of Ped if Config.UseTarget True or Loction of QB:DrawText Area if Config.UseTarget = false and Config.UseNewQB = true
  ['useZ'] = true,                                        -- Use Z coord for Config.Loacation['coords']. Best to leave this true

  ['ped'] = {
    ['model'] = 's_m_y_cop_01',                             -- Ped to spawn if Config.UseTarget is true.
  },
  ['radius'] = 5.0,                                         -- If Config.UseNewQB = true and Config.UseTarget = false then this is how far away you have to be from the above coordinates.
}

Config.Amount = {
    ['driving']     = 150                              --Drivers Test Payment Amount
}

Config.Blip = {                                             -- Blip Config
  Sprite = 16,
  Display = 4,
  Color = 1,
  Scale = 0.8,
  ShortRange = true,
  BlipName = 'Pilot School'
}

Config.VehicleModels = {
  driver = 'luxor2',                                         -- Car to spawn with Driver's Test
}

Config.SpeedLimits = {                                      -- Speed Limits in each zone
  residence = 35
}

Config.CheckPoints = {                                      -- Each Cheackpoint for the Drivers Test
  {
    Pos = {x = -1127.07, y = -3064.1, z = 13.94},--vector3(-1127.07, -3064.1, 13.94)
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('go to the next point! Fast', 5000)
    end
  },

  {
    Pos = {x = 1613.48, y = 3224.53, z = 40.41},--vector3(1613.48, 3224.53, 40.41)
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('i\'m impressed, but don\'t forget to stay ~r~Best~s~ Flying!', 5000)
      PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
    end
  },

  {
    Pos = {x = -875.17, y = -3221.65, z =  13.94},--vector3(-875.17, -3221.65, 13.94)
    Action = function(playerPed, vehicle, setCurrentZoneType)
      function QBCore.Functions.DeleteVehicle(vehicle)
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
      end
    end
  },

}