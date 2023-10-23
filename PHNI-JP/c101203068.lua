--アロマブレンド
--Aroma Blend
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Humid Winds/Dried Winds/Blessed Winds" face-up in the Spell/Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tfcost)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Plant Fusion Monster
	local params={handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),
				matfilter=Card.IsAbleToRemove,extrafil=s.extrafil,
				extraop=Fusion.BanishMaterial,extratg=s.extrtarget}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end
s.listed_names={28265983,92266279,15177750} --Humid Winds, Dried Winds, Blessed Winds
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.tffilter(c,tp)
	return c:IsCode(28265983,92266279,15177750) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if c:IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.extrafil(e,tp,mg)
	if not (Duel.GetLP(tp)>Duel.GetLP(1-tp)) then return nil end
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
end
function s.extrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
--[[
Aroma Blend
Normal Spell
You can only use the (1) and (2) effects of this card's name once per turn.
(1) Discard 1 card; Place 1 "Humid Winds", "Dried Winds", or "Blessed Winds" from your hand or Deck face-up in your Spell & Trap Zone.
(2) You can banish this card from your GY; Fusion Summon 1 Plant Fusion Monster, by banishing Fusion Material monsters from your hand and/or field, or if your LP is higher than your opponent's, you can also banish Plant monsters from your GY as Fusion Material.
]]--