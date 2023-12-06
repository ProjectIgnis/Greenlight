--炎王妃 ウルカニクス
--Fire King Consort Ulkanix
--Scripted by DyXel
local s,id=GetID()
function s.initial_effect(c)
	--Destroy + Search + Change level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special Summon Garunix when destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_DESTROY) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={23015896}
s.listed_series={0x81}
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACES_BEAST_BWARRIOR_WINGB) and c:IsAbleToHand()
end
function s.filter(c)
	return not c:IsPublic() or c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) and
		       Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	if #g1==0 or Duel.Destroy(g1,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,c)
	if #g2==0 then return end
	Duel.SendtoHand(g2,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g2)
	local lvl=g2:GetFirst():GetLevel()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() or lvl==c:GetLevel() or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.BreakEffect()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(lvl)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
