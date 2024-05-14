--リヴァーチュ・ドラゴン
--Levirtue Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,3,2)
	--Add 1 "Virtue Stream" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={id,101206208} --"Virtue Stream"
function s.thfilter(c)
	return c:IsCode(101206208) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.thgyfilter(c)
	return c:IsRace(RACE_FISH|RACE_SEASERPENT|RACE_AQUA) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.xyztarget(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
function s.overlayfilter(c)
	return c:GetOverlayCount()>0
end
function s.rescon(sg,e,tp)
	return sg:IsExists(s.overlayfilter,1,nil)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) and Duel.IsExistingMatchingCard(s.thgyfilter,tp,LOCATION_GRAVE,0,1,nil)
	local g=Duel.GetMatchingGroup(s.xyztarget,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	local b2=#g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
		Duel.SetTargetCard(g)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Add 1 Fish, Sea Serpent, or Aqua monster from your GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Attach 1 Xyz material from one of the targets to the other
		local g=Duel.GetTargetCards(e)
		if #g~=2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local detachxyz=g:FilterSelect(tp,s.overlayfilter,1,1,nil):GetFirst()
		local attachxyz=g:RemoveCard(detachxyz):GetFirst()
		local attach_group=detachxyz:GetOverlayGroup()
		if #attach_group>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			attach_group=attach_group:Select(tp,1,1,nil)
		end
		Duel.Overlay(attachxyz,attach_group)
		Duel.RaiseSingleEvent(detachxyz,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end