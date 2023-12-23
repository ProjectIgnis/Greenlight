--Transamu Praime Full Armor Nova
--トランザム・プライム・フルアーマーノヴァ
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_TRANSAMU_RAINAC,160016008)
		--Gains ATK per each Spellcaster monster with different name
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetLabel(5)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetLabel(10)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsMonster,e:GetHandler():GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)
	return g:GetClassCount(Card.GetRace)*100
end
function s.con(e)
	local g=Duel.GetMatchingGroup(Card.IsMonster,e:GetHandler():GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)
	return g:GetClassCount(Card.GetRace)>=e:GetLabel()
end