local Chili = WG.Chili

VerificationCodeWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

vcode_win = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function Cancel(self)
    local win = self.win
    WG.LibLobby.lobby:Disconnect()
    win:Hide()
end

function Ok(self)
    local win = self.win

    local vcode = win.vcode.text
    win:Hide()

    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnDenied",
        function(listener, reason)
            Spring.Log("Menu", LOG.WARNING, reason)
            lobby:RemoveListener("OnDenied", listener)
            win:Show()
        end
    )
    lobby:ConfirmAgreement(vcode)
end

function VerificationCodeWindow:New(obj, login_win)
    self.login_win = login_win

    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.width = obj.width or '40%'
    obj.height = obj.height or '80%'
    obj.resizable = false
    obj.draggable = false

    obj = VerificationCodeWindow.inherited.New(self, obj)

    -- Agreement text
    -- ==============
    obj.scroll = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = obj.height - 148,
        horizontalScrollbar = false,
        BorderTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        BackgroundTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
    }
    obj.agreement_text = ""
    obj.agreement = Chili.TextBox:New {
        parent = obj.scroll,
        text = obj.agreement_text,
        font = {size = fontsize},
        x = "0%",
        y = "0%",
        width = "100%",
    }


    -- Login fields
    -- ============
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = obj.height - 148,
        width = '100%',
        height = 138,
        rows = 2,
        columns = 2,
    }

    obj.label = Chili.Label:New {
        parent = grid,
        caption = "Verification code ",
        align    = "center",
        valign   = "center",
    }
    obj.vcode = Chili.EditBox:New {
        parent = grid,
        text = "check email",
    }

    obj.cancel = Chili.Button:New {
        parent = grid,
        caption = "Cancel",
        OnMouseUp = { Cancel },
    }
    obj.ok = Chili.Button:New {
        parent = grid,
        caption = "Ok",
        OnMouseUp = { Ok },
    }

    -- Store references to the main object into the event triggers
    obj.ok.win = obj
    obj.cancel.win = obj

    -- Hiden by default
    obj:Hide()

    -- Events
    vcode_win = obj
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnAgreement", 
        function(listener, line)
            vcode_win.agreement_text = vcode_win.agreement_text .. line .. "\n"
        end
    )
    lobby:AddListener("OnAgreementEnd", 
        function(listener)
            vcode_win.agreement:Dispose()
            vcode_win.agreement = Chili.TextBox:New {
                parent = vcode_win.scroll,
                text = vcode_win.agreement_text,
                font = {size = fontsize},
                x = "0%",
                y = "0%",
                width = "100%",
            }
            vcode_win.agreement.text = vcode_win.agreement_text
            vcode_win.agreement_text = ""
            vcode_win:Show()
        end
    )

    return obj
end 
