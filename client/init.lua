-- Custom events
addEvent("onCameraManagerInitialized", true)

function initCameraManager()
	local cameraManager = CameraManager:new()
	
	if (not cameraManager) then
		return outputDebugString("[init] CameraManager failed to initialize") and false
	end
	
	triggerEvent("onCameraManagerInitialized", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, initCameraManager)