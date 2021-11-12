-- 逢華妖麗譚－魔妖不知火語
-- Ghost Meets Girl - A Mayakashi and Shiranui's Tale
-- Scripted by Nellag 
local s,id=GetID()

-- Shiranui + Mayakashi
s.listed_series={0xd9, 0x121}

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.pspcost)
	e1:SetOperation(s.pspactivate)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	-- Graveyard Effect to Return 1 Banished Zombie to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.tgop)
	e2:SetTarget(s.tgtarget)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end
function s.pspcostfilter(c)
	return 
		 (c:IsSetCard(0xd9) or c:IsSetCard(0x121))
		and (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_LINK))
end
function s.pspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if (chk==0) then return Duel.CheckReleaseGroupCost(tp,s.pspcostfilter,1,false,nil,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local g=Duel.SelectReleaseGroupCost(tp,s.pspcostfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.pspfilter(e,c,tp)
	return c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_EXTRA) or c:IsLocation(LOCATION_DECK)
end
function s.pspactivate(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler();
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetCategory(CATEGORY_DISABLE_SUMMON)
	e0:SetDescription(aux.Stringid(id, 1))
	e0:SetTargetRange(1,1)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	e0:SetTarget(s.pspfilter)
	Duel.RegisterEffect(e0, tp)
end
function s.tgfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE)
end
function s.tgtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g = Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc, REASON_EFFECT+REASON_RETURN)
	end
end