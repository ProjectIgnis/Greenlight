--原石の鳴獰
--Primoredial Tremors
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Prevent battle destruction and Special Summon 1 Normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET) --maybe EFFECT_FLAG2_CHECK_SIMULTANEOUS?
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.rmvcond)
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ac=Duel.AnnounceCard(tp,TYPE_NORMAL)
	Duel.SetTargetParam(ac)
	local code=Duel.AnnounceCard(tp,TYPE_NORMAL)
	Duel.SetTargetParam(code)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp,code)
	return c:IsType(TYPE_NORMAL) and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	--Your Normal Monsters with declared name and "Primoredial" monsters cannot be destroyed by battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_PRIMOREDIAL) or (c:IsCode(code) and c:IsType(TYPE_NORMAL)) end)
	e1:SetReset(RESET_PHASE|PHASE_END,Duel.IsTurnPlayer(tp) and 2 or 1)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	--Special Summon 1 Normal Monster with the declared name
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.rmvfilter(c,atk)
	return c:IsAbleToRemove() and c:IsFaceup() and c:GetAttack()>atk
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk):GetFirst()
	if tc then
		Duel.Remove(tc,nil,REASON_EFFECT)
	end
end