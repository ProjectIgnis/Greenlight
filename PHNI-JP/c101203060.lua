--百鬼羅刹大集会
--Grand Meeting of the Goblin Riders
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--"Goblin" monsters you control gain 300 ATK for each "Goblin" monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GOBLIN))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Additional Normal Summon for a "Goblin" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GOBLIN))
	c:RegisterEffect(e3)
	--Change the levels of 2 "Goblin" monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_LVCHANGE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GOBLIN}
function s.atkval(e,c)
	return 300*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_GOBLIN),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_GOBLIN) and c:HasLevel() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==2 or
		not sg:IsExists(Card.IsLevel,1,nil,sg:GetSum(Card.GetOriginalLevel))
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
	local b1=sg:GetClassCount(Card.GetLevel)==2
	local b2=not sg:IsExists(Card.IsLevel,1,nil,sg:GetSum(Card.GetOriginalLevel))
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,sg,2,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g~=2 then return end
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		if g:GetClassCount(Card.GetLevel)==1 then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4)) --"Select a monster to change its level"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.HintSelection(Group.FromCards(tc),true)
		Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())

		local tc1,tc2=g:GetFirst(),g:GetNext()
		if tc1==tc then
			tc1,tc2=tc2,tc1
		end

		local lv=tc1:GetLevel()
		--The Level of the selected monster becomes the Level of the other
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif op==2 then
		local lv=g:GetSum(Card.GetOriginalLevel)
		if g:IsExists(Card.IsLevel,1,nil,lv) then return end
		--The Levels of both monsters become their combined original Levels
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end