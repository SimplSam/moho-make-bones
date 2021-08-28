-- **************************************************
-- Intro
-- **************************************************

ScriptName = "SS_MakeBones"

-- **************************************************
-- Make Bones - Split, Clone & Reform
-- version:	001.0 AS11-MH13.5 #510803/510828
-- by Sam Cogheil (SimplSam)
-- **************************************************

--[[ ***** Licence & Warranty *****

	This work is licensed under a GNU General Public License v3.0 license
	Please see: https://www.gnu.org/licenses/gpl-3.0.en.html

	You can:
		Usage - Use/Reuse Freely
		Adapt - remix, transform, and build upon the material for any purpose, even commercially
		Share - copy and redistribute the material in any medium or format

	Adapt / Share under the following terms:
		Attribution - You must give appropriate credit, provide a link to the GPL-3.0 license, and
		indicate if changes were made. You may do so in any reasonable manner, but not in any way
		that suggests the licensor endorses you or your use.

        ShareAlike - If you remix, transform, or build upon the material, you must distribute your
        contributions under the same license as this original.

	Warranty:

		Your use of this software material is at your own risk.

		By accepting to use this material you acknowledge that Sam Cogheil / SimplSam
		("The Developer") make no warranties whatsoever - expressed or implied for the
		merchantability or fitness for a particular purpose of the software provided.

		The Developer will not be liable for any direct, indirect or consequential loss
		of actual or anticipated - data, revenue, profits, business, trade or goodwill
		that is suffered as a result of the use of the software provided.

--]]

--[[
	***** SPECIAL THANKS to:
	*    Stan (and team) @ MOHO Scripting -- http://mohoscripting.com
	*    The friendly faces @ Lost Marble Moho forum -- https://www.lostmarble.com/forum
	*****
]]

SS_MakeBones = {}
SS_MakeBones._MOHO_Version = -1

function SS_MakeBones:Name()
	return "Make Bones"
end

function SS_MakeBones:Version()
	return "1.0 #510828"
end

function SS_MakeBones:Description()
	return "Make Bones"
end

function SS_MakeBones:Creator()
	return "Sam Cogheil (SimplSam)"
end

function SS_MakeBones:UILabel()
	return "Make Bones"
end

function SS_MakeBones:IsEnabled(moho)
	if (not (moho.layer:IsBoneType())) or (moho.document:CurrentDocAction() ~= "")
            or (moho:CountSelectedBones(false) < 1) then
        return false
    end
end

function SS_MakeBones:IsRelevant(moho)
    return (moho:Skeleton() ~= nil) --and (moho.frame == 0)
end

function SS_MakeBones:ColorizeIcon()
    return true
end

-- **************************************************
-- Dialog
-- **************************************************

SS_MakeBones.pieces   = 2
SS_MakeBones.strength = false
SS_MakeBones.parented = true
SS_MakeBones.rescaled = true
SS_MakeBones.weighted = false
SS_MakeBones.angle    = 0
SS_MakeBones.reangled = false
SS_MakeBones.chained  = true
SS_MakeBones.shared   = false

function SS_MakeBones:LoadPrefs(prefs)
    self.pieces   = prefs:GetInt("SS_MakeBonesDialog.pieces", 2)
    self.strength = prefs:GetBool("SS_MakeBonesDialog.strength", false)
    self.parented = prefs:GetBool("SS_MakeBonesDialog.parented", true)
    self.rescaled = prefs:GetBool("SS_MakeBonesDialog.rescaled", true)
    self.weighted = prefs:GetBool("SS_MakeBonesDialog.weighted", false)
    self.angle    = prefs:GetFloat("SS_MakeBonesDialog.angle", 0)
    self.reangled = prefs:GetBool("SS_MakeBonesDialog.reangled", false)
    self.chained  = prefs:GetBool("SS_MakeBonesDialog.chained", true)
    self.shared   = prefs:GetBool("SS_MakeBonesDialog.shared", false)
end

function SS_MakeBones:SavePrefs(prefs)
    prefs:SetInt("SS_MakeBonesDialog.pieces", self.pieces)
    prefs:SetBool("SS_MakeBonesDialog.strength", self.strength)
    prefs:SetBool("SS_MakeBonesDialog.parented", self.parented)
    prefs:SetBool("SS_MakeBonesDialog.rescaled", self.rescaled)
    prefs:SetBool("SS_MakeBonesDialog.weighted", self.weighted)
    prefs:SetFloat("SS_MakeBonesDialog.angle", self.angle)
    prefs:SetBool("SS_MakeBonesDialog.reangled", self.reangled)
    prefs:SetBool("SS_MakeBonesDialog.chained", self.chained)
    prefs:SetBool("SS_MakeBonesDialog.shared", self.shared)
end

function SS_MakeBones:ResetPrefs()
    self.pieces   = 2
    self.strength = false
    self.parented = true
    self.rescaled = true
    self.weighted = false
    self.angle    = 0
    self.reangled = false
    self.chained  = true
    self.shared   = false
end

local SS_MakeBonesDialog = {}

SS_MakeBonesDialog.MSG_BASE = MOHO.MSG_BASE +91612 --TODO MH13.5 BUG ??? MH12/13 OK using 0
SS_MakeBonesDialog.PIECES   = SS_MakeBonesDialog.MSG_BASE
SS_MakeBonesDialog.STRENGTH = SS_MakeBonesDialog.MSG_BASE + 1
SS_MakeBonesDialog.RESCALED = SS_MakeBonesDialog.MSG_BASE + 2
SS_MakeBonesDialog.WEIGHTED = SS_MakeBonesDialog.MSG_BASE + 3
SS_MakeBonesDialog.ANGLE    = SS_MakeBonesDialog.MSG_BASE + 4
SS_MakeBonesDialog.PARENTED = SS_MakeBonesDialog.MSG_BASE + 5
SS_MakeBonesDialog.REANGLE  = SS_MakeBonesDialog.MSG_BASE + 6
SS_MakeBonesDialog.RESET    = SS_MakeBonesDialog.MSG_BASE + 7
SS_MakeBonesDialog.CHAINED  = SS_MakeBonesDialog.MSG_BASE + 8
SS_MakeBonesDialog.GROUPED  = SS_MakeBonesDialog.MSG_BASE + 9

function SS_MakeBonesDialog:new()
    local d = LM.GUI.SimpleDialog("Let's Make Some Bones ...", SS_MakeBonesDialog)
    local l = d:GetLayout()

    d.piecesInput = LM.GUI.TextControl(0, '999', d.PIECES, LM.GUI.FIELD_UINT, 'Number of Pieces:')
    l:AddChild(d.piecesInput, LM.GUI.ALIGN_LEFT, 0)

    l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)

    d.parentedCheckbox = LM.GUI.CheckBox('Parental Link', d.PARENTED)
    l:AddChild(d.parentedCheckbox, LM.GUI.ALIGN_LEFT, 0)
    l:PushH(LM.GUI.ALIGN_CENTER, 20)
        d.chainedRadio = LM.GUI.RadioButton('Chained', d.CHAINED)
        l:AddChild(d.chainedRadio, LM.GUI.ALIGN_LEFT, 0)
        d.sharedRadio = LM.GUI.RadioButton('Shared', d.GROUPED)
        l:AddChild(d.sharedRadio, LM.GUI.ALIGN_LEFT, 0)
    l:Pop()

    l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)

    d.rescaledCheckbox =  LM.GUI.CheckBox('Rescale', d.RESCALED)
    l:AddChild(d.rescaledCheckbox, LM.GUI.ALIGN_LEFT, 0)
        d.weightedCheckbox =  LM.GUI.CheckBox('Weighted', d.WEIGHTED)
        l:AddChild(d.weightedCheckbox, LM.GUI.ALIGN_LEFT, 20)
        d.strengthCheckbox = LM.GUI.CheckBox('Scale Strength', d.STRENGTH)
        l:AddChild(d.strengthCheckbox, LM.GUI.ALIGN_LEFT, 20)

    l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)

    d.angleText = LM.GUI.StaticText('Angle Offset')
    l:AddChild(d.angleText, LM.GUI.ALIGN_LEFT, 0)
    d.angleDial = ( (SS_MakeBones._MOHO_Version >= 12) and LM.GUI.AngleWidget(d.ANGLE, true) or LM.GUI.AngleWidget(d.ANGLE) )
    l:AddChild(d.angleDial, LM.GUI.ALIGN_LEFT, 10)

    d.reangledCheckbox = LM.GUI.CheckBox('ReAngle First Bone', d.REANGLE)
    l:AddChild(d.reangledCheckbox, LM.GUI.ALIGN_LEFT, 20)

    -- l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)
    --     d.menu = LM.GUI.Menu("Menu")
    --     d.popup = LM.GUI.PopupMenu(100, false)
    --     d.popup:SetMenu(d.menu)
    --     l:AddChild(d.popup)
    --     d.menu:AddItem("Item 1", 0, 12345)

    l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)
    l:PushH()
        d.resetText = LM.GUI.StaticText('Reset to defaults:')
        l:AddChild(d.resetText, LM.GUI.ALIGN_LEFT, 0)
        d.resetButton = LM.GUI.Button('Reset', d.RESET)
        l:AddChild(d.resetButton, LM.GUI.ALIGN_LEFT, 0)
    l:Pop()

    return d
end

function SS_MakeBonesDialog:UpdateWidgets()
    self.piecesInput:SetValue(SS_MakeBones.pieces)
    self.strengthCheckbox:SetValue(SS_MakeBones.strength)
    self.parentedCheckbox:SetValue(SS_MakeBones.parented)
    self.rescaledCheckbox:SetValue(SS_MakeBones.rescaled)
    self.weightedCheckbox:SetValue(SS_MakeBones.weighted)
    self.angleDial:SetValue(SS_MakeBones.angle)
    self.reangledCheckbox:SetValue(SS_MakeBones.reangled)
    self.chainedRadio:SetValue(SS_MakeBones.chained)
    self.sharedRadio:SetValue(SS_MakeBones.shared)

    self.weightedCheckbox:Enable(self.rescaledCheckbox:Value())
    self.strengthCheckbox:Enable(self.rescaledCheckbox:Value())
    self.reangledCheckbox:Enable(self.angleDial:Value() > 0)
    self.chainedRadio:Enable(self.parentedCheckbox:Value())
    self.sharedRadio:Enable(self.parentedCheckbox:Value())
end

function SS_MakeBonesDialog:OnOK(moho)
    SS_MakeBones.pieces   = self.piecesInput:IntValue()
    SS_MakeBones.strength = self.strengthCheckbox:Value()
    SS_MakeBones.parented = self.parentedCheckbox:Value()
    SS_MakeBones.rescaled = self.rescaledCheckbox:Value()
    SS_MakeBones.weighted = self.weightedCheckbox:Value()
    SS_MakeBones.angle    = self.angleDial:Value()
    SS_MakeBones.reangled = self.reangledCheckbox:Value()
    SS_MakeBones.chained  = self.chainedRadio:Value()
    SS_MakeBones.shared   = self.sharedRadio:Value()
end

function SS_MakeBonesDialog:HandleMessage(msg)
    if msg == self.RESET then
        SS_MakeBones:ResetPrefs()
        self:UpdateWidgets()
    elseif msg == self.PIECES then
        self.piecesInput:SetValue(LM.Clamp(self.piecesInput:IntValue(), 2, 999))
    elseif msg == self.PARENTED then
        self.chainedRadio:Enable(self.parentedCheckbox:Value())
        self.sharedRadio:Enable(self.parentedCheckbox:Value())
    elseif msg == self.RESCALED then
        self.weightedCheckbox:Enable(self.rescaledCheckbox:Value())
        self.strengthCheckbox:Enable(self.rescaledCheckbox:Value())
    elseif msg == self.ANGLE then
        self.reangledCheckbox:Enable(self.angleDial:Value() > 0)
    end
end

-- **************************************************
-- The guts of this script
-- **************************************************

function SS_MakeBones:Run(moho)

    SS_MakeBones._MOHO_Version = moho:AppVersion() and moho:AppVersion():match("(%d+%.?%d*)")+0 or -1
    local boneLayer = moho:LayerAsBone(moho.layer)
	local skel = moho:Skeleton()

    local dlog = SS_MakeBonesDialog:new()
    if (dlog:DoModal() == LM.GUI.MSG_CANCEL) then
        return
    end

    local function GetFiboWeights(_length, _splits)
        local function fibo(n)
            return (n>2) and (fibo(n-1) + fibo(n-2)) or 1 --< #Ref: inspired by http://progopedia.com/example/fibonacci/37/
        end
        local hi = fibo(_splits +2)
        local lo = fibo(_splits +1)
        local dv = hi + lo -2
        local len0 = _length / dv
        local len1, len2 = len0, len1
        local _parts = {}
        for i = 1, _splits do
          table.insert(_parts, len0)
          len2 = len1
          len1 = len0
          len0 = len0 + len2
        end
        for i=1, math.floor(#_parts / 2) do
            _parts[i], _parts[#_parts - i + 1] = _parts[#_parts - i + 1], _parts[i]
        end
        return(_parts)
    end

    moho.document:PrepUndo(moho.layer)
	moho.document:SetDirty()

    local frame0, curFrame = 0, moho.frame
    local selectedBones = {}
    for iBone =0, skel:CountBones(false) -1 do
        if (skel:Bone(iBone).fSelected) then
            table.insert(selectedBones, iBone)
        end
    end

    for iBone =1, #selectedBones do
        local boneID = selectedBones[iBone]
        local bone = skel:Bone(boneID)
        local fiboFactor, when
        local boneLen = bone.fLength
        local newBoneLen = boneLen
        local boneStrength = bone.fStrength
        local boneAngle = bone.fAngle
        local newAngle = boneAngle
        local childBones = {}
        local baseHasParent = bone.fParent ~= -1

        if ((SS_MakeBones._MOHO_Version >= 12) and (not bone:IsZeroLength())) or (bone.fLength > 0.0001) then --no pins

            -- find children of the base bone (inc. animated)
            for _iBone =0, skel:CountBones() -1 do
                local childBone = skel:Bone(_iBone)
                for iKey = 0, childBone.fAnimParent:CountKeys() -1 do
                    when = childBone.fAnimParent:GetKeyWhen(iKey)
                    if (childBone.fAnimParent:GetValue(when) == boneID) then
                        table.insert(childBones, _iBone)
                        break
                    end
                end
            end

            -- base bone
            if (SS_MakeBones.rescaled) then
                if (SS_MakeBones.weighted) then
                    fiboFactor = GetFiboWeights(boneLen, SS_MakeBones.pieces)
                    newBoneLen = fiboFactor[1]
                else
                    newBoneLen = boneLen / SS_MakeBones.pieces
                end
            end
            bone.fLength   = newBoneLen --todo @ 0?
            bone.fStrength = boneStrength * (SS_MakeBones.strength and (newBoneLen / boneLen) or 1)
            if (SS_MakeBones.reangled) then
                bone.fAngle = bone.fAngle + SS_MakeBones.angle
                bone.fAnimAngle:SetValue(curFrame, bone.fAngle)
            end

            -- new bones
            local lastBone, lastBoneID, lastBoneLen = bone, boneID, newBoneLen
            local lastBonePos, lastBoneTip = LM.Vector2:new_local(), LM.Vector2:new_local()
            local xd = lastBoneLen * math.cos(boneAngle)
            local yd = lastBoneLen * math.sin(boneAngle)

            if (baseHasParent) then
                lastBonePos:Set(lastBone.fPos)
                lastBoneTip:Set(lastBonePos.x + xd, lastBonePos.y + yd)
                if (SS_MakeBones.parented) then
                    newAngle = boneAngle + SS_MakeBones.angle
                else
                    local parentBone = skel:Bone(bone.fParent)
                    parentBone.fMovedMatrix:Transform(lastBonePos)
                    parentBone.fMovedMatrix:Transform(lastBoneTip)
                    newAngle = math.atan2(lastBoneTip.y - lastBonePos.y, lastBoneTip.x - lastBonePos.x) + SS_MakeBones.angle
                end
            else
                lastBoneTip:Set(lastBone.fPos.x + xd, lastBone.fPos.y + yd)
                if (SS_MakeBones.parented and SS_MakeBones.chained) then
                    newAngle = SS_MakeBones.angle
                else
                    newAngle = boneAngle + SS_MakeBones.angle
                end
            end

            local newBone, newBoneID
            for _iBone =2, SS_MakeBones.pieces do
                newBone   = skel:AddBone(frame0)
                newBoneID = skel:BoneID(newBone)
                newBone:SetName(bone:Name())
                if (SS_MakeBones._MOHO_Version >= 12) then
                    skel:MakeBoneNameUnique(newBoneID)
                end

                if (SS_MakeBones.parented) then
                    if (SS_MakeBones.chained) then
                        newBone.fParent = lastBoneID
                        newBone.fAnimParent:SetValue(frame0, lastBoneID)
                        lastBoneTip:Set(newBoneLen, 0)
                    else -- shared
                        if (baseHasParent) then
                            newBone.fParent = bone.fParent
                            newBone.fAnimParent:SetValue(frame0, bone.fParent)
                        end
                    end
                end
                newBone.fPos:Set(lastBoneTip)
                newBone.fAnimPos:SetValue(frame0, newBone.fPos)  --todo @ 0?

                if (SS_MakeBones.rescaled and SS_MakeBones.weighted) then
                    newBoneLen = fiboFactor[_iBone]
                end
                newBone.fLength = newBoneLen
                newBone.fAngle = (SS_MakeBones.parented and baseHasParent and (not SS_MakeBones.shared)) and SS_MakeBones.angle or newAngle
                newBone.fAnimAngle:SetValue(frame0, newBone.fAngle)

                newBone.fStrength = boneStrength * (SS_MakeBones.strength and (newBoneLen / boneLen) or 1)
                newBone:SetTags(bone:Tags()) -- color
                skel:UpdateBoneMatrix(newBoneID)

                -- next new bone
                lastBone, lastBoneID, lastBoneLen = newBone, newBoneID, newBoneLen
                if (SS_MakeBones.shared) or (not SS_MakeBones.parented) then
                    if (baseHasParent and (SS_MakeBones.shared or (not SS_MakeBones.parented))) then
                        xd = lastBoneLen * math.cos(lastBone.fAngle -SS_MakeBones.angle) --todo @ 0?
                        yd = lastBoneLen * math.sin(lastBone.fAngle -SS_MakeBones.angle)
                    else
                        xd = lastBoneLen * math.cos(boneAngle)
                        yd = lastBoneLen * math.sin(boneAngle)
                    end
                    lastBoneTip:Set(lastBone.fPos.x + xd, lastBone.fPos.y + yd)
                    newAngle = lastBone.fAngle
                end
            end

            -- fixup original child bones
            if (#childBones > 0) then
                local xOffset = boneLen - newBoneLen
                for _, childBoneID in ipairs(childBones) do
                    local childBone = skel:Bone(childBoneID)

                    -- rePosition (inc. animated)
                    if (childBone.fParent == boneID) then
                        childBone.fPos:Set(childBone.fPos.x - xOffset, childBone.fPos.y)
                    end
                    for iKey = 0, childBone.fAnimPos:CountKeys() -1 do
                        when = childBone.fAnimPos:GetKeyWhen(iKey)
                        if (childBone.fAnimParent:GetValue(when) == boneID) then
                            local xyPos = childBone.fAnimPos:GetValue(when)
                            xyPos.x = xyPos.x - xOffset
                            childBone.fAnimPos:SetValue(when, xyPos)
                        end
                    end

                    -- reParent (inc. animated)
                    if (childBone.fParent == boneID) then
                        childBone.fParent = lastBoneID
                    end
                    for iKey = 0, childBone.fAnimParent:CountKeys() -1 do
                        when = childBone.fAnimParent:GetKeyWhen(iKey)
                        if (childBone.fAnimParent:GetValue(when) == boneID) then
                            childBone.fAnimParent:SetValue(when, lastBoneID)
                        end
                    end
                    skel:UpdateBoneMatrix(childBoneID)
                end
            end
        end
    end
end