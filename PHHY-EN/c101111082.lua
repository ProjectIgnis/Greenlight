--Orphebull the Harmonious Bullfighter Bard
--Scripted by fiftyfour

local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Must be Special Summoned by own procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	--Special Summon Condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Banish destroyed monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		and ((c:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and aux.SpElimFilter(c,true)) or c:IsLocation(LOCATION_HAND))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,e:GetHandler(),ATTRIBUTE_DARK)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,e:GetHandler(),ATTRIBUTE_LIGHT)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-4 and #rg1>1 and #rg2>1 and aux.SelectUnselectGroup(rg1:Merge(rg2),e,tp,4,4,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,e:GetHandler(),ATTRIBUTE_DARK)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,e:GetHandler(),ATTRIBUTE_LIGHT)
	local rg=rg1:Clone()	
	rg:Merge(rg2)
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil)
	if	#g>0 then
		local tab={}
		for card in aux.Next(g) do
			table.insert(tab,card:GetCardID())
		end
		e:SetLabel(table.unpack(tab))
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Group.CreateGroup()
	for _,id in pairs({e:GetLabel()}) do
		local card=Duel.GetCardFromCardID(id)
		if not card then return end
		g:AddCard(card)
	end
	local hc=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	local gc=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	if hc>0 then
		--Attack gain
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(hc*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e:GetHandler():RegisterEffect(e1)
	end
	if gc>0then
		--Multiple attacks
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(gc-1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e2)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local bc=c:GetBattleTarget()
	if bc and bc:IsControler(1-tp) and bc:IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetLabelObject(bc)
		return true
	end
	return false
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
