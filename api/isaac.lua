-- Compatibility function for unpacking binary data
local function unpackLE(data, offset, num_bytes)
    local value = 0
    for i = 0, num_bytes - 1 do
        value = value + data:byte(offset + i + 1) * (256 ^ i)
    end
    return value
end

-- Function to get section offsets
local function getSectionOffsets(data)
    local ofs = 0x14
    local sectData = {-1, -1, -1}
    local entryLens = {1, 4, 4, 1, 1, 1, 1, 4, 4, 1}
    local sectionOffsets = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

    for i = 1, #entryLens do
        for j = 1, 3 do
            sectData[j] = unpackLE(data, ofs, 2)  -- Use unpackLE here
            ofs = ofs + 4
        end
        
        if sectionOffsets[i] == 0 then
            sectionOffsets[i] = ofs
        end
        
        for j = 1, sectData[3] do
            ofs = ofs + entryLens[i]
        end
    end
    return sectionOffsets
end

-- Function to get the secrets
local function getSecrets(data)
    local secrets_data = {}
    local offs = getSectionOffsets(data)[1]
    
    -- Retrieve the secrets data (1 byte each)
    for i = 1, 637 do
        secrets_data[i] = data:byte(offs + i)  -- Get 1 byte at a time
    end
    return secrets_data
end

-- Function to read an integer
local function getInt(data, offset, num_bytes)
    local num_bytes = num_bytes or 2  -- Default to 2 bytes if not specified
    return unpackLE(data, offset, num_bytes)
end

-- Function to read a file
local function read(filePath)
    local data, size = NFS.read(filePath)  -- Read the file into 'data' and return size
    if not data then
        error("Failed to read file: " .. filePath)  -- Handle error if file doesn't read
    end
    return data  -- Return the file content
end

return {
    read = read,
    getInt = getInt,
    getSecrets = getSecrets,
    getSectionOffsets = getSectionOffsets,
}