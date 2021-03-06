class Server
	attr_accessor :id, :desc, :env, :target, :host, :as, :port, :jvmmemory, :datasource, :application

	def initialize(id, desc, env, target, host, as, port, jvmmemory, datasource, application)
		@id = id
		@desc = desc
		@env = env
		@target = target
		@host = host
		@as = as
		@port = port
		@jvmmemory = jvmmemory
		@datasource = datasource
		@application = application
	end

	def to_s
		return { :id => @id, :desc => @desc, :env => @env, :target => @target, :host => @host, :as => @as, :port => @port.to_i, :jvmmemory => @jvmmemory, :datasource => @datasource, :application => @application }
	end
end
