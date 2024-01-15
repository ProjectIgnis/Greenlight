--連慄砲固定式
--Equation System Cannon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.star(c)
	return c:IsType(TYPE_XYZ) and c:GetRank() or c:GetLevel()
end
function s.rmfilter(c)
	return c:IsType(TYPE_FUSION|TYPE_XYZ) and c:IsAbleToRemove()
end
function s.sumcheck(ct)
	return  function(sg,e,tp,mg)
				return #sg==3 and sg:FilterCount(Card.IsType,nil,TYPE_XYZ)==2 
					and sg:FilterCount(Card.IsType,nil,TYPE_FUSION)==1 
					and sg:Filter(Card.IsType,nil,TYPE_XYZ):GetClassCount(Card.GetRank)==1
					and sg:GetSum(s.star)==ct
			end
end
function s.gyfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION|TYPE_XYZ) and not c:IsForbidden()
end
function s.gyfilter2(c,lv)
	return c:IsFaceup() and (c:HasLevel() or c:IsType(TYPE_XYZ)) and s.star(c)==lv
end
function s.sumcheck2(sg,e,tp,mg)
	return #sg==3 and sg:FilterCount(Card.IsType,nil,TYPE_XYZ)==1 
		and sg:FilterCount(Card.IsType,nil,TYPE_FUSION)==1
		and Duel.IsExistingMatchingCard(s.gyfilter2,tp,0,LOCATION_MZONE,1,nil,sg:GetSum(s.star))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,LOCATION_ONFIELD|LOCATION_HAND)
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.sumcheck(ct),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,LOCATION_ONFIELD|LOCATION_HAND)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,0,nil)
	local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.sumcheck(ct),1,tp,HINTMSG_REMOVE)
	if #rg==3 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==3 then
		local g2=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_REMOVED,0,nil)
		local rg2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if #rg2>0 and aux.SelectUnselectGroup(g2,e,tp,2,2,s.sumcheck2,0) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local yg=aux.SelectUnselectGroup(g2,e,tp,2,2,s.sumcheck2,1,tp,HINTMSG_TOGRAVE)
			if Duel.SendtoGrave(yg,REASON_EFFECT|REASON_RETURN)~=0 then 
				Duel.BreakEffect()
				Duel.Remove(rg2,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
