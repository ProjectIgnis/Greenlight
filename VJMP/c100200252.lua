--古代の機械竜
--Ancient Gear Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Special Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Normal Summon this card without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.nscon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Negate Spell/Trap card or effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Double Snare check
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_names={CARD_ANCIENT_GEAR_GOLEM,id} --Ancient Gear Golem, Ancient Gear Dragon
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function s.nscon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or g:FilterCount(s.cfilter,nil)==#g
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep==1-tp and re:IsActiveType(TYPE_SPELL|TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.disfilter(c)
	return ((c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)) or (c:IsCode(CARD_ANCIENT_GEAR_GOLEM) and c:IsLocation(LOCATION_DECK))) and c:IsAbleToGraveAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end