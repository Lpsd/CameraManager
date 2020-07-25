local function call_inst(method, ...)
	local instance = CameraManager:getInstance()
	
	if (not instance) then
		return outputDebugString("[CameraManager{export}:call_inst] Failed to retrieve CameraManager instance") and false
	end
	
	if (not instance[method]) then
		return outputDebugString("[CameraManager{export}:call_inst] Method '" .. method .. "' does not exist") and false
	end
	
	return instance[method](instance, ...)
end

function addCameraScene(...)
	return call_inst("addCameraScene", ...)
end

function setAutoplayEnabled(...)
	return call_inst("setAutoplayEnabled", ...)
end

function setCameraFadeDuration(...)
	return call_inst("setCameraFadeDuration", ...)
end

function getCurrentScene(...)
	return call_inst("getCurrentScene", ...)
end

function startNextScene(...)
	return call_inst("startNextScene", ...)
end

function stopCurrentScene(...)
	return call_inst("stopCurrentScene", ...)
end