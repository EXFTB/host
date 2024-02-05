local Success, Error = pcall(function()
    local Services = setmetatable({}, {__index = function(Type, Key)
        return game:GetService(Key)
    end})
    
    local Players = Services.Players
    local RunService = Services.RunService
    local ReplicatedStorage = Services.ReplicatedStorage
    local StarterGui = Services.StarterGui
    local TeleportService = Services.TeleportService
    local VirtualUser = Services.VirtualUser
    
    local Client = Players.LocalPlayer
    local RunningFunc = false
    
    local GetState = function(Player)
        local CurrentState = {Alive = false, Knocked = false, Grabbed = false}
    
        if Player ~= nil and Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            local UpperTorso = Player.Character:FindFirstChild("UpperTorso")
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            local I_LOADED_I = Player.Character:FindFirstChild("I_LOADED_I")
            local KO = I_LOADED_I:FindFirstChild("K.O").Value
            local WELD_GRAB = Player.Character:FindFirstChild("WELD_GRAB")
            local DEBUG_DEAD = Player.Character:FindFirstChild("DEBUG_DEAD")
    
            if I_LOADED_I and HumanoidRootPart and UpperTorso and Humanoid and Humanoid.Health > 0 then
                if (not DEBUG_DEAD) then
                    CurrentState["Alive"] = true
                end
    
                if WELD_GRAB then
                    CurrentState["Grabbed"] = true
                end
    
                if KO == true then
                    CurrentState["Knocked"] = true
                end
            end
        end
    
        return CurrentState
    end
    
    local Storage = {
        Prefix = "/e",
        Connections = {},
        Ignore = {},
        Flags = {},
        Whitelisted = {
            "Serotuko",
            "FalseVaIues",
            "ethanbot15i",
        },
        Commands = {
            ["Command_BRING"] = {
                ["Aliases"] = {"Bring", "bring"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
                    local HostState = GetState(Arguments[2])
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) and HostState["Alive"] then
                        if Client.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0) then
                            Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        end
    
                        Client.Character.HumanoidRootPart.CFrame = CFrame.new(Arguments[2].Character.HumanoidRootPart.Position + Arguments[2].Character.HumanoidRootPart.CFrame.LookVector * Vector3.new(0, 0, 5))
                    end
                end
            },
            ["Command_RESET"] = {
                ["Aliases"] = {"Reset", "reset"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) then
                        Client.Character.Humanoid.Health = 0
                    end
                end
            },
            ["Command_RESTART"] = {
                ["Aliases"] = {"Restart", "restart"},
                ["Function"] = function(Arguments)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                end
            },
            ["Command_OPENCONSOLE"] = {
                ["Aliases"] = {"Console", "console"},
                ["Function"] = function(Arguments)
                    StarterGui:SetCore("DevConsoleVisible", true)
                end
            },
            ["Command_STOMP"] = {
                ["Aliases"] = {"Stomp", "stomp"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
                    local TargetState = GetState(Arguments[3])
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) and TargetState["Alive"] and TargetState["Knocked"] and (not TargetState["Grabbed"]) then
                        task.spawn(function()
                            RunningFunc = true
                            repeat RunService.RenderStepped:Wait()
                                Client.Character.HumanoidRootPart.CFrame = CFrame.new(Arguments[3].Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                                ReplicatedStorage.MainRemote:FireServer("Stomp")
    
                                TargetState = GetState(Arguments[3])
                            until (not TargetState["Alive"]) or TargetState["Grabbed"]

                            if Client.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0) then
                                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            end
    
                            Client.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(65, 603, 265))
                            RunningFunc = false
                        end)
                    end
                end
            },
            ["Command_GET"] = {
                ["Aliases"] = {"Get", "get"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
                    local HostState = GetState(Arguments[2])
                    local TargetState = GetState(Arguments[3])
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) and HostState["Alive"] and TargetState["Alive"] and TargetState["Knocked"] and (not TargetState["Grabbed"]) then
                        task.spawn(function()
                            RunningFunc = true
                            Client.Character.HumanoidRootPart.CFrame = CFrame.new(Arguments[3].Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                            repeat task.wait(0.25)
                                ReplicatedStorage.MainRemote:FireServer("Grabbing", false)
    
                                TargetState = GetState(Arguments[3])
                            until TargetState["Grabbed"] or TargetState["Dead"]
    
                            Client.Character.HumanoidRootPart.CFrame = CFrame.new(Arguments[2].Character.HumanoidRootPart.Position + Arguments[2].Character.HumanoidRootPart.CFrame.LookVector * Vector3.new(0, 0, 5))
                            repeat RunService.RenderStepped:Wait() until (Client.Character.HumanoidRootPart.Position - Arguments[2].Character.HumanoidRootPart.Position).Magnitude < 15
    
                            repeat task.wait(0.25)
                                ReplicatedStorage.MainRemote:FireServer("Grabbing", false)
    
                                TargetState = GetState(Arguments[3])
                            until (not TargetState["Grabbed"])
    
                            if Client.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0) then
                                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            end
    
                            Client.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(65, 603, 265))
                            RunningFunc = false
                        end)
                    end
                end
            },
            ["Command_EXPLODE"] = {
                ["Aliases"] = {"Explode", "explode"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
                    local TargetState = GetState(Arguments[3])
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) and TargetState["Alive"] and (not TargetState["Knocked"]) then
                        RunningFunc = true
    
                        local MinePath = workspace.Ignored.Shop.Others["[Land Mine] - $725"]
                        local HeartbeatConnection
                        HeartbeatConnection = RunService.Heartbeat:Connect(function()
                            local Mine = Client.Backpack:FindFirstChild("[Land Mine]") or Client.Character:FindFirstChild("[Land Mine]")
    
                            if TargetState["Knocked"] or (not TargetState["Alive"]) or ClientState["Knocked"] or (not ClientState["Alive"]) then
                                if Client.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0) then
                                    Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                end
    
                                task.spawn(function()
                                    for Index = 1, 15 do
                                        Client.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(65, 603, 265))
                                        task.wait(0.01)
                                    end
                                end)

                                RunningFunc = false
                                HeartbeatConnection:Disconnect()
                            end
    
                            if MinePath and (not Mine)  then
                                Client.Character.HumanoidRootPart.CFrame = MinePath.Head.CFrame * CFrame.new(0, -1, 0)
    
                                if MinePath:FindFirstChild("ClickDetector") then
                                    fireclickdetector(MinePath.ClickDetector)
                                end
                            end
    
                            if Mine then
                                if Mine.Parent ~= Client.Character then
                                    Mine.Parent = Client.Character
                                end
                                
                                if Mine.Parent == Client.Character then
                                    Mine:Activate()
                                end
                            end
    
                            for _, Projectile in next, workspace.Ignored:GetChildren() do
                                if tostring(Projectile) == "Land Mine" then
                                    Projectile.CanCollide = false
                                    
                                    if TargetState["Alive"] then
                                        Projectile.CFrame = Arguments[3].Character.HumanoidRootPart.CFrame * CFrame.new(0, -2, 0)
                                    else
                                        Projectile.CFrame = CFrame.new(-9999, -9999, -9999)
                                    end
                                end
                            end
                            
                            ClientState = GetState(Client)
                            TargetState = GetState(Arguments[3])
                        end)
                    end
                end
            },
            ["Command_FLING"] = {
                ["Aliases"] = {"Fling", "fling"},
                ["Function"] = function(Arguments)
                    local ClientState = GetState(Client)
                    local TargetState = GetState(Arguments[3])
    
                    if ClientState["Alive"] and (not ClientState["Knocked"]) and TargetState["Alive"] and (not TargetState["Knocked"]) then
                        RunningFunc = true
                        task.spawn(function()
                            repeat RunService.RenderStepped:Wait()
                                ClientState = GetState(Client)
                                TargetState = GetState(Arguments[3])
    
                                Client.Character.HumanoidRootPart.CFrame = CFrame.new(Arguments[3].Character.HumanoidRootPart.Position + (Arguments[3].Character.HumanoidRootPart.Velocity / 2))
                            until (not TargetState["Alive"]) or TargetState["Knocked"] or (not ClientState["Alive"]) or ClientState["Knocked"] or Arguments[3].Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 370
    
                            RunningFunc = false
                        end)
    
                        task.spawn(function()
                            repeat RunService.Heartbeat:Wait()
                                local Velocity = Client.Character.HumanoidRootPart.Velocity
                                
                                Client.Character.HumanoidRootPart.Velocity = Client.Character.HumanoidRootPart.Velocity + Vector3.new(2 ^ 16, 2 ^ 16, 2 ^ 16)
                                RunService.RenderStepped:Wait()
                                Client.Character.HumanoidRootPart.Velocity = Velocity
                            until (not RunningFunc)
                            
                            ClientState = GetState(Client)
    
                            if ClientState["Alive"] and Client.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0) then
                                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            end
    
                            if ClientState["Alive"] and (not ClientState["Knocked"]) then
                                Client.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(65, 603, 265))
                            end
                        end)
                    end
                end
            },
        }
    }
    --// Bypasses \\--
    
    task.spawn(function()
        local Character = Client.Character or Client.CharacterAdded:Wait()
        Character:WaitForChild("Humanoid").Health = 0
        
        if (not workspace:FindFirstChild("IDLE")) then
            local NewPart = Instance.new("Part", workspace)
            NewPart.Name = "IDLE"
            NewPart.Transparency = 0.8
            NewPart.Anchored = true
            NewPart.Size = Vector3.new(30, 3, 30)
            NewPart.CFrame = CFrame.new(65, 600, 265)
        end
            
        Storage.Connections["RESPAWN"] = Client.CharacterAdded:Connect(function()
            Client.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(0, 0, 0)
            Client.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(Vector3.new(65, 603, 265))
        end) 
    end)
    
    task.spawn(function()
        for _, Seat in pairs(workspace:GetDescendants()) do
            if Seat:IsA("Seat") then
                Seat.Disabled = true
            end
        end
    end)
    --\\ Bypasses //--
    
    --// Functions \\--
    local SearchPlayer = function(String)
        local FoundPlayer = nil
        
        if String ~= nil and type(String) == "string" then
            for _, Player in pairs(Players:GetPlayers()) do
                if string.find(string.lower(tostring(Player)), string.lower(String)) or string.find(string.lower(tostring(Player.DisplayName)), string.lower(String)) then
                    FoundPlayer = Player
                end            
            end
        end
    
        return FoundPlayer
    end
    
    local RunCommand = function(...)
        if RunningFunc then return end
    
        local Arguments = {...} --//1 = Command, 2 = Caller, 3 = Target
    
        for _, Command in pairs(Storage.Commands) do
            if table.find(Command.Aliases, Arguments[1]) then
                Command.Function(Arguments)
            end
        end
    end
    
    local ConnectChatted = function()
        for Name, Connection in pairs(Storage.Connections) do
            if string.find(Name, "CHATTED") then
                Connection:Disconnect()
            end
        end
    
        for _, Player in pairs(Players:GetPlayers()) do
            if table.find(Storage.Whitelisted, tostring(Player)) then
                Storage.Connections[tostring(Player) .. "-CHATTED"] = Player.Chatted:Connect(function(Message)
                    local Arguments = string.split(Message, " ")
    
                    if Arguments[1] == Storage.Prefix then
                        local Command = Arguments[2]
                        local Target = SearchPlayer(Arguments[3])
    
                        if Target ~= nil and table.find(Storage.Whitelisted, tostring(Target)) then return end
    
                        RunCommand(Command, Player, Target)
                    end
                end)
            end
        end
    end
    print("Started: Connecting")
    ConnectChatted()
    --\\ Functions //--
    
    --// Connections \\--
    Storage.Connections["PlayerAdded"] = Players.PlayerAdded:Connect(function(Player)
        if table.find(Storage.Whitelisted, tostring(Player)) then
            print("Joined: Reconnecting")
            ConnectChatted()
        end
    end)
    
    Storage.Connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(Player)
        if table.find(Storage.Whitelisted, tostring(Player)) then
            print("Left: Reconnecting")
            ConnectChatted()
        end
    end)
    
    Storage.Connections["AntiAFK"] = Client.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    --\\ Connections //--
end)
