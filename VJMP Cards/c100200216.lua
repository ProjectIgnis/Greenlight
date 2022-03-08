-- 悪魔嬢ロリス
-- Loris, Lady of Lament
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rlsetcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.tgsetcon)
	c:RegisterEffect(e3)
end
function s.drfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_TRAP and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and s.drfilter(chkc) end
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=3 and Duel.IsPlayerCanDraw(tp,1) end
	local op=(#g>=6 and Duel.IsPlayerCanDraw(tp,2))
		and Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		or Duel.SelectOption(tp,aux.Stringid(id,0))
	local ct=3*op+3
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=g:Select(tp,ct,ct,nil)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,op+1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg<1 or Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)<0 then return end
	local g=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	local ct=#g
	if ct<1 then return end
	local ct1=g:FilterCount(Card.IsControler,nil,tp)
	if ct1>0 then
		Duel.SortDeckbottom(tp,tp,ct1)
	end
	if ct>ct1 then
		Duel.SortDeckbottom(tp,1-tp,ct-ct1)
	end
	if ct>=3 then
		Duel.BreakEffect()
		Duel.Draw(tp,ct//3,REASON_EFFECT)
	end
end
function s.rlsetconfilter(c)
	return c:IsMonster() or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER)
end
function s.rlsetcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rlsetconfilter,1,e:GetHandler())
end
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
	end
end
function s.tgsetconfilter(c,tp)
	return c:GetType()==TYPE_TRAP and c:IsPreviousControler(tp)
end
function s.tgsetcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and r&REASON_EFFECT==REASON_EFFECT and eg:IsExists(s.tgsetconfilter,1,e:GetHandler(),tp)
end