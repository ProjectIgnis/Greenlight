--地縛神 スカーレッド・ノヴァ
--Earthbound Immortal Red Nova
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,SET_EARTHBOUND_IMMORTAL),LOCATION_MZONE)
	--Send 1 "Red-Dragon Archifiend" or "Earthbound Immortal" monster to the GY and Special Summon 1 "Earthbound" monster or "Red Nova Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return Duel.IsMainPhase() end)
	e1:SetCost(aux.selfbanishcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND,97489701}
s.listed_series={SET_EARTHBOUND,SET_EARTHBOUND_IMMORTAL}
function s.filter(c)
	return c:IsMonster() and c:IsAbleToGrave() and (c:IsFaceup() or not c:IsOnField())
		and (c:IsCode(CARD_RED_DRAGON_ARCHFIEND) or c:IsSetCard(SET_EARTHBOUND_IMMORTAL))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE|LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(SET_EARTHBOUND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c) or Duel.GetLocationCount(tp,LOCATION_MZONE))>0
end
function s.spfilter2(c,e,tp)
	return c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil):GetFirst()
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)>0 and gc:IsLocation(LOCATION_GRAVE) then
		local b1=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		if not (b1 or b2) then return end
		local sel=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		Duel.BreakEffect()
		if sel==1 then
			--Special Summon 1 "Earthbound" monster 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif sel==2 then
			--Special Summon "Red Nova Dragon"
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
				tc:CompleteProcedure()
			end
		end
	end
end