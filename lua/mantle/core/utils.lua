Mantle.util = {}

function Mantle.util.isDescendantOf(panel, target)
    while IsValid(panel) do
        if panel == target then return true end
        panel = panel:GetParent()
    end

    return false
end

function Mantle.util.stepAlpha(current, target, maxSpeed, ft)
    local next = Mantle.func.approachExp(current, target, 20, ft)
    local maxStep = maxSpeed * ft
    local delta = next - current
    if math.abs(delta) > maxStep then
        delta = delta > 0 and maxStep or -maxStep
    end

    return current + delta
end