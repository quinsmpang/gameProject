local RandomTool = 
{
}
local meta = RandomTool

--初始化
function meta:init( ... )
    math.randomseed(os.time())
end

--用该函数的时候需要种子  math.randomseed(os.time())
function  meta:randnum(min,max)
    local random_num = nil
    if min == nil and max == nil then 
        random_num = math.random()
    elseif min and max == nil  then 
	    local diff = min - 1 + 1 
        random_num = math.floor(math.random()*diff) % diff + min
    else
	    local diff = max - min + 1 
        random_num = math.floor(math.random()*diff) % diff + min
    end
    --cclog("random_num ========= " ..random_num)
	return random_num
end



return RandomTool