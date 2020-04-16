function widget:GetInfo ()
    return {
        name = "Map minimap decompiler",
        desc = "Decompile a map and save the minimap",
        author = "Jose Luis Cercos-Pita",
        date = "30/03/2020",
        license = "GPL v3",
        layer = 1,
        enabled = true,
    }
end

local USE_MIPMAPS = false
local bit = VFS.Include("libs/luabit/bit.lua", nil, VFS.RAW_FIRST)
local shader = nil
local dds2png = {}
local mapnames = {}

local function _inspect_mapname()
    local info
    if not VFS.FileExists("mapinfo.lua") then
        return ""
    end

    info = VFS.Include("mapinfo.lua")
    local name = info.name
    if info.version then
        name = name .. " " .. info.version
    end

    return name
end

local function _inspect_mapname_wrapper(map)
    -- Apparently VFS.UseArchive lead to spring engine crashes, so better just
    -- simply mapping and unmapping the resources
    -- return VFS.UseArchive(map, _inspect_mapname)
    VFS.MapArchive(map)
    local name = _inspect_mapname()
    VFS.UnmapArchive(map)
    return name
end

local function _find_map(map)
    local maps = VFS.GetMaps()
    local candidate = nil
    local score = 0
    for _, m in ipairs(maps) do
        -- First check if it is already a straight map name
        if m:lower() == map:lower() then
            return m
        end
        -- Try to look for it as a file path
        local path = VFS.GetArchivePath(m)
        if path:len() > map:len() then
            path = path:sub(path:len() - map:len() + 1)
        end
        if path == map then
            return m
        end
        -- Try to look inside the map file
        if mapnames[m] == nil then
            mapnames[m] = _inspect_mapname_wrapper(m)
        end
        if mapnames[m] ~= "" and mapnames[m] == map then
            return m
        end
    end

    return nil
end

local function _read_header(data)
    local hdr_size = 16 + 4 * 16
    if #data < hdr_size then
        Spring.Log("GetMinimap", LOG.ERROR,
                   "SMF file has " .. tostring(#data) .. " bytes, but ".. tostring(hdr_size) .. " are required")
    end
    local hdr = {}
    hdr.magic = data:sub(1, 15)
    if hdr.magic ~= "spring map file" then
        Spring.Log("GetMinimap", LOG.ERROR, "Not a SMF file")
    end
    local i = 17
    hdr.version = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.mapid = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.mapx = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.mapy = VFS.UnpackS32(data, i)
    i = i + 4

    if hdr.mapx % 128 or hdr.mapy % 128 then
        Spring.Log("GetMinimap", LOG.WARNING,
                   "Invalid map dimensions " .. tostring(hdr.mapx) .. " x ".. tostring(hdr.mapy))
    end

    hdr.squareSize = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.texelPerSquare = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.tilesize = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.minHeight = VFS.UnpackF32(data, i)
    i = i + 4
    hdr.maxHeight = VFS.UnpackF32(data, i)
    i = i + 4
    hdr.heightmapPtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.typeMapPtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.tilesPtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.minimapPtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.metalmapPtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.featurePtr = VFS.UnpackS32(data, i)
    i = i + 4
    hdr.numExtraHeaders = VFS.UnpackS32(data, i)
    i = i + 4

    return hdr
end

local DDS_CAPS        = 0x00000001
local DDS_HEIGHT      = 0x00000002
local DDS_WIDTH       = 0x00000004
local DDS_PIXELFORMAT = 0x00001000
local DDS_FOURCC      = 0x00000004
local DDS_COMPLEX     = 0x00000008
local DDS_TEXTURE     = 0x00001000
local DDS_MIPMAPCOUNT = 0x00020000
local DDS_LINEARSIZE  = 0x00080000
local DDS_MIPMAP      = 0x00400000

local function _extract_minimap(hdr, data, folder)
    local sx, sy, sc = 1024, 1024, 699064
    local out = io.open(folder .. "/minimap.dds", "w")
    if out == nil then
        Spring.Log("GetMinimap", LOG.WARNING,
                   "Failure creating file '" .. folder .. "/minimap.dds'")
    end

    local flags = bit.bor(bit.bor(bit.bor(bit.bor(bit.bor(DDS_CAPS,
                                                          DDS_HEIGHT),
                                                          DDS_WIDTH),
                                                          DDS_PIXELFORMAT),
                                                          DDS_MIPMAPCOUNT),
                                                          DDS_LINEARSIZE)
    local blocksize = 8
    local linearsize = math.floor(((sx + 3) / 4)) * math.floor(((sy + 3) / 4)) * blocksize
    local num_mipmaps, ddscaps, dxtc
    if USE_MIPMAPS then
        num_mipmaps = 9
        ddscaps = bit.bor(bit.bor(DDS_COMPLEX, DDS_MIPMAP), DDS_TEXTURE)
        dxtc = data:sub(hdr.minimapPtr + 1, hdr.minimapPtr + sc)
    else
        num_mipmaps = 1
        ddscaps = DDS_TEXTURE
        dxtc = data:sub(hdr.minimapPtr + 1, hdr.minimapPtr + linearsize)
    end

    -- To understand the following header values, I suggest taking a look to
    -- DevIL library WriteHeader() method, at DevIL/src-IL/src/il_dds-save.cpp
    -- Also the format specification can be visited:
    -- https://docs.microsoft.com/en-us/windows/win32/direct3ddds/dds-header
    -- TODO: Deal with Big endian systems
    out:write("DDS ")
    out:write(VFS.PackU32(124))
    out:write(VFS.PackU32(flags1))
    out:write(VFS.PackU32(sy))
    out:write(VFS.PackU32(sx))
    out:write(VFS.PackU32(linearsize))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(num_mipmaps))

    for i = 1,11 do
        out:write(VFS.PackU32(0))
    end

    out:write(VFS.PackU32(32))
    out:write(VFS.PackU32(DDS_FOURCC))
    out:write("DXT1")
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))

    out:write(VFS.PackU32(ddscaps))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))
    out:write(VFS.PackU32(0))

    out:write(dxtc)

    out:close()

    -- Add it to the list of dds2png conversions
    dds2png[#dds2png + 1] = {fi = folder .. "/minimap.dds",
                             fo = folder .. "/minimap.png",
                             aspect = hdr.mapy / hdr.mapx}
end

local function _decompile_map(map, folder)
    if Spring.CreateDir(folder) == false then
        Spring.Log("GetMinimap", LOG.ERROR,
                   "Failure creating the folder '" .. folder .. "'")
        return false
    end

    local mapfile = VFS.GetArchiveInfo(map).mapfile
    Spring.Echo("Loading '" .. mapfile .. "'...")
    local data = VFS.LoadFile(mapfile)
    local hdr = _read_header(data)
    _extract_minimap(hdr, data, folder)

    return true
end

local function _decompile_map_wrapper(map, folder)
    -- Apparently VFS.UseArchive lead to spring engine crashes, so better just
    -- simply mapping and unmapping the resources
    -- return VFS.UseArchive(map, _decompile_map, map, folder)
    VFS.MapArchive(map)
    local success = _decompile_map(map, folder)
    VFS.UnmapArchive(map)
    return success
end

function GetMinimap(map, folder)
    folder = folder or map .. ".decompiled"

    local mapname = _find_map(map)
    if mapname == nil then
        Spring.Log("GetMinimap", LOG.ERROR, "Cannot find map '" .. map .. "'")
        return false
    end

    local success = _decompile_map_wrapper(mapname, folder)
    if not success then
        if success == nil then
            Spring.Log("GetMinimap", LOG.ERROR,
                       "Failure using '" .. map .. "' archive")
        else
            Spring.Log("GetMinimap", LOG.ERROR,
                       "Failure excuting _decompile_map()")            
        end
    end
    
    return success
end

function GetMinimapCmd(cmd, optLine)
    local map = nil
    local folder = nil
    
    words = {}
    for word in optLine:gmatch("%S+") do
        table.insert(words, word)
    end
    for i = 1,#words,2 do
        if words[i] == 'map' then
            map = words[i + 1]
        elseif words[i] == 'folder' then
            folder = words[i + 1]
        end
    end

    if map == nil then
        Spring.Log("GetMinimap", LOG.ERROR, "map argument is mandatory")
        return false
    end

    return GetMinimap(map, folder)
end

function widget:Initialize()
    shader = shader or gl.CreateShader({
        fragment = VFS.LoadFile("LuaUI\\Widgets\\Shaders\\dds2png.fs", VFS.ZIP),
        uniformInt = {colors = 0},
    })
    if not shader then
        Spring.Log("GetMinimap", LOG.ERROR,
                   "Failed to create png converter shader!")
        Spring.Echo(gl.GetShaderLog())
        return
    end

    -- map decompiler API
    WG.GetMinimap = GetMinimap

    -- /getminimap map mapname/mapfile [folder path]
    widgetHandler:AddAction("getminimap", GetMinimapCmd)
end

function widget:Update()
    -- Look for untracked maps
    local maps = VFS.GetMaps()
    for _, m in ipairs(maps) do
        if mapnames[m] == nil then
            mapnames[m] = _inspect_mapname_wrapper(m)
            return
        end
    end
end

function widget:DrawGenesis()
    if shader == nil or #dds2png == 0 then
        return
    end

    Spring.Echo("Converting " .. dds2png[#dds2png].fi .. " -> " .. dds2png[#dds2png].fo)

    local textinfo = gl.TextureInfo(dds2png[#dds2png].fi)
    local xsize, ysize = textinfo.xsize, textinfo.ysize
    local aspect = dds2png[#dds2png].aspect
    if aspect > 1 then
        xsize = math.floor(xsize / aspect + 0.5)        
    else
        ysize = math.floor(ysize * aspect + 0.5)
    end
    local output = output or gl.CreateTexture(xsize, ysize, {
        fbo = true, min_filter = GL.LINEAR, mag_filter = GL.LINEAR,
        wrap_s = GL.CLAMP, wrap_t = GL.CLAMP,
    })
    if not output then
        Spring.Log("GetMinimap", LOG.ERROR,
                   "Failed to create FBO texture")
        return
    end

    gl.UseShader(shader)
        gl.Texture(0, dds2png[#dds2png].fi)

        gl.RenderToTexture(output, gl.TexRect, -1, 1, 1, -1)

        gl.Texture(0, false)
    gl.UseShader(0)

    gl.Texture(output)
    gl.RenderToTexture(output, gl.SaveImage, 0, 0, xsize, ysize, dds2png[#dds2png].fo)
    gl.Texture(false)

    gl.DeleteTexture(output)
    gl.DeleteTexture(dds2png[#dds2png].fi)

    dds2png[#dds2png] = nil
end
