--白銀の城の執事 アリアス
--Arias the Labrynth Butler
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
	--special labrynth monster or set normal trap from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settarget)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--special summon from grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LABRYNTH}
function s.setcon()
	return Duel.IsMainPhase()
end
function s.ssfilter(c,e,tp)
	return c:IsSetCard(SET_LABRYNTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setfilter(c)
	return c:IsNormalTrap() and c:IsSSetable()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and (Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)) end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.settarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)
    if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)
	if (b1 or b2) then
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
                local c=e:GetHandler()
                local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
				if sc and Duel.SSet(tp,g,tp,false)>0 then
                	--can be activate this turn
                	local g1=Effect.CreateEffect(c)
                	g1:SetType(EFFECT_TYPE_SINGLE)
                	g1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                	g1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                	g1:SetReset(RESET_EVENT|RESETS_STANDARD)
                	sc:RegisterEffect(g1)
				end
			end
		end
	end
end
			
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local ch=ev-1
	if ch==0 or not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch_player,ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	local ch_c=ch_eff:GetHandler()
	return ch_player==tp and ((ch_c:IsSetCard(SET_LABRYNTH) and not ch_c:IsCode(id))
		or (ch_c:GetType()==(TYPE_TRAP) and ch_eff:IsTrapEffect()))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
