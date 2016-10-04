--
-- perlin.lua
-- Perlin Noise module 
-- https://forums.coronalabs.com/topic/14101-perlin-noise-module-need-help-to-convert-to-lua/
--

local m = {}

function M.new()	
	local perlin = {}			
	for idx = 1,512 do		
		perlin[#perlin+1] = math.random()	
	end		
 
	perlin.octate = 4	
	perlin.persistence = 0.25		
 
	function perlin:cos_interpolate(a,b,x)	
		local ft = x * math.pi	
		f = (1.0 - math.cos(ft))*0.5	
		return (a*(1.0-f)) + (b*f)
	end
 
	function perlin:setOctaves(x)		
		perlin.octate = x	
	end		
 
	function perlin:setPersistence(x)		
		perlin.persistence = x	
	end		
 
	function perlin:noise_int(x)		
		local y = (x % 512)+1		
		return perlin[y]	
	end	
 
	function perlin:smooth_noise1(x)		
		return (self:noise_int(x)/2) + (self:noise_int(x-1)/4) + (self:noise_int(x+1)/4)
	end
 
	function perlin:interpolate_noise_1(x)		
		local ix,f = math.modf(x)		
		local v1 = self:smooth_noise1(ix)		
		local v2 = self:smooth_noise1(ix+1)		
		return perlin:cos_interpolate(v1,v2,f)	
	end
	
	function perlin:noise(x)		
		local total = 0		
		local p = perlin.persistence		
		local n = perlin.octate-1		
		local freq, amplitude		
		
		for idx = 0,n do			
			freq = 2^idx			
			amplitude = p^idx			
			total = total + perlin:interpolate_noise_1(x*freq) * amplitude		
		end
		
		total = math.min(total,1.0)		
		total = math.max(0.0,total)		
		return total	
	end
 
	return perlin
end

return m