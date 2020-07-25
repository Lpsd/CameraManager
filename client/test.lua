local cameraScenes = {
	{
		from = {
			position = Vector3(400, 150, 125),
			rotation = Vector3(-25, -25, 180),
			roll = 0,
			fov = 70
		},
		to = {
			position = Vector3(-20, 0, 35),
			rotation = Vector3(-20, -10, 100),
			roll = 0,
			fov = 70
		},
		duration = 1000,
		fade = true
	},
	{
		from = {
			position = Vector3(-20, 0, 35),
			rotation = Vector3(-20, -10, 100),
			roll = 0,
			fov = 70
		},
		to = {
			position = Vector3(-2000, -2500, 175),
			rotation = Vector3(-30, 0, 0),
			roll = 0,
			fov = 70
		},
		duration = 1000,
		fade = false
	},
	{
		from = {
			position = Vector3(-2000, -2500, 175),
			rotation = Vector3(-30, 0, 0),
			roll = 0,
			fov = 70
		},
		to = {
			position = Vector3(400, 150, 125),
			rotation = Vector3(-25, -25, 180),
			roll = 0,
			fov = 70
		},
		duration = 1000,
		fade = false
	}			
}

function importCameraScenes()
	for i, scene in ipairs(cameraScenes) do
		local from = scene.from
		local to = scene.to
		
		CameraManager:getInstance():smoothMoveCamera(from.position:getX(), from.position:getY(), from.position:getZ(), from.rotation:getX(), from.rotation:getY(), from.rotation:getZ(), to.position:getX(), to.position:getY(), to.position:getZ(), to.rotation:getX(), to.rotation:getY(), to.rotation:getZ(), scene.duration, from.roll, to.roll, from.fov, to.fov, "InOutQuad", "InOutQuad", "InOutQuad", scene.fade)
	end
end

function init()
	-- Import camera scenes twice, intentional
	importCameraScenes()
	importCameraScenes()
end
addEventHandler("onCameraManagerInitialized", root, init)