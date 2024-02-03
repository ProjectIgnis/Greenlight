--石板の神殿
--Temple of the Stone Slabs
--Scripted by Eerie Code
local CARD_SENGENJIN=76232340
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Place 1 monster in the Spell/Trap Zone as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
	--Place monsters in the S/T Zone when they are destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MILLENNIUM))
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MILLENNIUM}
s.listed_names={CARD_SENGENJIN}
function s.place(c,hc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return false end
	local e1=Effect.CreateEffect(hc)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	return true
end
function s.stfilter(c)
	return c:IsMonster() and not c:IsForbidden()
end
function s.stfilter2(c)
	return s.stfilter(c) and (c:IsSetCard(SET_MILLENNIUM) or c:IsCode(CARD_SENGENJIN))
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.stfilter2,tp,LOCATION_DECK,0,1,nil) end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g1=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g1>0 and s.place(g1:GetFirst(),c,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g2=Duel.SelectMatchingCard(tp,s.stfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.BreakEffect()
			s.place(g2:GetFirst(),c,tp)
		end
	end
end
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end