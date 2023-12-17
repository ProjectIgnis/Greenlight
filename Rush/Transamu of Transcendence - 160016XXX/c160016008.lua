-- トランザム・プライム・アーマーノヴァ 
-- Transamu Praime Armornova
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(FLAG_TRIPLE_TRIBUTE,0,0,1)
	--tribute check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--summon/set with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),nil,s.otop)
	--Summon with 3 tribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(s.nscondition)
	e2:SetTarget(s.nstarget)
	e2:SetOperation(s.nsoperation)
	e2:SetValue(SUMMON_TYPE_TRIBUTE+1)
	c:RegisterEffect(e2)
	--tribute check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	--Gain ATK when it is Tribute Summoned
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_COST)
	e4:SetOperation(s.facechk)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- summon with 1 Tribute
function s.otop(g,e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	--change base attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1800)
	c:RegisterEffect(e1)
end
--triple tribute summon
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg)
		and (#sg==3 or (#sg==2 and sg:IsExists(Card.HasFlagEffect,1,nil,FLAG_HAS_DOUBLE_TRIBUTE)) or (#sg==1 and sg:IsExists(Card.HasFlagEffect,1,nil,160015135)))
end
function s.nscondition(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local mg=Duel.GetTributeGroup(c)
	return #mg>=1 and aux.SelectUnselectGroup(mg,e,tp,1,3,s.rescon,0)
end
function s.nstarget(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetTributeGroup(c)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,3,nil,1,tp,HINTMSG_TRIBUTE,s.rescon,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.nsoperation(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON|REASON_MATERIAL)
	g:DeleteGroup()
end
--atk up
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local lvl=0
	if #g==1 then
		for tc in g:Iter() do
			local clvl=tc:GetOriginalLevel()
			--Triple tribute handle according to Maju Garzett (Rush)
			if tc:GetFlagEffect(160015135)>0 then
				clvl=tc:GetOriginalLevel()*3
			end
			lvl=lvl+(clvl>=0 and clvl or 0)
		end
	elseif #g==2 then
		for tc in g:Iter() do
			local clvl=tc:GetOriginalLevel()
			--double tribute handle according to Maju Garzett (Rush)
			if tc:HasFlagEffect(FLAG_HAS_DOUBLE_TRIBUTE) then
				clvl=tc:GetOriginalLevel()*2
			end
			lvl=lvl+(clvl>=0 and clvl or 0)
		end
	else
		for tc in g:Iter() do
			local clvl=tc:GetOriginalLevel()
			lvl=lvl+(clvl>=0 and clvl or 0)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)		
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
		e2:SetValue(lvl*100)
		e:GetHandler():RegisterEffect(e2)
	end
end
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end