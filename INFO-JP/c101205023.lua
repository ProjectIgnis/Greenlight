--至天の魔王ミッシング・バロウズ
--Heavenly Demon King Missing Borous
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.spcheck(sg,e,tp,mg)
	return sg:CheckDifferentPropertyBinary(function(c) return c:GetType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP) end)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil,tp)
	return aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil,tp)
	local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #rg>0 then
		rg:KeepAlive()
		e:SetLabelObject(rg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	if not rg then return end
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	rg:DeleteGroup()
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and (c:IsFaceup() or not c:IsOnField())
end
function s.rmcheck(sg,e,tp,mg)
	return sg:IsExists(Card.IsMonster,1,nil) and sg:IsExists(Card.IsSpellTrap,2,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.rmcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rmcheck,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #rg==3 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
