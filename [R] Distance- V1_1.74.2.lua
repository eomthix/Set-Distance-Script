LIB_BASE = nil
lib_found = false

-- EXIT
function vxbxtrq()
    print("──────────────────\n\nScript Created By Sr Romero\n\n──────────────────")
    gg.clearResults()
    gg.clearList()
    gg.setVisible(true)
    os.exit()
end

local function getlib()
    local libs = gg.getRangesList("libcocos2dcpp.so")

    if #libs == 0 then
        gg.alert("❌ Couldn't find lib!")
        vxbxtrq()
        return false
    end

    LIB_BASE = libs[1].start
    lib_found = true
    return true
end

getlib()

local function detectFullArchitecture()
    if not LIB_BASE then return nil end

    local res = gg.getValues({{address = LIB_BASE + 0x12, flags = gg.TYPE_BYTE}})
    if res and #res > 0 then
        return res[1].value
    end
    return nil
end

if lib_found then
    local rawArch = detectFullArchitecture()

    if rawArch == -73 or rawArch == 183 or rawArch == 0xB7 then
        archType = 1
    elseif rawArch == 62 or rawArch == 0x3E then
        archType = 2
	else
    gg.alert("❌ Unsupported Architecture!")
    vxbxtrq()
	end
end


local kmValue = 5000
local savedPointers = {}

function prototype2distance()
    gg.setVisible(true)

    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            local menu = gg.choice({
                "🌐  START (Activate in Countryside)",
                "✏️  SET KM",
                "🖥️  LOOP",
                "🔓  PATCH",
                "❌  EXIT"
            }, nil, "Sr Romero | Eomthix (Emulator) | Distance [R BETA] | Version 1.74.2")

            if menu == 1 then
                isnwele()
            elseif menu == 2 then
                xxmoo()
            elseif menu == 3 then
                lqnwlsw()
            elseif menu == 4 then
                lsmwlsl()
            elseif menu == 5 then
                vxbxtrq()
            end
        end
        gg.sleep(200)
    end
end


function isnwele()
    gg.clearResults()
    gg.setVisible(false)

	local primaryOffset = 0

    if archType == 1 then
        primaryOffset = 0x2051598
    elseif archType == 2 then
        primaryOffset = 0x20ACE18
    else
        gg.alert("❌ Unsupported Architecture!")
        vxbxtrq()
    end

    local target = LIB_BASE + primaryOffset

    gg.clearResults()
    gg.setRanges(gg.REGION_C_ALLOC)
    gg.searchNumber(target, gg.TYPE_QWORD)

    local count = gg.getResultCount()
    if count == 0 then
        gg.toast("NOT WORK")
        return
    end

    local results = gg.getResults(count)
    local addListItems = {}
    savedPointers = {}

    for i = 1, #results do
        local addrAsValue = results[i].address

        gg.clearResults()
        gg.setRanges(gg.REGION_C_ALLOC)
        gg.searchNumber(addrAsValue, gg.TYPE_QWORD)

        local count2 = gg.getResultCount()
        if count2 > 0 then
            local results2 = gg.getResults(count2)

            for j = 1, #results2 do
                local offsetAddr = results2[j].address - 0xAC

                gg.clearResults()
                gg.setRanges(gg.REGION_C_ALLOC)
                gg.searchNumber(offsetAddr, gg.TYPE_QWORD)

                local count3 = gg.getResultCount()
                if count3 > 0 then
                    local results3 = gg.getResults(count3)
                    for k = 1, #results3 do
                        local addr = results3[k].address
                        table.insert(addListItems, {
                            address = addr,
                            flags   = gg.TYPE_QWORD
                        })

                        table.insert(savedPointers, addr)
                    end
                end
            end
        end
    end

    if #addListItems == 0 then
        gg.toast("NOT WORK")
        return
    end

    gg.addListItems(addListItems)
    gg.toast("✓✓✓")
end


function xxmoo()
    local input = gg.prompt(
        {"Set km:"},
        {tostring(kmValue)},
        {"number"}
    )
    if input and input[1] then
        kmValue = tonumber(input[1]) or kmValue
        gg.toast("KM  =  " .. kmValue)
    end
end


-- PATCH
function lsmwlsl(showToast)
    gg.setVisible(false)

    local list = gg.getListItems()
    if not list or #list == 0 then
        gg.toast("Run START first")
        return
    end

    local pointerReads = {}

    for i = 1, #list do
        local item = list[i]
        if item and item.address then
            pointerReads[#pointerReads + 1] = {
                address = item.address,
                flags = gg.TYPE_QWORD
            }
        end
    end

    if #pointerReads == 0 then
        gg.toast("Data Empty")
        return
    end

    gg.loadResults(pointerReads)
    local pointerResults = gg.getResults(#pointerReads) or {}

    if #pointerResults == 0 then
        gg.toast("Pointer Error")
        return
    end

    local edits = {}

    for i = 1, #pointerResults do
        local item = pointerResults[i]

        if item and type(item.value) == "number" and item.value ~= 0 then
            edits[#edits + 1] = {address = item.value + 0x0,  flags = gg.TYPE_DWORD, value = kmValue}
            edits[#edits + 1] = {address = item.value + 0x10, flags = gg.TYPE_FLOAT, value = 2000000000}
            edits[#edits + 1] = {address = item.value + 0x14, flags = gg.TYPE_FLOAT, value = 2000000000}
        end
    end

    if #edits > 0 then
        gg.setValues(edits)
        if showToast ~= false then
            gg.toast("✓ ✓✓")
        end
    else
        gg.toast("No edits")
    end

    gg.clearResults()
end


-- LOOP
function lqnwlsw()
    local input = gg.prompt({"Loops [1;500]"}, {"66"}, {"number"})
    if not input or not tonumber(input[1]) then
        gg.toast("Error input")
        return
    end

    local reps = tonumber(input[1])

    for i = 1, reps do
        lsmwlsl(false)
    end

    gg.setVisible(false)
    gg.toast("✓✓✓")
end


prototype2distance()
