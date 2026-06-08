-- Made by Ash
TOOL.Name         = "Persistence"
TOOL.Category   = "Helix"
TOOL.Command    = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("tool.ix_persistence.name", "Persistence")
    language.Add("tool.ix_persistence.desc", "Make entities persistent across map restarts.")
    language.Add("tool.ix_persistence.0", "Left-click: Make Persistent | Right-click: Remove Persistence")

    local COLOR_PERSISTED     = Color(50, 220, 80)
    local COLOR_NOT_PERSISTED = Color(220, 50, 50)
    local COLOR_SHADOW        = Color(0, 0, 0, 200)

    local function IsToolActive()
        local client = LocalPlayer()
        if !IsValid(client) then return false end
        local wep = client:GetActiveWeapon()
        return IsValid(wep) and wep:GetClass() == "gmod_tool" and wep:GetMode() == "ix_persistence"
    end

    hook.Add("PreDrawHalos", "ix_persistence_halo", function()
        if !IsToolActive() then return end

        local ent = LocalPlayer():GetEyeTrace().Entity
        if !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() then return end

        local isPersisted = ent:GetNetVar("Persistent", false)
        local color = isPersisted and COLOR_PERSISTED or COLOR_NOT_PERSISTED

        halo.Add({ent}, color, 6, 6, 1, true, true)
    end)

    function TOOL:DrawHUD()
        local ent = LocalPlayer():GetEyeTrace().Entity
        if !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() then return end

        local isPersisted = ent:GetNetVar("Persistent", false)
        local text  = isPersisted and "PERSISTED" or "NOT PERSISTED"
        local color = isPersisted and COLOR_PERSISTED or COLOR_NOT_PERSISTED

        draw.SimpleTextOutlined(
            text,
            "ContentHeader",
            ScrW() * 0.5,
            ScrH() * 0.25,
            color,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP,
            2,
            COLOR_SHADOW
        )
    end
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    if !self:GetOwner():IsSuperAdmin() then
        return false
    end

    local ent = trace.Entity

    if !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() or ent.bNoPersist then
        return false
    end

    if ent:GetNetVar("Persistent", false) then
        return false
    end

    local plugin = ix.plugin.Get("persistence")

    if !plugin then return false end

    plugin.stored[#plugin.stored + 1] = ent
    ent:SetNetVar("Persistent", true)

    ix.log.Add(self:GetOwner(), "persist", ent:GetModel(), true)

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    if !self:GetOwner():IsSuperAdmin() then
        return false
    end

    local ent = trace.Entity

    if !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() then
        return false
    end

    if !ent:GetNetVar("Persistent", false) then
        return false
    end

    local plugin = ix.plugin.Get("persistence")

    if !plugin then return false end

    for k, v in ipairs(plugin.stored) do
        if v == ent then
            table.remove(plugin.stored, k)
            break
        end
    end

    ent:SetNetVar("Persistent", false)

    ix.log.Add(self:GetOwner(), "persist", ent:GetModel(), false)

    return true
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text        = "Persistence",
        Description = "Left click: make an entity persistent across map restarts.\nRight click: remove persistence from an entity."
    })
end
