--マジックカード「クロス・ソウル」
--Spell Card: "Soul Exchange"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Tribute Summon 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tpnstg)
	e1:SetOperation(s.tpnsop)
	c:RegisterEffect(e1)
	--Your opponent can Tribute Summon 1 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.opnstg)
	e2:SetOperation(s.opsumop)
	c:RegisterEffect(e2)
end
function s.filter(c,ec,p)
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetAbsoluteRange(p,0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP|POS_FACEDOWN)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1,true)
	local res=c:CanSummonOrSet(true,nil,1)
	e1:Reset()
	return res
end
function s.tpnstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,LOCATION_HAND)
end
function s.tpnsop(e,tp,eg,ep,ev,re,r,rp)
	s.tributesummon(e,tp)
end
function s.tpnstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.tpnsop(e,tp,eg,ep,ev,re,r,rp)
	s.tributesummon(e,tp)
end
function s.opnstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function s.opsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,p,LOCATION_HAND,0,1,nil,e:GetHandler(),1-tp) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		s.tributesummon(e,1-tp)
	end
end
function s.tributesummon(e,p)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(p,s.filter,p,LOCATION_HAND,0,1,1,nil,c,p):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
		e1:SetAbsoluteRange(p,0,LOCATION_MZONE)
		e1:SetValue(POS_FACEUP|POS_FACEDOWN)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Tribute Summon it
		Duel.SummonOrSet(p,tc,true,nil)
		--Cannot be tributed this turn
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3303)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e3,true)
	end
end