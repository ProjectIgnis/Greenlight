--黒魔術のバリア －ミラーフォース－
--Dark Magic Mirror Force
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate (on attack)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate (on effect)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_GOLD_SARC_OF_LIGHT }
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_GOLD_SARC_OF_LIGHT),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return s.condition(e,tp,eg,ep,ev,re,r,rp) and Duel.GetTurnPlayer()~=tp
end
function s.cfilter(c)
	return c:IsOnField() and c:IsMonster()
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and s.condition(e,tp,eg,ep,ev,re,r,rp) and tc+tg:FilterCount(s.cfilter,nil)-#tg>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.ListsCode,CARD_GOLD_SARC_OF_LIGHT))
	e1:SetValue(s.indct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,nil) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
function s.indct(e,re,r,rp)
	if (r&(REASON_BATTLE|REASON_EFFECT))~=0 then
		return 1
	else return 0 end
end
