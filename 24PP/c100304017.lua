--シンクロ・パニック
--Synchro Panic
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Tuner and any number of non-Tuners from your GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_CUSTOM+id)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local g1=Group.CreateGroup()
	g1:KeepAlive()
	e1a:SetLabelObject(g1)
	--Use a global effect because the regular efffect didnt work while it was face-down
	aux.GlobalCheck(s,function()
		--Keep track of the destroyed Synchro monsters
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e0:SetCode(EVENT_DESTROYED)
		e0:SetRange(LOCATION_SZONE)
		e0:SetLabelObject(e1a)
		e0:SetCondition(s.synchregcon)
		e0:SetOperation(s.synchregop)
		Duel.RegisterEffect(e0,0)
	end)
	--Keep track of the destroyed Synchro monsters
	--[[
		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE) --does this flag work here?
		e1b:SetCode(EVENT_DESTROYED)
		e1b:SetRange(LOCATION_SZONE)
		e1b:SetLabelObject(e1a)
		e1b:SetOperation(s.synchregop)
		c:RegisterEffect(e1b)
	]]--
	--Neither player can Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(function(e,c,tp,sumtp,sumpos) return (sumtp&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO end)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp,e)
	return c:IsType(TYPE_SYNCHRO) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		--and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.synchregcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandlerPlayer(),e)
end
function s.synchregop(e,tp,eg,ep,ev,re,r,rp)
	tp=e:GetHandlerPlayer()
	local tg=eg:Filter(s.cfilter,nil,tp,e)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.spfilter(c,e,tp)
	return c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(lvl)
	return function(sg,e,tp,mg)
		return sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
			and sg:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
			and sg:GetSum(Card.GetLevel)==lvl
		end
end
function s.rescon2(sumg,ct)
	return function(sg,e,tp,mg)
		return sg:IsExists(s.specialcheck,1,nil,sumg,ct) end
end
function s.specialcheck(c,sumg,ct)
	return sumg:IsExists(Card.IsType,1,nil,TYPE_TUNER)
		and sumg:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
		and sumg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,ct)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local synchg=e:GetLabelObject():Filter(s.cfilter,nil,tp,e)
	--Note: target redirection not properly handled yet
	--(need to also check if the level of the target would be correct to summon monsters?)
	if chkc then return synchg:IsContains(chkc) and s.cfilter(chkc,tp,nil) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ct=math.min(ft,#sumg)
	--Note: I am assuming you need to summon 1 tuner and at least 1 non-tuner. Can you summon just 1 tuner and nothing else?
	if chk==0 then return ft>=2 and #sumg>=2 and
		--trying to make it less costy when there is only 1 Synchro to target
		((#synchg==1 and aux.SelectUnselectGroup(sumg,e,tp,2,ct,s.rescon(synchg:GetFirst():GetLevel()),0))
		--version for when there are multiple Synchros to target
		or aux.SelectUnselectGroup(synchg,e,tp,1,1,s.rescon2(sumg,ct),0))
	end
	local tc=nil
	if #synchg==1 then
		tc=synchg:GetFirst()
		Duel.SetTargetCard(tc)
	else
		local syncg=aux.SelectUnselectGroup(synchg,e,tp,1,1,s.rescon2(sumg,ct),1,tp,HINTMSG_TARGET,s.rescon2(sumg,ct))
		tc=syncg:GetFirst()
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,LOCATION_GRAVE)
	--Destroy this card during your 3rd Standby Phase after activation
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.sdescon)
	e1:SetOperation(s.sdesop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,3)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	--Special Summon 1 Tuner and any number of non-Tuners from your GY, whose total Levels equal that monster's
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<2 or #g<2 then return end
	local lvl=tc:GetLevel()
	Debug.Message("The level is "..lvl)
	Debug.Message("number of possible monster to summon is "..#g)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,math.min(ft,#g),s.rescon(lvl),1,tp,HINTMSG_SPSUMMON,s.rescon(lvl))
	if #sg==0 then return end
	for tc in sg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			--Summoned monsters cannot be destroyed by battle or card effects this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3000)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetDescription(3001)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		Duel.Destroy(c,REASON_RULE)
	end
end