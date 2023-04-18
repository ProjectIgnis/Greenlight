--合成獣融合
--Chimera Fusion
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,nil,function()return nil,s.matcheck end)
	c:RegisterEffect(e1)
	--Graveyard effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={4796100,5818798,77207191}
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_BEAST|RACE_FIEND,fc,SUMMON_TYPE_FUSION,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,4796100),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
end
function s.spfilter(c,e,tp,code1,code2)
	return c:IsCode(code1,code2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=c:IsAbleToHand()
	local b2=c:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,5818798)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,77207191)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	else
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if e:GetLabel()==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	elseif Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp,5818798,77207191)
		if g:GetClassCount(Card.GetCode)==2 then
			local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.dncheck,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end