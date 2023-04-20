--Japanese name
--Gold Pride – Chariot Carrier
--scripted by fiftyfour
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	--Detach to add Gold Pride Spell
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.decost)
	e1:SetTarget(s.detarget)
	e1:SetOperation(s.deoperation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Return to Extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={96305350}
s.listed_series={SET_GOLD_PRIDE}
function s.decost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.detarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.defilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)

end
function s.defilter(c)
	return c:IsSetCard(SET_GOLD_PRIDE) and c:IsSpell() and c:IsAbleToHand()
end
function s.gyfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_GOLD_PRIDE) and c:IsAbleToGrave()
end
function s.deoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.defilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
			local cg=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_DECK,0,nil)
			if #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				local gyg=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #gyg>0 then
					Duel.SendtoGrave(gyg,REASON_EFFECT)
				end
			end
		end
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(96305350) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToExtra() and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end