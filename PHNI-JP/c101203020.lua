--粛声の竜賢姫サフィラ
--Saffira, the Wise Silenforcer Queen
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
        --send 1 Ritual Spell from your Deck to the GY, then you can add 1 LIGHT Warrior or Dragon Ritual Monster from your Deck or GY to your hand
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetCountLimit(1,id)
        e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH)
        e1:SetType(EFFECT_TYPE_IGNITION)
        e1:SetRange(LOCATION_HAND)
        e1:SetCost(s.thcost)
        e1:SetTarget(s.thtg)
        e1:SetOperation(s.thop)
        c:RegisterEffect(e1)
        --Ritual Summon 1 LIGHT Warrior or Dragon Ritual Monster from your hand
        local e2=Ritual.CreateProc(c,RITPROC_GREATER,s.filter,nil,aux.Stringid(id,1),nil,nil,nil,nil,LOCATION_HAND)
        e2:SetCountLimit(1,{id,1})
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_GRAVE)
        e2:SetCost(aux.bfgcost)
        c:RegisterEffect(e2)
end
function s.filter(c)
        return c:IsRitualMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_DRAGON))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then return c:IsDiscardable() end
        Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsRitualSpell),tp,LOCATION_DECK,0,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
        Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.FilterBoolFunction(Card.IsRitualSpell),tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            	Duel.SendtoGrave(g,REASON_EFFECT)
            	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
            	if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                    	Duel.BreakEffect()
                    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                    	local sg=mg:Select(tp,1,1,nil)
                    	Duel.SendtoHand(sg,nil,REASON_EFFECT)
                    	Duel.ConfirmCards(1-tp,sg)
            	end
        end
end
