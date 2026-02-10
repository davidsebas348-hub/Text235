-- ===== SERVICES =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- ===== TOGGLE =====
if _G.AUTO_JUMP_CLICK_CONN then
    _G.AUTO_JUMP_CLICK_CONN:Disconnect()
    _G.AUTO_JUMP_CLICK_CONN = nil
    return
end

-- ===== CONFIGURACIÓN =====
local CLICK_THRESHOLD = 3        -- click cuando aparezcan 3
local RESET_THRESHOLD = 4        -- reinicia si llega a 4
local TIMEOUT = 1.5              -- reinicia si no aparece nuevo M1ing en este tiempo
local OFFSET_X = 25               -- mover 25 píxeles a la derecha
local OFFSET_Y = 30               -- mover 30 píxeles hacia abajo

-- Variables de control
local seenM1ing = {}
local m1ingCount = 0
local lastM1ingTime = 0

-- ===== FUNCIONES =====
local function clickJumpButton()
    local playerGui = player:WaitForChild("PlayerGui")
    local jumpButton = playerGui:FindFirstChild("JumpButton", true)
    if not jumpButton then
        warn("No se encontró JumpButton")
        return
    end

    local absPos = jumpButton.AbsolutePosition
    local absSize = jumpButton.AbsoluteSize

    local x = absPos.X + absSize.X/2 + OFFSET_X
    local y = absPos.Y + absSize.Y/2 + OFFSET_Y

    -- PRESIONAR
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    -- SOLTAR
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- ===== LOOP PRINCIPAL =====
_G.AUTO_JUMP_CLICK_CONN = RunService.Heartbeat:Connect(function()
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then
        seenM1ing = {}
        m1ingCount = 0
        return
    end

    local myModel = liveFolder:FindFirstChild(player.Name)
    if not myModel then
        seenM1ing = {}
        m1ingCount = 0
        return
    end

    local newM1Detected = false

    -- Detectar nuevos M1ing
    for _, child in ipairs(myModel:GetChildren()) do
        if child.Name:lower() == "m1ing" and not seenM1ing[child] then
            seenM1ing[child] = true
            m1ingCount += 1
            newM1Detected = true
            lastM1ingTime = tick()

            if m1ingCount == CLICK_THRESHOLD then
                clickJumpButton()
            end
        end
    end

    -- Reiniciar si llega a RESET_THRESHOLD
    if m1ingCount >= RESET_THRESHOLD then
        seenM1ing = {}
        m1ingCount = 0
    end

    -- Reiniciar si no aparece ninguno durante TIMEOUT segundos
    if not newM1Detected and m1ingCount > 0 and (tick() - lastM1ingTime) > TIMEOUT then
        seenM1ing = {}
        m1ingCount = 0
    end
end)
