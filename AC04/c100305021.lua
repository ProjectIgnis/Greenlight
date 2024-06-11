--Ｅｍカップ・トリッカー
--Performage Cup Tricker
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Attach this card to 1 "Performage" Xyz monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pendattachtg)
	e1:SetOperation(s.pendattachop)
	c:RegisterEffect(e1)
	--Add 1 "Performage" monster from your face-up Extra Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Detach 1 material from an Xyz monster to Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Attach 1 material from 1 Xyz monster to another Xyz monster
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.attachcon)
	e4:SetTarget(s.attachtg)
	e4:SetOperation(s.attachop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_PERFORMAGE}
function s.pendattachfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_PERFORMAGE)
end
function s.pendattachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.pendattachfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pendattachfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,s.pendattachfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.pendattachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_PERFORMAGE) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.detachfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.detachfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.detachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.detachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local og=tc:GetOverlayGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 or #og==0 or not tc then return end
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local dc=og:Select(tp,1,1,nil)
		if Duel.SendtoGrave(dc,REASON_EFFECT)>0 then
			Duel.RaiseSingleEvent(dc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local ac=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,TYPE_XYZ):GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-600)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			ac:RegisterEffect(e1)
		end
	end
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.overlayfilter,1,nil)
end
function s.overlayfilter(c)
	return c:GetOverlayCount()>0
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
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