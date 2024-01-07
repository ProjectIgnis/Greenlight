--Slimey Disposition
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={46821314,73216412,5600127}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
--Special Summon Function
function s.spfilter(c,e,tp)
	return (c:IsCode(46821314) or c:IsCode(73216412)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
--Fusion Summon Fuctions
function s.matfilter(c)
	return (c:IsCode(46821314) or c:IsCode(73216412)) and c:IsCanBeFusionMaterial()
end
function s.fusfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCode(5600127)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.cfilter(c,e,tp)
	if not c:IsDiscardable() then return false end
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE|LOCATION_DECK,0,nil)
	local res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,mg2,mf,chkf)
		end
	end
	return res
end
function s.fusTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		--OPT Register (Special Summon from GY)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Special Summon "Humanoid Slime" or "Worm Drake" from GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3303)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e1:SetValue(1)
			sg:GetFirst():RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetValue(function(e,c) return not c:IsRace(RACE_DEVINE) end)
			sg:GetFirst():RegisterEffect(e2)
		end
	else
		--Fusion Summon "Humanoid Worm Drake"
		local g2=s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
		--OPT Register (Fusion Summon)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		s.fusTarget(e,tp,eg,ep,ev,re,r,rp,1)
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE|LOCATION_DECK,0,nil)
		local sg1=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2,sg2=nil,nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=aux.SelectUnselectGroup(mg1,e,tp,tc.min_material_count,tc.max_material_count,s.rescon,1,tp,HINTMSG_FMATERIAL)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1 and sg:GetClassCount(Card.GetCode)==#sg
end