-- 死の罪宝－ルシエラ
-- Tainted Treasure of Doom – Luciela
-- Scripted by Satella
local s,id=GetID()
function s.initial_effect(c)
	-- Apply effects 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- Unaffected by monster effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3101)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(function(e,te) return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetHandler() end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		local resetcount=Duel.GetCurrentPhase()==PHASE_STANDBY and 2 or 1
		local prevturn=Duel.GetTurnCount()
		-- Send to the GY during the next Standby Phase
		aux.DelayedOperation(tc,PHASE_STANDBY,id,e,tp,function(ag) Duel.SendtoGrave(ag,REASON_EFFECT) end,function() return Duel.GetTurnCount()~=prevturn end,0,resetcount,aux.Stringid(id,1))
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		local dg=Group.CreateGroup()
		for c in g:Iter() do
			local preatk=c:GetAttack()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-tc:GetAttack())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
			if preatk~=0 and c:GetAttack()==0 then dg:AddCard(c) end
		end
		if #dg==0 then return end
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end