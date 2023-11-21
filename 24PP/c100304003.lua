--トイ・ボックス
--Toy Box
--scripted by Naim
local s,id=GetID()
local CARD_TOY_BOX=id
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Destroy an opponent's attacking monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e2:SetCost(s.mondescost)
	e2:SetTarget(s.mondestg)
	e2:SetOperation(s.mondesop)
	c:RegisterEffect(e2)
	--Set up to 2 monsters that have "Toy" in their names and an effect to Set themselves
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- Destroy up to 2 cards in your Spell/Trap Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(s.stdestg)
	e4:SetOperation(s.stdesop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_TOY}
local locations=LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE|LOCATION_GRAVE
function s.cstfilter(c)
	return c:IsFacedown() and c:IsAbleToGraveAsCost()
end
function s.mondescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cstfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cstfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.mondestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
end
function s.mondesop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() then
		Duel.Destroy(at,REASON_EFFECT)
	end
end
function s.setfilter(c)
	return c:IsOriginalSetCard(SET_ARTIFACT) and c:IsMonster() --to be removed later
	--return c:IsOriginalSetCard(SET_TOY) and c:IsMonster() and s.self_set_effect
		and c:IsSSetable() and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,locations,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	if ft==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,locations,0,1,ft,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.stdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.stdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_STZONE,0,1,2,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end