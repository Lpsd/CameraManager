-- ********************************************************************************************************************************** --
BaseClass = {
	m_events = {}
}
-- ********************************************************************************************************************************** --

function BaseClass:new(...)
	return new(self, ...)
end

function BaseClass:delete(...)
	self:unregisterEvents()
	
	delete(self, ...)
end

-- ********************************************************************************************************************************** --

function BaseClass:addEvent(eventName, attachedTo, handlerFunction, getPropagated, priority)
	if (not eventName) or (not attachedTo) or (not handlerFunction) then
		return false
	end
	
	getPropagated = getPropagated or true
	priority = priority or "normal"
	
	addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	
	return table.insert(self.m_events, {
		eventName = eventName,
		attachedTo = attachedTo,
		handlerFunction = handlerFunction
	})
end

-- ********************************************************************************************************************************** --

function BaseClass:unregisterEvents()
	for i, event in ipairs(self.m_events) do
		removeEventHandler(event.eventName, event.attachedTo, event.handlerFunction)
	end
end

-- ********************************************************************************************************************************** --
