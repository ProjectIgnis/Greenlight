--特異点の悪魔
--Singularity Fiend
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
    --Destroy opponent's Special Summoned monster(s)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and Duel.GetCurrentChain()==0 end)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.costfilter(c)
    return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() and
        Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(eg,REASON_EFFECT)
end
