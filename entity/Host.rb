class Host
	attr_accessor :id, :desc, :env, :target, :server, :application, :datasource, :as, :memory

	def initialize(id, desc, env, target, server, application, datasource, as, memory)
		@id = id
		@desc = desc
		@env = env
		@target = target
		@server = server
		@application = application
		@datasource = datasource
		@as = as
		@memory = memory
	end

	def to_s
		return { :id => @id, :desc => @desc, :env => @env, :target => @target, :server => @server, :application => @application, :datasource => @datasource, :as => @as, :memory => @memory }
	end
end
