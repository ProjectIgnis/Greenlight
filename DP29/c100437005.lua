--殲滅のタキオン・スパイラル
--Tachyon Spiral of Destruction
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
    --Activate 1 of these effects (Destroy cards, Add "Tachyon" card from GY to hand, or Special Summon Dragon "Number")
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(s.efftg)
    e1:SetOperation(s.effop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_GALAXY,SET_TACHYON,SET_NUMBER}
s.listed_names={id}
function s.galaxyfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GALAXY)
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsStatus(STATUS_DISABLED)
end
function s.thfilter(c)
    return c:IsSetCard(SET_TACHYON) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NUMBER) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local b1=Duel.IsExistingMatchingCard(s.galaxyfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) and not Duel.HasFlagEffect(tp,id)
    local b2=Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and not Duel.HasFlagEffect(tp,id+1)
    local b3=Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and not Duel.HasFlagEffect(tp,id+2) and ft>0 
    if chk==0 then return b1 or b2 or b3 end
    local op=Duel.SelectEffect(tp,
        {b1,aux.Stringid(id,1)},
        {b2,aux.Stringid(id,2)},
        {b3,aux.Stringid(id,3)})
    e:SetLabel(op)
    if op==1 then
        e:SetCategory(CATEGORY_DESTROY)
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    elseif op==2 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
    elseif op==3 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local op=e:GetLabel()
    if op==1 then
        --Destroy all face-up negated cards your opponent controls
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    elseif op==2 then
        --Target 1 "Tachyon" card in your GY, except "Tachyon Spiral of Destruction"; add it to your hand
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.SendtoHand(tc,tp,REASON_EFFECT)
        end
    elseif op==3 then
        --Target 1 Dragon "Number" monster in your GY; Special Summon in face-up Defense Position
        if ft<=0 then return end
        Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
end