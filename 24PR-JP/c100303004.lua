--ライフハック
--Life Hack
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Targeted monster's ATK becomes your opponent's current LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcond)
	e1:SetTarget(s.atktg1)
	e1:SetOperation(s.atkop1)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	--Targeted monster's ATK becomes your current LP
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetLabel(2)
	c:RegisterEffect(e2)
end
function s.atkcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.filter(c,p)
	return c:IsFaceup() and c:GetAttack()~=Duel.GetLP(p)
end
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local p=e:GetLabel()==1 and 1-tp or tp
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,p) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,p) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,p)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,0)
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()==1 and 1-tp or tp
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Its ATK becomes the player's LP
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(Duel.GetLP(p))
		tc:RegisterEffect(e1)
	end
	--Any damage your opponent takes is halved
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(0,1)
	e1:SetValue(function(e,re,val,r,rp,rc) return val//2 end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end