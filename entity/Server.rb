class Server
	attr_accessor :id, :desc, :env, :host, :as, :port, :jvmmemory, :datasource

	def initialize(id, desc, env, host, as, port, jvmmemory, datasource)
		@id = id
		@desc = desc
		@env = env
		@host = host
		@as = as
		@port = port
		@jvmmemory = jvmmemory
		@datasource = datasource
	end

	def to_s
		return { :id => @id, :desc => @desc, :env => @env, :host => @host, :as => @as, :port => @port.to_i, :jvmmemory => @jvmmemory, :datasource => @datasource }
	end
end
