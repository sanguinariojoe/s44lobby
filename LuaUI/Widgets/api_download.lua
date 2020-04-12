function widget:GetInfo ()
    return {
        name = "Files downloader",
        desc = "Provides an easy downloading interface",
        author = "Jose Luis Cercos-Pita",
        date = "09/04/2020",
        license = "GPL v3",
        layer     = -1000,
        enabled   = true,
        handler   = true,
        api       = true,
        hidden    = true,
    }
end

local LISTENER_NAMES = {"DownloadStarted",
                        "DownloadFinished",
                        "DownloadFailed",
                        "DownloadProgress",}
local downloads = {}
local downloadByID = {}

local function CallListeners(download, event, ...)
    if download.listeners[event] == nil then
        return nil -- no event listeners
    end
    local eventListeners = download.listeners[event]
    for i = 1, #eventListeners do
        local listener = eventListeners[i]
        args = {...}
        xpcall(function() listener(unpack(args)) end,
            function(err) Spring.Log("Downloader", LOG.ERROR, err) end )
    end
    return true
end

function AddListener(download, event, listener)
    local eventListeners = download.listeners[event]
    if eventListeners == nil then
        eventListeners = {}
        download.listeners[event] = eventListeners
    end
    table.insert(eventListeners, listener)
end

function RemoveListener(download, event, listener)
    if download.listeners[event] then
        for k, v in pairs(download.listeners[event]) do
            if v == listener then
                table.remove(download.listeners[event], k)
                if #download.listeners[event] == 0 then
                    download.listeners[event] = nil
                end
                break
            end
        end
    end
end

function Download(name, category, listeners)
    local dname = category .. " :: " .. name
    local is_new = false
    if downloads[dname] and not downloads[dname].failed and downloads[dname].progress >= 0 then
        -- Create a temporal download object so we can call some listeners
        local tmp = {name = name,
                     category = category,
                     failed = downloads[dname].failed,
                     progress = downloads[dname].progress,
                     listeners = {},}
        for _, lname in ipairs(LISTENER_NAMES) do
            if listeners[lname] ~= nil then
                if (type(listeners[lname]) == "table") then
                    for _, l in ipairs(listeners[lname]) do
                        AddListener(tmp, lname, l)
                    end
                else
                    AddListener(tmp, lname, listeners[lname])
                end
            end
        end
        CallListeners(tmp, "DownloadStarted", name, category)
        CallListeners(tmp, "DownloadProgress", name, category, tmp.progress)
        if tmp.progress >= 1 then
            CallListeners(tmp, "DownloadFinished", name, category)
        end
        tmp = nil  -- We don't need it anymore
    else
        -- Create a download object, for good this time
        downloads[dname] = {id = #downloadByID + 1,
                            name = name,
                            category = category,
                            failed = false,
                            progress = -1,
                            listeners = {},}
        downloadByID[#downloadByID + 1] = downloads[dname]
        is_new = true
    end
    -- Add the new listeners
    for _, lname in ipairs(LISTENER_NAMES) do
        if listeners[lname] ~= nil then
            if (type(listeners[lname]) == "table") then
                for _, l in ipairs(listeners[lname]) do
                    AddListener(downloads[dname], lname, l)
                end
            else
                AddListener(downloads[dname], lname, listeners[lname])
            end
        end
    end
    if is_new then
        VFS.DownloadArchive(name, category)
    end
end

function CancelDownload(name, category)
    local dname = category .. " :: " .. name
    if downloads[dname].failed then
        return
    end
    download.failed = true
    CallListeners(tmp, "DownloadFailed", name, category)
    VFS.AbortDownload(downloads[dname].id)
end


function widget:Initialize()
    -- map decompiler API
    WG.DownloadArchive = Download
    WG.AbortDownload = CancelDownload
end

function widget:DownloadStarted(id)
    local download = downloadByID[id + 1]
    if download == nil then
        return nil
    end

    download.progress = 0
    download.failed = false

    CallListeners(download, "DownloadStarted", download.name, download.category)
end

function widget:DownloadProgress(id, downloaded, total)
    local download = downloadByID[id + 1]
    if download == nil then
        return nil
    end

    if total <= 0 then
        download.progress = 0
    else
        download.progress = downloaded / total
    end
    CallListeners(download, "DownloadProgress",
                  download.name, download.category, download.progress)
end

function widget:DownloadFailed(id, errorID)
    local download = downloadByID[id + 1]
    if download == nil then
        return nil
    end

    download.failed = true
    CallListeners(download, "DownloadFailed", download.name, download.category)
end

function widget:DownloadFinished(id)
    local download = downloadByID[id + 1]
    if download == nil then
        return nil
    end

    download.progress = 1
    CallListeners(download, "DownloadFinished", download.name, download.category)
end
