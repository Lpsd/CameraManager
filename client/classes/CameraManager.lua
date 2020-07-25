CameraManager = inherit(Instance)

function CameraManager:constructor()
	self.m_scenes = {}
	self.m_currentScene = false
	self.m_queueScenes = false
	
	self.m_autoplay = true
	self.m_cameraFadeDurationMs = 750
	
	self.m_constructorFunctions = {
		["smooth-move"] = bind(self.smoothMoveCamera, self),
		["rotation"] = bind(self.attachRotatingCamera, self)
	}
	
	self.m_renderFunctions = {
		["smooth-move"] = bind(self.renderSmoothMoveScene, self),
		["rotation"] = bind(self.renderRotationScene, self)
	}
	
	self.m_renderHandlerState = {
		["smooth-move"] = false,
		["rotation"] = false
	}
	
	self.m_destructorFunctions = {
		["smooth-move"] = bind(self.destroySmoothMoveScene, self),
		["rotation"] = bind(self.destroyRotationScene, self)
	}
	
	self.m_cameraSphereRadius = 100
	
	self.m_fInitializeScene = bind(self.initializeScene, self)
	
	self.m_fAddCameraScene = bind(self.addCameraScene, self)
	
	addEvent("addCameraScene", true)
	addEventHandler("addCameraScene", root, self.m_fAddCameraScene)
	
	return self
end

function CameraManager:destructor()

end

-- ********************************************************************************************************************************** --

function CameraManager:addCameraScene(sceneType, ...)
	local constructor = self.m_constructorFunctions[sceneType]
	
	if (not constructor) then
		return outputDebugString("[CameraManager:addCameraScene()] Scene type not found! (" .. sceneType ..")") and false
	end
	
	return constructor(...)
end

-- ********************************************************************************************************************************** --

function CameraManager:smoothMoveCamera(fromPosX, fromPosY, fromPosZ, fromRotX, fromRotY, fromRotZ, toPosX, toPosY, toPosZ, toRotX, toRotY, toRotZ, durationMs, fromRoll, toRoll, fromFov, toFov, positionEasingType, rotationEasingType, fovEasingType, preFadeCamera)
	local fromPosVector, fromRotVector, toPosVector, toRotVector = Vector3(fromPosX, fromPosY, fromPosZ), Vector3(fromRotX, fromRotY, fromRotZ), Vector3(toPosX, toPosY, toPosZ), Vector3(toRotX, toRotY, toRotZ)
	
	fromFov = fromFov or getCameraFieldOfView("player")
	toFov = toFov or getCameraFieldOfView("player")
	durationMs = durationMs or 5000
	positionEasingType = positionEasingType or "InOutQuad"
	rotationEasingType = rotationEasingType or "InOutQuad"
	fovEasingType = fovEasingType or "InOutQuad"
	preFadeCamera = preFadeCamera
	
	local radius = (fromPosVector - toPosVector):getLength()
	
	local scene = {
		from = {
			position = fromPosVector,
			rotation = fromRotVector,
			roll = fromRoll,
			fov = fromFov
		},
		to = {
			position = toPosVector,
			rotation = toRotVector,
			roll = toRoll,
			fov = toFov
		},
		duration = durationMs,
		positionEasingType = positionEasingType,
		rotationEasingType = rotationEasingType,
		fovEasingType = fovEasingType,
		preFadeCamera = preFadeCamera,
		type = "smooth-move",
		id = getTickCount() .. string.random(8),
		start = false
	}
	
	return self:addScene(scene)
end

function CameraManager:smoothMoveCamera_internal()

end

-- You can also supply an element as the first argument
function CameraManager:attachRotatingCamera(posX, posY, posZ, distance, zOffset, rotationDurationMs, timesToRotate, rotationEasingType, preFadeCamera)	
	local posVector = Vector3(posX, posY, posZ)
	
	local attachedToElement = isElement(posVector) and posVector or false
	
	distance = tonumber(distance) or 15
	zOffset = tonumber(zOffset) or 10
	rotationDurationMs = tonumber(rotationDurationMs) or 10000
	timesToRotate = tonumber(timesToRotate) or 0 -- 0 = infinite
	rotationEasingType = rotationEasingType or "Linear"
	preFadeCamera = true
	
	if (attachedToElement) then
		posVector = Vector3(unpack({getElementPosition(posVector)}))
	end
	
	local scene = {
		posVector = posVector,
		distance = distance,		
		zOffset = zOffset,
		attachedElement = attachedToElement,
		timesToRotate = timesToRotate,
		duration = rotationDurationMs,
		rotations = 0,
		rotationEasingType = rotationEasingType,
		preFadeCamera = preFadeCamera,
		type = "rotation",
		id = getTickCount() .. string.random(8),		
		start = false
	}
	
	return self:addScene(scene)
end

function CameraManager:detachRotatingCamera()
	local scene = self:getCurrentScene()
	
	if (not scene) or (scene.type ~= "rotation") then
		return outputDebugString("[CameraManager:detachRotatingCamera] A camera rotation scene is not currently playing") and false
	end
	
	self:stopCurrentScene()
end

-- ********************************************************************************************************************************** --

function CameraManager:setAutoplayEnabled(state)
	self.m_autoplay = state and true or false
	return true
end

function CameraManager:setCameraFadeDuration(ms)
	ms = tonumber(ms)
	if (not ms) then
		return outputDebugString("[CameraManager:setCameraFadeDuration] Expected a number value, got '" .. type(seconds) .. "'") and false
	end
	self.m_cameraFadeDurationMsMs = ms
	return true
end

-- ********************************************************************************************************************************** --

function CameraManager:getSceneRenderFunction(scene)
	if (not scene.type) then
		return outputDebugString("[CameraManager:getSceneRenderFunction] Scene is not valid or has no type") and false
	end
	
	return self.m_renderFunctions[scene.type]
end

function CameraManager:getSceneDestructorFunction(scene)
	if (not scene.type) then
		return outputDebugString("[CameraManager:getSceneDestructorFunction] Scene is not valid or has no type") and false
	end
	
	return self.m_destructorFunctions[scene.type]
end

-- ********************************************************************************************************************************** --

-- Returns true or false. If true then two extra values are returned (sceneIndex, isScenePlaying)
function CameraManager:isSceneQueued(scene)
	for i, s in ipairs(self.m_scenes) do
		if (scene.id == s.id) then
			return true, i, (i == 1) and true or false
		end
	end
	return false
end

function CameraManager:getCurrentScene()
	return self.m_scenes[self.m_currentScene]
end

-- ********************************************************************************************************************************** --

function CameraManager:addScene(scene)
	if (self:isSceneQueued(scene)) then
		return outputDebugString("[CameraManager:addScene] Scene already exists!") and false
	end

	self.m_scenes[#self.m_scenes+1] = scene
	
	
	if (not self:getCurrentScene()) and (self.m_autoplay) then
		self:startNextScene()
	end

	return true	
end

function CameraManager:removeScene(scene)
	local isSceneQueued, sceneIndex, isScenePlaying = self:isSceneQueued(scene)
	
	if (not isSceneQueued) then
		return false
	end
	
	table.remove(self.m_scenes, sceneIndex)
	
	return isScenePlaying and self:startNextScene() or true
end

-- ********************************************************************************************************************************** --

function CameraManager:startScene(sceneIndex)
	if (not self:isSceneQueued(self.m_scenes[sceneIndex])) then
		return outputDebugString("[CameraManager:startScene] Scene has not been queued or does not exist (via smoothMoveCamera/addScene)!") and false
	end
	
	-- Make sure any current scene is stopped
	if (self:getCurrentScene()) then
		self:stopCurrentScene()
	end
	
	-- Set current scene index
	self.m_currentScene = sceneIndex	
	
	local scene = self.m_scenes[sceneIndex]
	
	-- Make sure camera is faded in (includes 'fancy' fade-out & fade-in between scenes)
	if (scene.preFadeCamera) then
		fadeCamera(false, (self.m_cameraFadeDurationMs / 1000))
		
		-- Initialize scene after camera fully faded out
		scene.initializerTimer = setTimer(self.m_fInitializeScene, self.m_cameraFadeDurationMs, 1)
	else
		self:initializeScene()
	end
end

function CameraManager:initializeScene()
	local scene = self:getCurrentScene()
	
	fadeCamera(true, self.m_cameraFadeDurationMs / 1000)
	
	if (isTimer(scene.initializerTimer)) then
		scene.initializerTimer = nil
	end
	
	-- Initialize camera scene
	scene.start = getTickCount()
	
	if (not self.m_renderHandlerState[scene.type]) then
		addEventHandler("onClientPreRender", root, self:getSceneRenderFunction(scene))
		self.m_renderHandlerState[scene.type] = true
	end
	
	scene.destructorTimer = setTimer(self:getSceneDestructorFunction(scene), scene.duration, 1, scene)	
end

function CameraManager:startNextScene()
	if (#self.m_scenes == 0) then
		return outputDebugString("[CameraManager:startNextScene] No camera scenes are currently queued") and false
	end
	
	local nextIndex = 1
	
	if (self:getCurrentScene()) then
		if (self.m_scenes[self.m_currentScene+1]) then
			nextIndex = self.m_currentScene + 1
		end
	end
	
	return self:startScene(nextIndex)
end

function CameraManager:stopCurrentScene()
	local scene = self:getCurrentScene()
	
	if (not scene) then
		return outputDebugString("[CameraManager:stopCurrentScene] No scene currently playing") and false
	end
	
	removeEventHandler("onClientPreRender", root, self:getSceneRenderFunction(scene))
	self.m_renderHandlerState[scene.type] = false
	
	if (isTimer(scene.destroyTimer)) then
		killTimer(scene.destroyTimer)
		scene.destroyTimer = nil
	end
	
	if (isTimer(scene.initializerTimer)) then
		killTimer(scene.initializerTimer)
		scene.initializerTimer = nil
	end

	table.remove(self.m_scenes, self.m_currentScene)
	self.m_currentScene = false
	
	return true
end

-- ********************************************************************************************************************************** --

function CameraManager:destroySmoothMoveScene()
	self:stopCurrentScene()
	if (self.m_autoplay) then
		self:startNextScene()
	end
end

function CameraManager:destroyRotationScene()
	local scene = self:getCurrentScene()
	
	scene.rotations = scene.rotations + 1
	
	if (scene.timesToRotate == 0) or (scene.rotations < scene.timesToRotate) then
		return self:initializeScene()
	end
	
	self:stopCurrentScene()
	
	if (self.m_autoplay) then
		self:startNextScene()
	end	
end

-- ********************************************************************************************************************************** --

function CameraManager:renderSmoothMoveScene()
	local scene = self:getCurrentScene()
	
	local now = getTickCount()
	local start = scene.start
	local duration = scene.duration
	local progress = (now - start) / duration
	
	local x, y, z = interpolateBetween(scene.from.position, scene.to.position, progress, scene.positionEasingType)
	local rx, ry, rz = interpolateBetween(scene.from.rotation, scene.to.rotation, progress, scene.rotationEasingType)
	
	local roll = interpolateBetween(scene.from.roll, 0, 0, scene.to.roll, 0, 0, progress, scene.rotationEasingType)
	local fov = interpolateBetween(scene.from.fov, 0, 0, scene.to.fov, 0, 0, progress, scene.fovEasingType)
	
	local camX, camY, camZ, camRotX, camRotY, camRotZ = getCameraMatrix()
	
	setCameraMatrix(x, y, z, camRotX, camRotY, camRotZ, roll, fov)
	setElementRotation(getCamera(), rx, ry, rz)
end

function CameraManager:renderRotationScene()
	local scene = self:getCurrentScene()
	
	if (scene.attachedElement) then
		local x, y, z = getElementPosition(scene.attachedElement)
		scene.posVector = Vector3(x, y, z)
	end
	
	local now = getTickCount()
	local start = scene.start
	local duration = scene.duration
	
	local progress = (now - start) / duration	
	
	local angle = interpolateBetween(0, 0, 0, 360, 0, 0, progress, scene.rotationEasingType)
	local x, y = self:getPointFromDistanceRotation(scene.posVector:getX(), scene.posVector:getY(), scene.distance, angle)
	
	setCameraMatrix(x, y, (scene.posVector:getZ() + scene.zOffset), scene.posVector)
end

-- ********************************************************************************************************************************** --

function CameraManager:getPointFromDistanceRotation(x, y, distance, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * distance
	local dy = math.sin(a) * distance
	return (x + dx), (y + dy)
end

-- ********************************************************************************************************************************** --