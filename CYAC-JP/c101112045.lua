--星騎士 セイクリッド・カドケウス
--Tellarknight Constellar Caduceus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	--Add 1 "tellarknight" and/or 1 "Constellar" card from the Gy to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Apply the effect of 1 "tellarknight" or "Constellar" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.applycost)
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TELLARKNIGHT,SET_CONSTELLAR}
function s.thfilter(c,e)
	return c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_TELLARKNIGHT)==1 or sg:FilterCount(Card.IsSetCard,nil,SET_CONSTELLAR)==1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.rmvfilter(c,tp)
	if not (c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsAbleToRemoveAsCost()
		and c:IsHasEffect(id)) then 
		return false
	end
	local eff={c:GetCardEffect(id)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		local tg=te:GetTarget()
		if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then return true end
	end
	return false
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Debug.Message(Duel.GetMatchingGroupCount(s.rmvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp))
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and
		Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then
		Debug.Message("Card to apply is: "..tostring(tc:GetCode()))
		local eff={tc:GetCardEffect(id)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			local con=temp:GetCondition()
			local tg=temp:GetTarget()
			if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
				and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(ac,teh)
				table.insert(acd,temp:GetDescription())
			end
		end
		if #ac==1 then te=ac[1] elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in g:Iter() do
			etc:CreateEffectRelation(te)
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		for etc in g:Iter() do
			etc:ReleaseEffectRelation(te)
		end
	end
end