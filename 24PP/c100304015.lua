--白の循環礁
--White Circle Reef
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 Fish monster and search 1 monster with the same name or Special Summon it if you controlled a Synchro monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Target 2 Fish monsters in the GY with the same name to return to the deck and Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp,fishsync)
	return c:IsRace(RACE_FISH) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode(),fishsync)
end
function s.thfilter(c,e,tp,code,fishsync)
	return c:IsCode(code) and (c:IsAbleToHand() or
		(fishsync>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.fishsyncfilter(c)
	return c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local fishsync=Duel.GetMatchingGroupCount(s.fishsyncfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(c,e,tp,fishsync) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,fishsync) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,fishsync)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	if fishsync>0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	e:SetLabel(fishsync)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FISH) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local fishsync=e:GetLabel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code,fishsync):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp,
			function(sc)
				return fishsync>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function(sc)
				return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,2)
		)
	end
end
function s.fishfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.rescon(sg,e,tp,mg)
	return sg:CheckSameProperty(Card.GetCode) and sg:IsExists(s.spcheck,1,nil,sg,e,tp)
end
function s.spcheck(c,sg,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sg:FilterCount(Card.IsAbleToDeck,c)==1
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.fishfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,s.rescon,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,nil)
	g:RemoveCard(td)
	if #td>0 and Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and #g>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end