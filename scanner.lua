local function GetAllGameScripts()
    local scripts = {}
    for _, v in pairs(game:GetDescendants()) do
        if v.Name ~= "CoreGui" and v.Name ~= "CorePackages" then
            pcall(function()
                if (v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Script")) then
                    table.insert(scripts, v)
                end
            end)
        end
    end
    return scripts
end

local function AnalyzeScript(script)
    local acPatterns = {
        ["names"] = {
            "anti", "check", "secure", "protect", "detect", "validate", "verify",
            "shield", "guard", "scan", "monitor", "watch", "block", "prevent",
            "security", "defense", "safety", "enforcement", "protection", "firewall",
            "barrier", "safeguard", "sentinel", "warden", "overseer", "supervisor",
            "controller", "moderator", "enforcer", "keeper", "ac", "anticheat",
            "bypass", "exploit", "hack", "cheat", "illegal", "violation", "abuse"
        },
        ["code"] = {
            "ban", "kick", "punish", "teleport", "report", "getrawmetatable",
            "hookfunction", "checkcaller", "fireserver", "invokeserver", "remote",
            "network", "physics", "velocity", "speed", "position", "humanoid",
            "character", "localplayer", "getservice", "children", "parent",
            "descendant", "instance", "property", "walkspeed", "jumppower",
            "health", "damage", "tool", "weapon", "ammo", "reload", "shoot",
            "fire", "hit", "damage", "kill", "died", "respawn", "spawn",
            "team", "player", "backpack", "inventory", "gui", "screen",
            "camera", "workspace", "replicatedstorage", "serverscriptservice",
            "starterplayer", "startergui", "lighting", "sound", "animation",
            "raycast", "touch", "collision", "part", "model", "mesh",
            "magnitude", "distance", "vector", "cframe", "region", "boundingbox",
            "size", "mass", "gravity", "acceleration", "force", "torque",
            "joint", "weld", "constraint", "spring", "rope", "beam",
            "trail", "particle", "effect", "decal", "texture", "surface",
            "material", "color", "transparency", "reflectance", "brightness",
            "contrast", "saturation", "hue", "fog", "atmosphere", "sky",
            "terrain", "water", "fire", "smoke", "sparkles", "debris",
            "http", "websocket", "json", "encode", "decode", "compress",
            "encrypt", "decrypt", "hash", "checksum", "validate", "verify",
            "authenticate", "authorize", "permission", "access", "deny",
            "allow", "block", "filter", "sanitize", "clean", "purge",
            "remove", "delete", "destroy", "create", "spawn", "clone",
            "duplicate", "copy", "paste", "move", "rotate", "scale",
            "transform", "modify", "change", "update", "refresh", "reload",
            "restart", "shutdown", "close", "open", "start", "stop",
            "pause", "resume", "toggle", "switch", "flip", "reverse",
            "invert", "normalize", "clamp", "lerp", "smooth", "interpolate",
            "extrapolate", "predict", "forecast", "calculate", "compute",
            "process", "analyze", "evaluate", "measure", "compare", "match",
            "find", "search", "scan", "probe", "test", "check", "verify",
            "validate", "confirm", "approve", "reject", "deny", "block",
            "prevent", "protect", "secure", "guard", "watch", "monitor",
            "track", "trace", "log", "record", "store", "save", "load",
            "sync", "async", "yield", "wait", "delay", "timeout", "interval",
            "timer", "clock", "time", "date", "schedule", "queue", "stack",
            "list", "array", "table", "dictionary", "map", "set", "collection",
            "container", "buffer", "stream", "pipe", "channel", "port",
            "socket", "connection", "session", "state", "status", "condition",
            "flag", "signal", "event", "trigger", "callback", "handler",
            "listener", "observer", "publisher", "subscriber", "message",
            "packet", "frame", "buffer", "stream", "flow", "traffic"
        },
        ["functions"] = {
            "GetChildren", "GetDescendants", "FindFirstChild", "WaitForChild",
            "Clone", "Destroy", "GetPropertyChangedSignal", "Connect", "Fire",
            "Invoke", "IsA", "GetAttribute", "SetAttribute", "GetAttributes",
            "ClearAllChildren", "ClearAllAttributes", "GetDebugId", "GetFullName",
            "GetJoints", "GetMass", "GetNetworkOwner", "GetPivot", "GetRootPart",
            "GetTouchingParts", "GetConnectedParts", "GetInstanceFromPort",
            "GetBoundingBox", "GetExtentsSize", "GetPrimaryPartCFrame",
            "GetModelCFrame", "GetModelSize", "GetServerTimeNow", "GetUserCFrame",
            "GetUserPosition", "GetVelocity", "GetState", "GetStateEnabled",
            "GetStatuses", "GetPlayingAnimationTracks", "GetPlaybackSpeed",
            "GetTimeOfDay", "GetMoonPhase", "GetMinutesAfterMidnight",
            "GetNameFromUserIdAsync", "GetUserIdFromNameAsync", "GetUserThumbnailAsync"
        }
    }
    
    local findings = {
        confidence = 0,
        matches = {}
    }
    
    pcall(function()
        local nameLower = script.Name:lower()
        for _, pattern in pairs(acPatterns.names) do
            if string.find(nameLower, pattern) then
                findings.confidence = findings.confidence + 2
                table.insert(findings.matches, {type = "Name", pattern = pattern})
            end
        end
        
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            local source = script.Source:lower()
            
            for _, pattern in pairs(acPatterns.code) do
                local count = select(2, string.gsub(source, pattern, ""))
                if count > 0 then
                    findings.confidence = findings.confidence + count
                    table.insert(findings.matches, {type = "Code", pattern = pattern, count = count})
                end
            end
            
            for _, func in pairs(acPatterns.functions) do
                local count = select(2, string.gsub(source, func, ""))
                if count > 2 then
                    findings.confidence = findings.confidence + math.floor(count/2)
                    table.insert(findings.matches, {type = "Function", pattern = func, count = count})
                end
            end
        end
    end)
    
    return findings
end

local function ScanRemotes()
    local remotes = {}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(remotes, v)
        end
    end
    return remotes
end

local function StartUniversalAnticheatScan()
    print("\n🔍 Universal Anti-Cheat Scanner v3.0")
    print("Scanning game: " .. game.Name)
    
    local remotes = ScanRemotes()
    print("Found " .. #remotes .. " remotes")
    
    local scripts = GetAllGameScripts()
    print("\nAnalyzing " .. #scripts .. " scripts")
    
    local potentialAntiCheats = {}
    local totalAnalyzed = 0
    
    for _, script in pairs(scripts) do
        local findings = AnalyzeScript(script)
        
        if findings.confidence >= 3 then
            table.insert(potentialAntiCheats, {
                script = script,
                findings = findings
            })
        end
        
        totalAnalyzed = totalAnalyzed + 1
        if totalAnalyzed % 50 == 0 then
            task.wait()
            print("Progress: " .. math.floor((totalAnalyzed / #scripts) * 100) .. "%")
        end
    end
    
    print("\n📊 Scan Results:")
    print("Total Scripts Analyzed: " .. #scripts)
    print("Potential Anti-Cheat Systems Found: " .. #potentialAntiCheats)
    
    if #potentialAntiCheats > 0 then
        print("\n🚨 High Confidence Matches:")
        table.sort(potentialAntiCheats, function(a,b) 
            return a.findings.confidence > b.findings.confidence 
        end)
        
        for i, result in ipairs(potentialAntiCheats) do
            if i > 15 then break end
            print("\n" .. result.script:GetFullName())
            print("Confidence Score: " .. result.findings.confidence)
            print("Notable Matches:")
            for _, match in pairs(result.findings.matches) do
                if match.count then
                    print("• " .. match.type .. ": " .. match.pattern .. " (x" .. match.count .. ")")
                else
                    print("• " .. match.type .. ": " .. match.pattern)
                end
            end
        end
    end
    
    print("\n✅ Scan Complete!")
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        StartUniversalAnticheatScan()
    end
end)

print("Press Right Alt to start universal anti-cheat scan")
