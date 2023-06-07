--超未来融合－オーバーフューチャー・フュージョン
--Over Future Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate 1 of two effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function s.exfilter(c,tp)
	return c.material and c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.tgfilter(c,fc)
	return c:IsAbleToGrave() and c:IsCode(table.unpack(fc.material))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local fusparams={handler=e:GetHandler(),fusfilter=s.ffilter,matfilter=aux.FALSE,
                     extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local b1=Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0
	local b2=Fusion.SummonEffTG(fusparams)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.GetFlagEffect(tp,id+100)==0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
		Fusion.SummonEffTG(fusparams)(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if not cc then return end
		Duel.ConfirmCards(1-tp,cc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,cc):GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			--Cannot Special Summon monsters with the same name
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			--Cannot activate monster effects of cards with the same name
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetValue(s.aclimit)
			Duel.RegisterEffect(e2,tp)
	end
	elseif op==2 then
		local fusparams={handler=e:GetHandler(),fusfilter=s.ffilter,matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
		Fusion.SummonEffOP(fusparams)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and re:GetHandler():IsCode(e:GetLabel())
end